#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

tmp=$LOCALTMP/provider_charge.csv

if [ ! -e $tmp ]; then
  $CURRENT_DIR/../etl/transform_csv.sh
fi

$CURRENT_DIR/part1a.R