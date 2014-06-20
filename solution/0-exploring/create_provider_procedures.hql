DROP TABLE provider_procedures;
CREATE EXTERNAL TABLE provider_procedures (
  type STRING,
  icd9 STRING,
  procedure STRING,
  provider_id STRING,
  city STRING,
  state STRING,
  region STRING,
  service_count INT,
  charges FLOAT,
  payments FLOAT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '${loc}';