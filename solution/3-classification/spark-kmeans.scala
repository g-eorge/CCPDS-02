// Scala script to be run in the Spark shell via :load /path/to/file.scala

import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.linalg.Vectors
import scala.collection.mutable.{Map => MutableMap}

// Convert a row to a vector removing the patient_id and label fields
def vector(row: Array[String]) = {
  val label = row(4).toDouble
  // val fields = row.tail.slice(0,3) ++ row.tail.slice(4,row.length)
  val fields = row.slice(5, row.length)
  new LabeledPoint(label, Vectors.dense(fields.map(_.toDouble)))
}

// Load the data
val project = "/Users/george/Src/CCP2014-01"
val file = s"$project/data/claim_vector_sample.csv"
val examples = sc.textFile(file)

// Parse the data
val labeledPoints = examples.map(line => vector(line.split(','))).cache()
val points = labeledPoints.map(_.features).cache()

// Cluster the data into two classes using KMeans
val numClusters = 2
val model = KMeans.train(points, numClusters, maxIterations)

// Evaluate clustering by computing Within Set Sum of Squared Errors
val WSSSE = model.computeCost(points)
println("Within Set Sum of Squared Errors = " + WSSSE)

val predictions = labeledPoints.map { p =>
  val actual = p.label.toInt
  val prediction = model.predict(p.features).toInt
  (actual, prediction)
}

// Evaluate clustering by computing a confusion matrix
val r = 0 until numClusters
val indices = for (i <- r; j <- r) yield (i,j)
val confusion = Map(indices.map { case (i,j) => (s"$i:$j" -> sc.accumulator(0)) } :_*)

predictions.foreach( p => confusion(s"${p._1}:${p._2}") += 1)

// Display the confusion matrix
println("Confusion matrix:")
r.foreach(i => print("%10s" format i))
println(" <-- predicted class")
r.foreach { i => 
  r.foreach { j =>
    print("%10s" format confusion.getOrElse(s"$i:$j", 0))
  }
  println(s" | $i")
}