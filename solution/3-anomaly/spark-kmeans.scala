// Scala script to be run in the Spark shell via :load /path/to/file.scala

object Clusterer extends Serializable {
  import org.apache.spark.mllib.regression.LabeledPoint
  import org.apache.spark.mllib.clustering.KMeans
  import org.apache.spark.mllib.linalg.Vectors
  import org.apache.spark.mllib.util.MLUtils._
  import org.apache.spark.Accumulator
  import org.apache.spark.rdd.RDD
  import scala.collection.mutable.{Map => MutableMap}
  import java.io._

  // Convert a row to a vector removing the patient_id and label fields
  def vector(row: Array[String]) = {
    val label = row(4).toDouble
    // val fields = row.tail.slice(0,3) ++ row.tail.slice(4,row.length)
    val fields = row.slice(5, row.length)
    new LabeledPoint(label, Vectors.dense(fields.map(_.toDouble)))
  }

  // Display the confusion matrix
  def displayConfusion(k: Int, confusion: Map[String, Accumulator[Int]]) {
    println("Confusion matrix:")
    val r = 0 until k
    r.foreach(i => print("%10s" format i))
    println(" <-- predicted class")
    r.foreach { i => 
      var l = List[Int]()
      r.foreach { j =>
        l = confusion.get(s"$i:$j").map(a => a.value).getOrElse(0) +: l
      }
      if (l.exists(_ > 0)) {
        l.reverse.foreach { x =>
          print("%10s" format x)
        }
        println(s" | $i")
      }
    }
  }

  // Evaluate clustering by computing a confusion matrix
  def confusion(k: Int, predictions: RDD[(Int,Int)]) = {
    val r = 0 until k
    val indices = for (i <- r; j <- r) yield (i,j)
    val conf = Map(indices.map { case (i,j) => (s"$i:$j" -> sc.accumulator(0)) } :_*)
    predictions.foreach( p => conf(s"${p._1}:${p._2}") += 1)
    conf
  }

  // Dump the cluster scores to csv
  def csvScores(file: String, scores: List[(Int,Double,Double)]) {
    val pw = new PrintWriter(new File(file))
    pw.write("k,wssse,purity\n")
    scores.foreach { s => 
      pw.write(s"${s.productIterator.toList.mkString(",")}\n")
    }
    pw.close
  }

  // Dump the clusters with the majority of labels to csv
  def csvReviewClusters(file: String, clusters: Iterator[(Int,Int,Int,Int)]) {
    val pw = new PrintWriter(new File(file))
    pw.write("cid,label,count,total\n")
    clusters.foreach { s => 
      pw.write(s"${s.productIterator.toList.mkString(",")}\n")
    }
    pw.close
  }

  // Dump the confusion matrix to csv
  def csvConfusion(file: String, k: Int, confusion: Map[String, Accumulator[Int]]) {
    val pw = new PrintWriter(new File(file))
    val r = 0 until k
    pw.write("label")
    r.foreach { prediction => pw.write(s",c$prediction") }
    pw.write("\n")
    r.foreach { i =>
      var l = List[Int]()
      r.foreach { j =>
        l = confusion.get(s"$i:$j").map(a => a.value).getOrElse(0) +: l
      }
      if (l.exists(_ > 0)) {
        pw.write(s"$i")
        l.reverse.foreach { x =>
          pw.write("," + x)
        }
        pw.write("\n")
      }
    }
    pw.close
  }

  // Get a list of actual labels for each predicted cluster
  def clusters(predictions: RDD[(Int,Int)]) =
    predictions.map(x => (x._2, x._1)).groupByKey()

  // Find the class that appears the most in each cluster
  def majorityClass(clusters: RDD[(Int,Iterable[Int])]) = {
    clusters.map { case(k,v) =>
      val labelCounts = v.toList.distinct.map(l => (l, v.count(_ == l)))
      labelCounts.maxBy(x => x._2)
    }
  }

  // Find the clusters that have the majority of points labelled with label
  def reviewClusters(label: Int, predictions: RDD[(Int,Int)]) = {
    val c = clusters(predictions)
    c.zip(majorityClass(c)).map(x => (x._1._1, x._2._1, x._2._2, x._1._2.toList.length)).filter(_._2 == label)
  }

  // A simple evaluation of the clustering.
  // Assign each cluster to the class which appears most frequently.
  // Count the number of correctly assigned points divided by the total number of points.
  def purity(k: Int, predictions: RDD[(Int,Int)]) = {
    val N = predictions.count()
    1d / N * majorityClass(clusters(predictions)).map(_._2).sum
  }

  def parse(line: String) = vector(line.split(','))

  def cluster(input: String, output: String) = {
    // Load the data
    val examples = sc.textFile(input)
    val numFolds = 2
    val seed = 7
    val folds = kFold(examples, numFolds, seed)

    0 until numFolds foreach { fold =>

      val train = folds(fold)._1
      val test = folds(fold)._2

      // Parse the data
      val trainLabels = train.map(parse).cache()
      val trainPoints = trainLabels.map(_.features).cache()
      val testLabels = test.map(parse).cache()
      val testPoints = testLabels.map(_.features).cache()

      // Cluster the data into two classes using KMeans
      // val clusters = List(2,4,8,16,32,48,64,128,256)
      // val clusters = List(2)
      // val clusters = 2 to 202 by 10 toList
      // val clusters = 2 to 50 by 2 toList
      // val clusters = 2 to 20 by 1 toList
      val clusters = (2 to 19) ++ (20 to 50 by 2) toList
      val runs = 3

      val scores = clusters.map { numClusters =>
        
        println(s"k=$numClusters, fold=$fold...")

        val model = KMeans.train(trainPoints, numClusters, runs)

        // Evaluate clustering by computing Within Set Sum of Squared Errors
        val WSSSE = model.computeCost(testPoints)
        // println("Within Set Sum of Squared Errors = " + WSSSE)
        
        val labels = testLabels.map(_.label.toInt)
        val points = testLabels.map(_.features)
        val predictions = model.predict(points)
        val labelVsPredicted = labels.zip(predictions)

        val c = confusion(model.k, labelVsPredicted)
        // displayConfusion(model.k, c)
        csvConfusion(s"$output/confusion-k${model.k}-fold$fold.csv", model.k, c)
        csvReviewClusters(s"$output/review-k${model.k}-fold$fold.csv", reviewClusters(1, labelVsPredicted).toLocalIterator)

        // Evaluate clustering by computing the purity
        val pure = purity(model.k, labelVsPredicted)

        // The score for k clusters
        (model.k, WSSSE, pure)
      }

      csvScores(s"$output/cluster-fold$fold.csv", scores)
    }
  }
}

import Clusterer._
val input = "/Users/george/Src/CCP2014-01/data/sample/claim_vector_sample.csv"
val output = "/Users/george/Src/CCP2014-01/data/sample"
println("call> cluster(input, output)")