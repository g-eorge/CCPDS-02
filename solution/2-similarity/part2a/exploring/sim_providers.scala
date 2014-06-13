#!/bin/sh
JAVA_OPTS="-Xms512M -Xmx4096M -Xss1M"
exec scala -savecompiled "$0" "$@"
!#

import scala.io.Source
import scala.collection.mutable.Map
import scala.util.Sorting

val pVecs: Map[String,List[Double]] = Map()

for (line <- Source.stdin.getLines) {
  val parts = line.split("\t").toList
  pVecs += (parts.head -> parts.tail.map(_.toDouble))
}

rank(similarity(pVecs)).foreach(x => println(s"${x._1}\t${x._2}"))

def similarity(m: Map[String,List[Double]]) = {
  var done = 0
  val sim: Map[String,Double] = Map()
  for ((kx,vx) <- m; (ky,vy) <- m) {
    val key = s"$kx:$ky"
    if (kx != ky && !sim.contains(key) && !sim.contains(s"$ky:$kx")) {
      sim += (key -> euclidean(vx,vy))
      done = done + 1
    }
    progress(m.size, done)
  }
  sim
}

def euclidean(a: Iterable[Double], b: Iterable[Double]): Double =
  math.sqrt(a.zip(b).foldLeft(0.0) { (total, next) =>
    total + math.pow(next._1 - next._2, 2) })

def rank(sim: Iterable[(String,Double)]) = {
  val a = sim.toArray
  Sorting.quickSort(a)(Ordering.by[(String, Double), Double](_._2))
  a
}

def progress(size: Int, done: Int) {
  val s = ((size * size) - size) / 2
  if (done == 0) {
    System.err.println(s"$s to process.")
  }
  System.err.print(s"${(done/s)*100}%\r")
}