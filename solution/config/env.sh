#!/bin/bash

# Set up some environment variables, if these don't match your system then you will need to change them here
# Usage: $ source env.sh

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

# Linux
SED="sed -rn"

# OS X
if [ $(uname) == "Darwin" ]; then
  SED="sed -En"
fi

export BASE=$(cd $CURRENT_DIR && pwd | $SED -e 's/\/solution.*$//p')
export SRC="$BASE/solution"
export DATA="$BASE/data"

# Stream jar location
export STREAMJAR="/usr/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.4.0.jar"

# Tell Hive where to find our serdes
#export SERDES=$CURRENT_DIR/../lib/json-serde.jar

# HDFS work directory
export TMP="/tmp"

# Local tmp directory
export LOCALTMP="$SRC/.tmp"
mkdir -p $LOCALTMP