#!/bin/bash

# Load the PCDR claim data in to HDFS
# Depends: hadoop client, hive client, unzip

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../config/env.sh

tmp=$LOCALTMP/pntxml

# Unzip the files to a local tmp dir
if [ ! -d $tmp ]; then
  echo "Unzipping..."
  rm -rf $tmp
  mkdir -p $tmp
  unzip -d $tmp $DATA/PNTDUMP.zip
fi

# Remove dest dir if it exists
if hadoop fs -test -e $TMP/pntxml; then
  hadoop fs -rm -r -skipTrash $TMP/pntxml
fi
hadoop fs -mkdir -p $TMP/pntxml

hadoop fs -put $tmp/*.XML $TMP/pntxml
