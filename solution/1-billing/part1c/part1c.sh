#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

tail -n+2 $LOCALTMP/provider_charge.tsv | $CURRENT_DIR/part1c.py > $CURRENT_DIR/part1c.csv