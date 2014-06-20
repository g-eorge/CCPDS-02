DROP TABLE procedures;
CREATE TABLE procedures
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
AS SELECT
  type, 
  icd9, 
  procedure,
  avg(charges) AS avg_charge,
  variance(charges) AS var_charge,
  avg(payments) AS avg_payment,
  variance(payments) AS var_payment,
  sum(service_count) AS total_services
FROM provider_procedures
GROUP BY type, icd9, procedure;