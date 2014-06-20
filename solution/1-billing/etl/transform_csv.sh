#!/bin/bash

# Make the CSV files smaller and easier to work with
# Depends: csvkit (http://csvkit.readthedocs.org), sed

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

input=( "Medicare_Provider_Charge_Outpatient_APC30_CY2011_v2.csv" "Medicare_Provider_Charge_Inpatient_DRG100_FY2011.csv" )

for file in "${input[@]}"; do
	# Collect the columns we care about
	csvcut -c 1,2,5,6,8,9,10,11 $DATA/summary/csv/$file > $LOCALTMP/$file
done

# Merge the DRG and APC into one CSV file
csvstack -g APC,DRG -n Type "$LOCALTMP/${input[0]}" "$LOCALTMP/${input[1]}" > $LOCALTMP/provider_charge.tmp

# Clean and rename the columns, split the IPC-9 code and description into new columns
$SED -e '1s/[()]//g' \
	-e '1s/[[:space:]]+/_/g' \
	-e '1s/Hospital_Referral_Region_HRR_Description/HRR/g' \
	-e '1s/Type,APC/Type,ICD9,Procedure/p' \
	-e 's/^(DRG|APC),([0-9]+) \- (.*)$/\1,\2,\3/p' \
	-e 's/^(DRG|APC),"([0-9]+) \- (.+)",(.*)$/\1,\2,"\3",\4/p' \
	$LOCALTMP/provider_charge.tmp > $LOCALTMP/provider_charge.csv

# Convert CSV to TSV
cat $LOCALTMP/provider_charge.csv | $CURRENT_DIR/csv2tsv.py	> $LOCALTMP/provider_charge.txt

# Make a copy with no header
tail -n+2 $LOCALTMP/provider_charge.txt > $LOCALTMP/provider_charge_noheader.txt

# Check the same number of lines are output as in the input
wc -l $LOCALTMP/provider_charge.tmp
wc -l $LOCALTMP/provider_charge.csv
wc -l $LOCALTMP/provider_charge.txt

# Clean up
rm $LOCALTMP/provider_charge.tmp