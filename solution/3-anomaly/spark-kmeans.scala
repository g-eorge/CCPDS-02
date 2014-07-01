// Scala script to be run in the Spark shell via :load /path/to/file.scala

object Clusterer extends Serializable {
  import org.apache.spark.storage.StorageLevel
  import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
  import org.apache.spark.mllib.linalg.Vectors
  import org.apache.spark.Accumulator
  import org.apache.spark.rdd.RDD
  import scala.collection.mutable.{Map => MutableMap}
  import java.io._

  // Convert a row to a vector removing the patient_id and label fields
  def vector(row: Array[String]) = {
    val label = row(4).toInt
    val patientId = row(0)
    // val fields = row.tail.slice(0,3) ++ row.tail.slice(4,row.length) // Consider the patient details and the procedures claimed
    val fields = row.slice(5, row.length) // Only consider the procedures claimed
    (label, Vectors.dense(fields.map(_.toDouble)), patientId)
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
  def csvScores(scores: List[(Int,Double,Double)]) = {
    val s = new StringBuilder()
    s.append("k,wssse,purity\n")
    scores.foreach { score => 
      s.append(s"${score.productIterator.toList.mkString(",")}\n")
    }
    s.split('\n').toSeq
  }

  // Dump the clusters with the majority of labels to csv
  def csvReviewClusters(clusters: Iterator[(Int,Int,Int,Int)]) = {
    val s = new StringBuilder()
    s.append("cid,label,count,total\n")
    clusters.foreach { c => 
      s.append(s"${c.productIterator.toList.mkString(",")}\n")
    }
    s.split('\n').toSeq
  }

  // Dump the confusion matrix to csv
  def csvConfusion(k: Int, confusion: Map[String, Accumulator[Int]]) = {
    val s = new StringBuilder()
    val r = 0 until k
    s.append("label")
    r.foreach { prediction => s.append(s",c$prediction") }
    s.append("\n")
    r.foreach { i =>
      var l = List[Int]()
      r.foreach { j =>
        l = confusion.get(s"$i:$j").map(a => a.value).getOrElse(0) +: l
      }
      if (l.exists(_ > 0)) {
        s.append(s"$i")
        l.reverse.foreach { x =>
          s.append("," + x)
        }
        s.append("\n")
      }
    }
    s.split('\n').toSeq
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

    // Cache the models so we can choose one later
    val models = MutableMap[String,KMeansModel]()

    // Parse the data
    val vectors = examples.map(parse)
    val labels = vectors.map(_._1).persist(StorageLevel.MEMORY_ONLY_SER)
    val features = vectors.map(_._2).persist(StorageLevel.MEMORY_ONLY_SER)

    // Cluster the data into two classes using KMeans
    // val clusters = List(2,4,8,16,32,48,64,128,256)
    // val clusters = List(8,16,32)
    // val clusters = 2 to 202 by 10 toList
    // val clusters = 2 to 50 by 2 toList
    // val clusters = 2 to 20 by 1 toList
    val clusters = (2 to 19) ++ (20 to 50 by 2) toList
    val runs = 3

    val scores = clusters.map { numClusters =>
      
      println(s"k=$numClusters ...")

      val model = KMeans.train(features, numClusters, runs)
      models.put(s"$numClusters", model)

      // Evaluate clustering by computing Within Set Sum of Squared Errors
      val WSSSE = model.computeCost(features)
      // println("Within Set Sum of Squared Errors = " + WSSSE)
      
      val predictions = model.predict(features).cache()
      val labelVsPredicted = labels.zip(predictions).cache()

      val c = confusion(model.k, labelVsPredicted)
      // displayConfusion(model.k, c)
      sc.makeRDD(csvConfusion(model.k, c), 1).saveAsTextFile(s"$output/confusion-k${model.k}.csv")
      sc.makeRDD(csvReviewClusters(reviewClusters(1, labelVsPredicted).toLocalIterator), 1).saveAsTextFile(s"$output/review-k${model.k}.csv")

      // Evaluate clustering by computing the purity
      val pure = purity(model.k, labelVsPredicted)

      predictions.unpersist()
      labelVsPredicted.unpersist()

      // The score for k clusters
      (model.k, WSSSE, pure)
    }

    features.unpersist()
    labels.unpersist()

    sc.makeRDD(csvScores(scores), 1).saveAsTextFile(s"$output/cluster-scores.csv")
    saveModels(models, output)
    models
  }

  // Extracts the centers from the model as csv
  def csvCentroids(model: KMeansModel) = {
    val vectors = model.clusterCenters
    vectors.map(_.toArray.mkString(",")).toSeq
  }

  // Saves the centers from the models as csv
  def saveCentroids(models: MutableMap[String, KMeansModel], path: String) {
    models.map { case (k,v) => 
      sc.makeRDD(csvCentroids(v), 1).saveAsTextFile(s"$path/centroids-$k")
    }
  }

  // Loads the csv centroids
  def loadCentroids(path: String) = {
    val vectors = sc.textFile(path).map(_.split(",").map(_.toDouble)).toLocalIterator
    vectors.map(Vectors.dense(_)).toArray
  }

  // Saves the KMeansModels as objects so we can load them and use them later
  def saveModels(models: MutableMap[String, KMeansModel], path: String) {
    sc.makeRDD(models.toSeq,1).saveAsObjectFile(s"$path/models")
  }

  // Load the KMeansModels into a map where the key is the value of k used
  def loadModels(path: String) =
    MutableMap[String,KMeansModel](sc.objectFile[(String, KMeansModel)](path).toLocalIterator.toSeq :_*)

  def euclidean(a: Array[Double], b: Array[Double]): Double =
    math.sqrt(a.zip(b).foldLeft(0.0) { (total, next) =>
      total + math.pow(next._1 - next._2, 2) })

  // Classify patient claim vectors
  def classify(input: String, model: KMeansModel) = {
    // Get the patient vectors
    val patients = sc.textFile(input)
    // Only consider unlabeled patients
    val vectors = patients.map(parse).filter(_._1 == 0).cache()
    // Extract patientIds and feature vectors
    val patientIds = vectors.map(_._3)
    val features = vectors.map(_._2).cache()
    // Use the pre-selected model to predict the cluster ids for the unlabeled patients
    val patientClusters = model.predict(features)
    // Combine the patient id with the predicted cluster ids
    val suspicious = patientIds.zip(patientClusters)
    // Add the distance from the patient to the center of the cluster, retain only clusters which 
    // have a majority of anomalies and choose the closest first
    val suspiciousZipFeatures = suspicious.zip(features)
    val classified = suspiciousZipFeatures.map({ case ((patientId, clusterId), vec) => 
      (euclidean(vec.toArray, model.clusterCenters(clusterId).toArray), (patientId, clusterId))
    }).cache()
    classified
  }

  // Take the classified vectors and filter out the ones not assigned to the suspect clusters
  // Sort by distance to the cluster center ascending
  def anomalies(classified: RDD[(Double, (String, Int))], suspectClusters: Set[Int]) = {
    val suspectOnly = classified.filter(x => suspectClusters.contains(x._2._2)).cache()
    val ranked = suspectOnly.sortByKey()
    ranked
  }

  // Output the first n patient IDs from the sorted list for review and save as a csv file
  def csvReview(review: RDD[(Double, (String, Int))], output: String, take: Int) {
    review.cache()
    val patientIds = review.map(_._2._1).take(take)
    sc.makeRDD(patientIds.toSeq, 1).saveAsTextFile(output)
  }
}

import Clusterer._
// val input = "/Users/george/Src/CCP2014-01/data/sample/claim_vector_sample.csv"
// val output = "/Users/george/Src/CCP2014-01/data/sample/cluster"
println("Example usage:")
println("call> val models = cluster(sampleInputPath, evaluationOutputPath)")
println("call> val models = loadModels(evaluationOutputPath)")
println("call> val classified = classify(fullInputPath, selectedModel)")
println("call> val anomalies = anomalies(classified, anomalousClusterIds)")
println("call> csvReview(anomalies, csvPath, takeN)")