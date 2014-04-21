package ccp.medicare

import org.apache.crunch.scrunch.{Writables, PipelineApp}
import org.apache.crunch.io.From
import mapreduce.format.XmlInputFormat
import scala.xml.XML

object XmlTransform extends PipelineApp {

  def source(file: String) = {
    val src = From.formattedFile(file, classOf[XmlInputFormat], Writables.longs, Writables.strings)
    src.inputConf("xmlinput.start", "<rows>")
    src.inputConf("xmlinput.end", "</rows>")
    src
  }

  def parseRow(row: String) = Map(
    XML.loadString(row) \ "field" map { f =>
      ((f \ "@name").text, f.text.trim.replace("&lt;","<").replace("&gt;",">"))
    } :_*
  )

  def getVal(key: String, row: Map[String,String]) = row.get(key).getOrElse("""\N""")

  def transform(file: String) = {
    read(source(file)).flatMap {
      (key, value) =>
        val row = parseRow(value)
        List(getVal("id",row), getVal("age",row), getVal("gndr",row), getVal("inc",row)).mkString("\t") :: Nil
    }
  }

  override def run(args: Array[String]) {
    val rows = transform(args(0))
    write(rows, to.textFile(args(1)))
  }
}