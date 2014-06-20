import AssemblyKeys._

assemblySettings

name := "medicare"

version := "1.0.0-SNAPSHOT"

scalaVersion := "2.10.4"

libraryDependencies ++= Seq(
  "org.scalatest" % "scalatest_2.10" % "2.1.3" % "test",
  "ch.qos.logback" % "logback-classic" % "1.1.2",
  "org.apache.hadoop" % "hadoop-client" % "2.4.0" % "provided",
  "org.apache.crunch" % "crunch-core" % "0.10.0-hadoop2",
  "org.apache.crunch" % "crunch-scrunch" % "0.10.0-hadoop2"
    exclude("javax.jms", "jms")
    exclude("com.sun.jdmk", "jmxtools")
    exclude("com.sun.jmx", "jmxri"),
  "org.apache.thrift" % "libthrift" % "0.8.0" % "provided",
  "org.apache.mahout" % "mahout-core" % "0.9" % "provided"
)

scalacOptions += "-feature"

scalacOptions += "-deprecation"

scalacOptions in Test += "-language:reflectiveCalls"

javacOptions ++= Seq("-source", "1.6", "-target", "1.6")

resolvers += "Cloudera" at "https://repository.cloudera.com/artifactory/cloudera-repos/"

resolvers += "Maven Central" at "http://repo1.maven.org/maven2"

mergeStrategy in assembly <<= (mergeStrategy in assembly) { (old) =>
  {
    case PathList(xs @ _*) if xs.contains("slf4j-api") => MergeStrategy.first
    case PathList(xs @ _*) if xs.contains("slf4j") => MergeStrategy.first
    case PathList(xs @ _*) if xs.contains("jackson") => MergeStrategy.first
    case PathList(xs @ _*) if xs.contains("hawtjni") => MergeStrategy.first
    case PathList(xs @ _*) if xs.contains("jansi") => MergeStrategy.last
    case PathList(xs @ _*) if xs.contains("osx") => MergeStrategy.discard
    case PathList(xs @ _*) if xs.contains("windows32") => MergeStrategy.discard
    case PathList(xs @ _*) if xs.contains("windows64") => MergeStrategy.discard
    case x => old(x)
  }
}