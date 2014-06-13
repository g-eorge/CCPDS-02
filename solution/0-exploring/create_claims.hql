DROP TABLE claims;
CREATE EXTERNAL TABLE claims (
  claim_date STRING,
  patient_id STRING,
  procedure_code STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '${loc}';