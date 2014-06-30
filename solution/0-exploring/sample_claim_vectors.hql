DROP TABLE training_set;
CREATE TABLE training_set
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
AS SELECT *
FROM (
  SELECT * 
  FROM patient_claim_vectors TABLESAMPLE(0.1 percent) unlabelled
  WHERE label=0 LIMIT 100000
UNION ALL
  SELECT * 
  FROM patient_claim_vectors labelled
  WHERE label=1 LIMIT 50000
) sample;