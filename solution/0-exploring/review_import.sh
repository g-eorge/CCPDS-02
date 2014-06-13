#!/bin/bash

# Load the review data in to HDFS
# Depends: hadoop client, hive client, unzip

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../config/env.sh

tmp=$LOCALTMP/flagged

# Unzip the files to a local tmp dir
if [ ! -d $tmp ]; then
  echo "Unzipping..."
  rm -rf $tmp
  mkdir -p $tmp
  unzip -d $tmp $DATA/REVIEW.zip
fi

# Remove dest dir if it exists
if hadoop fs -test -e $TMP/flagged; then
  hadoop fs -rm -r -skipTrash $TMP/flagged
fi
hadoop fs -mkdir -p $TMP/flagged

# Send the review ids to hdfs adding a label column with 1 as the value
$SED -e 's/^(.+)$/\1	1/p' $tmp/REVIEW.txt | hadoop fs -put - $TMP/flagged/flagged.txt

# Create flagged Hive table
hive -d loc=$TMP/flagged -f $CURRENT_DIR/create_flagged.hql