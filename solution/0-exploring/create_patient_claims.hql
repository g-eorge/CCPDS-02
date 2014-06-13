DROP TABLE patient_claims;
CREATE TABLE patient_claims
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
AS SELECT
  claims.patient_id, 
  patients.age, 
  patients.gndr, 
  patients.inc, 
  claims.claim_date, 
  claims.procedure_code,
  CASE WHEN flagged.label=1 THEN 1 ELSE 0 END AS label
FROM claims LEFT OUTER JOIN patients 
  ON claims.patient_id=patients.patient_id
LEFT OUTER JOIN flagged
  ON flagged.patient_id=patients.patient_id;