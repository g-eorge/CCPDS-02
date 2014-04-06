#!/bin/bash

# Set up some environment variables, if these don't match your system then you will need to change them here
# Usage: $ source env.sh

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

export BASE=$(cd $CURRENT_DIR/../../ && pwd)
export SRC=$(cd $CURRENT_DIR/../ && pwd)
export DATA=$(cd $CURRENT_DIR/../../data && pwd)

# Stream jar location
export STREAMJAR="/usr/lib/hadoop-mapreduce/hadoop-streaming.jar"

# Tell Hive where to find our serdes
#export SERDES=$CURRENT_DIR/../lib/json-serde.jar

# HDFS work directory
export TMP="/tmp"

# Local tmp directory
export LOCALTMP="$SRC/.tmp"
mkdir -p $LOCALTMP