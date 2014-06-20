DROP TABLE procedures;
CREATE EXTERNAL TABLE procedures (
  type STRING,
  icd9 STRING,
  procedure STRING,
  avg_charge FLOAT,
  var_charge FLOAT,
  avg_payment FLOAT,
  var_payment FLOAT,
  total_services INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '${loc}';