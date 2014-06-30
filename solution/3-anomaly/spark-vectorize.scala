// Scala script to be run in the Spark shell via :load /path/to/file.scala

object Vectorizer extends Serializable {
  
  import scala.collection.SortedSet

  val ages = Map(List(("\\N" -> 0),
                 ("<65" -> 1),
                 ("65-74" -> 2),
                 ("75-84" -> 3),
                 ("85+" -> 4)) :_*)

  val genders = Map(("M" -> 1), ("F" -> 2))

  val incomes = Map(List(("\\N" -> 0),
                   ("NULL" -> 0),
                   ("<16000" -> 1),
                   ("16000-23999" -> 2),
                   ("24000-31999" -> 3),
                   ("32000-47999" -> 4),
                   ("48000+" -> 5)) :_*)

  val names = Map(List(("patient_id" -> 0),
                  ("age" -> 1),
                  ("gndr" -> 2),
                  ("inc" -> 3),
                  ("claim_date" -> 4),
                  ("procedure_code" -> 5),
                  ("avg_charge" -> 6),
                  ("var_charge" -> 7),
                  ("avg_payment" -> 8),
                  ("var_payment" -> 9),
                  ("total_services" -> 10),
                  ("label" -> 11)) :_*)

  // From a query over all claims
  val uniqueProcedures = SortedSet("0012","0013","0015","0019","0020","0073","0074","0078","0096","0203","0204","0206","0207","0209","0265","0267","0269","0270","0336","0368","0369","0377","039","057","0604","0605","0606","0607","0608","064","065","066","069","0690","0692","0698","074","101","149","176","177","178","189","190","191","192","193","194","195","202","203","207","208","238","243","244","246","247","249","251","252","253","254","280","281","282","286","287","291","292","293","300","301","303","305","308","309","310","312","313","314","315","329","330","372","377","378","379","389","390","391","392","394","418","419","439","460","469","470","473","480","481","482","491","536","552","563","602","603","638","640","641","682","683","684","689","690","698","699","811","812","853","870","871","872","885","897","917","918","948")

  def makeKey(fields: List[String]) = {
    List(fields(names("patient_id")),
      ages(fields(names("age"))),
      genders(fields(names("gndr"))),
      incomes(fields(names("inc"))),
      fields(names("label"))).mkString(":")
  }

  def denseClaims(sparseClaims: Iterable[String]) = uniqueProcedures.toList.map(icd9 => sparseClaims.count(_ == icd9))

  def vectorize(input: String, output: String) {
    val data = sc.textFile(input)
    val claimVectors = data map { line =>
      val fields = line.trim.split('\t')
      (makeKey(fields.toList), fields(names("procedure_code")))
    } groupByKey() map { case (key,vals) =>
      val sep = ","
      val claims = denseClaims(vals)
      key.split(":").mkString(sep) + sep + claims.mkString(sep)
    }

    claimVectors.saveAsTextFile(output) 
  }
}

import Vectorizer._
val input = "/Users/george/Src/CCP2014-01/data/sample/patient_claims_sample.txt"
val output = "/Users/george/Src/CCP2014-01/data/sample/spark_claim_vector_sample"
println("call> vectorize(input, output)")