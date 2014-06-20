package medicare.etl

import org.apache.crunch.scrunch.PipelineApp

object WordCount extends PipelineApp {

  def countWords(file: String) = {
    read(from.textFile(file))
      .flatMap(_.split("\\W+").filter(!_.isEmpty()))
      .count
  }

  override def run(args: Array[String]) {
    val counts = join(countWords(args(0)), countWords(args(1)))
    write(counts, to.textFile(args(2)))
  }
}