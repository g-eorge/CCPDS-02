#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

tail -n+2 $CURRENT_DIR/test_input.tsv | $CURRENT_DIR/part1d.py