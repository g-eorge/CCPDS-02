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
  procedures.avg_charge,
  procedures.var_charge,
  procedures.avg_payment,
  procedures.var_payment,
  procedures.total_services,
  CASE WHEN flagged.label=1 THEN 1 ELSE 0 END AS label
FROM claims 
LEFT OUTER JOIN patients 
  ON claims.patient_id=patients.patient_id
LEFT OUTER JOIN procedures
  ON claims.procedure_code=procedures.icd9
LEFT OUTER JOIN flagged
  ON flagged.patient_id=patients.patient_id;