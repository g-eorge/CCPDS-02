DROP TABLE provider_charge;
CREATE EXTERNAL TABLE provider_charge (
  type STRING,
  ipc9 STRING,
  procedure_code STRING,
  provider_id STRING,
  hrr STRING,
  num_procedures INT,
  charges FLOAT,
  payments FLOAT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/tmp/provider_charge';