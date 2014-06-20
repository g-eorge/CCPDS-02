DROP TABLE training_set;
CREATE TABLE training_set
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
AS SELECT *
FROM (
  SELECT * 
  FROM patient_claim_vectors TABLESAMPLE(10 percent) unlabelled
  WHERE label=0 LIMIT 40000
UNION ALL
  SELECT * 
  FROM patient_claim_vectors TABLESAMPLE(20 percent) labelled
  WHERE label=1 LIMIT 8000
) sample;