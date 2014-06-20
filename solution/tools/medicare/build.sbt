import AssemblyKeys._

assemblySettings

name := "ccp-medicare"

version := "1.0.0-SNAPSHOT"

scalaVersion := "2.10.4"

libraryDependencies ++= Seq(
  "org.scalatest" % "scalatest_2.10" % "2.1.3" % "test",
  "ch.qos.logback" % "logback-classic" % "1.1.2",
  "org.apache.hadoop" % "hadoop-client" % "2.0.0-cdh4.4.0" % "provided",
  "org.slf4j" % "slf4j-api" % "1.7.5",
  "org.slf4j" % "slf4j-jcl" % "1.7.5",
  "com.google.guava" % "guava" % "16.0",
  "org.apache.crunch" % "crunch-scrunch_2.10" % "0.8.2+48-cdh4.6.0"
    exclude("javax.jms", "jms") 
    exclude("com.sun.jdmk", "jmxtools") 
    exclude("com.sun.jmx", "jmxri")
)

scalacOptions += "-feature"

scalacOptions += "-deprecation"

scalacOptions in Test += "-language:reflectiveCalls"

javacOptions ++= Seq("-source", "1.6", "-target", "1.6")

resolvers += "Cloudera" at "https://repository.cloudera.com/artifactory/cloudera-repos/"

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