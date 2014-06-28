#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

data=$DATA/claim_vector_sample.csv
names=$(< $DATA/claim_vector_field_names.csv)
output=$LOCALTMP/claim_vector_sample.csv

echo $names > $output

./add_counts.py < $data >> $output