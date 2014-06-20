#!/bin/bash

bucket="s3n://ccp-medicare"
warehouse="/mnt/hive_0110/warehouse"
hql="$bucket/hql"

# Flagged
hive -d loc=$bucket/flagged -f $hql/create_flagged.hql

# Claims
hive -d loc=$bucket/claims -f $hql/create_claims.hql

# Patients
hive -d loc=$bucket/patients -f $hql/create_patients.hql

# Provider procedures
# Note: Needs solution/.tmp/provider_charge_noheader.txt
hive -d loc=$bucket/provider_procedures -f $hql/create_provider_procedures.hql

# Procedures
if hadoop fs -test -e $bucket/procedures; then
  echo "$bucket/procedures exists."
else
  hive -f $hql/create_procedures.hql
  # Make the table external
  hadoop fs -rmr $bucket/procedures
  hadoop fs -cp $warehouse/procedures $bucket/
fi
hive -d loc=$bucket/procedures -f $hql/create_procedures_ext.hql


# Patient Claims
if hadoop fs -test -e $bucket/patient_claims; then
  echo "$bucket/patient_claims exists."
else
  hive -f $hql/create_patient_claims.hql
  # Make the table external
  hadoop fs -rmr $bucket/patient_claims
  hadoop distcp $warehouse/patient_claims $bucket/
fi
hive -d loc=$bucket/patient_claims -f $hql/create_patient_claims_ext.hql
