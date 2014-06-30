#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

tmp=$LOCALTMP/provider_charge.txt

if [ ! -e $tmp ]; then
  $CURRENT_DIR/../etl/transform_csv.sh
fi

tail -n+2 $LOCALTMP/provider_charge.txt | $CURRENT_DIR/part1d.py > $CURRENT_DIR/part1d.csv