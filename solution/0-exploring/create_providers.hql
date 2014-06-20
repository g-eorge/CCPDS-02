DROP TABLE providers;
CREATE TABLE providers
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
AS SELECT
  provider_id, 
  city, 
  state,
  region
FROM provider_procedures
LOCATION '${loc}';