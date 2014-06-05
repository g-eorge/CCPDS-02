#!/bin/sh
exec scala -savecompiled "$0" "$@"
!#

import scala.io.Source
import scala.collection.mutable.Map
import scala.util.Sorting


var matrix: Map[String,List[Double]] = Map()
var cols = 392
var featureScaling = false

if (args.length > 0) {
  if (args(0) == "test")
    test()
  else
    cols = args(0).toInt
}

// Turn on feature scaling
if (args.length > 1) {
  if (args(1) == "scale")
    featureScaling = true
}

// Parse the input rows
for (line <- Source.stdin.getLines) {
  val parts = line.split("\t").toList
  matrix += (parts.head -> parts.tail.map { s =>
    try {
      s.toDouble
    } catch {
      case s: java.lang.NumberFormatException => 0.0
    }
  })
}

if (featureScaling) {
  matrix = scale(matrix)
}

// Find the centroid
val centroid = average(matrix)(cols)
// centroid.map(x => log(f"$x%2.2f"))

// Find the distance from each point to the centroid and sort
val sims = rank(similarity(matrix,centroid))
// display(sims)
// endl
summary(sims)

// Output the ids of the 3 least similar points (furthest from the centroid)
val leastSimilar = bottom3(sims)
csv(leastSimilar)

/** Normalize by subtracting the mean */
// def normalize(m: Map[String,List[Double]], centroid: List[Double]) = {
//   val mNorm: Map[String,List[Double]] = Map()
//   for ((id,vec) <- m) {
//     mNorm += id -> vec.zip(centroid).map(x => x._1 - x._2)
//   }
//   mNorm
// }

def getVector(x: (String,Double)) = matrix(x._1)

/** Compute similarity between each vector and the centroid */
def similarity(m: Map[String,List[Double]], centroid: List[Double]) = {
  var done = 0
  val sim: Map[String,Double] = Map()
  for ((id,vec) <- m) {
    sim += (id -> euclidean(vec, centroid))
    done = done + 1
  }
  sim
}

/** Find the max of each column */
def max(m: Map[String,List[Double]]) = {
  val maxes: Array[Double] = Array.ofDim(m.toList.head._2.size)
  for ((id,vec) <- m; (col,i) <- vec.zipWithIndex) {
    if (col > maxes(i)) {
      maxes(i) = col
    }
  }
  maxes
}

/** Scale the feature vectors */
def scale(m: Map[String,List[Double]]) = {
  val scaled: Map[String,List[Double]] = Map()
  if (m.size > 0) {
    val maxes = max(m)
    for ((id,vec) <- m) {
      val scaledVec = vec.zip(maxes).map { x =>
        if (x._2 > 0) x._1 / x._2 else 0
      }
      scaled += id -> scaledVec
    }
  }
  scaled
}

/** Compute the Euclidean distance between two vectors */
def euclidean(a: Iterable[Double], b: Iterable[Double]): Double =
  math.sqrt(a.zip(b).foldLeft(0.0) { (total, next) =>
    total + math.pow(next._1 - next._2, 2) })

/** Sort by similarity */
def rank(sim: Iterable[(String,Double)]) = {
  val a = sim.toArray
  Sorting.quickSort(a)(Ordering.by[(String, Double), Double](_._2))
  a
}

/** Compute the centroid */
def average(matrix: Map[String,List[Double]])(implicit cols: Int) = {
  val centroid = Array.fill(cols-1)(0.0)
  for ( ((id,vec), numrows) <- matrix.toList.zipWithIndex;
        (x,i) <- vec.zipWithIndex ) {
    centroid(i) = updateAvg(x, centroid(i), numrows)
  }
  centroid.toList
}

def updateAvg(newDatum: Double, currentAvg: Double, numDatums: Int) =
  (newDatum + (numDatums * currentAvg)) / (numDatums + 1)

/** Output n most different pairs */
def summary(vec: Iterable[(String,Double)]) = {
  log("Most similar:")
  top3(vec).foreach(x => log(str(x)))
  endl
  log("Least similar:")
  bottom3(vec).foreach(x => log(str(x)))
}

def csv(vec: Iterable[(String,Double)]) =
  vec.foreach(x => println(s"${x._1}"))

def display(vec: Iterable[(String,Double)]) =
  vec.foreach(x => log(str(x)))

def top3(vec: Iterable[(String,Double)]) = vec.slice(0,3).toList
def bottom3(vec: Iterable[(String,Double)]) = vec.slice(vec.size-3,vec.size).toList

def log(s: String) = System.err.println(s)
def endl = log("")

def str(x: (String,Double)) =
  f"${x._1}\t${x._2}%2.2f"

def test() = {
  val cols = 4
  val matrix: Map[String,List[Double]] = Map()
  val v1 = List(0.0,1.0,2.0)
  val v2 = List(0.0,1.0,2.0)
  val v3 = List(0.0,2.0,3.0)
  val v4 = List(2.0,0.0,4.0)
  val v5 = List(2.0,-1.0)
  val v6 = List(-2.0,2.0)
  matrix += ("row1" -> v1)
  matrix += ("row2" -> v2)
  matrix += ("row3" -> v3)
  matrix += ("row4" -> v4)

  val centroid = average(matrix)(cols)
  assert(centroid == List(0.5, 1.0, 2.75))
  assert(euclidean(v1,v2) == 0)
  assert(euclidean(v5,v6) == 5)

  val maxes = max(matrix)
  assert(maxes.length == cols-1)
  assert(maxes(0) == 2.0)
  assert(maxes(1) == 2.0)
  assert(maxes(2) == 4.0)

  val scaled = scale(matrix)
  assert(scaled.size == 4)
  assert(scaled("row1") == List(0.0,0.5,0.5))
  assert(scaled("row2") == List(0.0,0.5,0.5))
  assert(scaled("row3") == List(0.0,1.0,0.75))
  assert(scaled("row4") == List(1.0,0.0,1.0))

  println("Tests passed.")
  System.exit(0)
}