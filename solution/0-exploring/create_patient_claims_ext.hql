DROP TABLE patient_claims;
CREATE EXTERNAL TABLE patient_claims (
  patient_id STRING,
  age STRING,
  gndr STRING,
  inc STRING,
  claim_date STRING,
  procedure_code STRING,
  avg_charge FLOAT,
  var_charge FLOAT,
  avg_payment FLOAT,
  var_payment FLOAT,
  total_services INT,
  label INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '${loc}';