#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

$CURRENT_DIR/part1a.R