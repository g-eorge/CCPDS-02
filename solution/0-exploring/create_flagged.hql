DROP TABLE flagged;
CREATE EXTERNAL TABLE flagged (
  patient_id STRING,
  label int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/tmp/flagged';