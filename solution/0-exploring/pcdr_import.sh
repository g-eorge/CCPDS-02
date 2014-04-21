#!/bin/bash

# Load the PCDR claim data in to HDFS
# Depends: hadoop client, hive client, unzip, tr, sed, cat

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../config/env.sh

tmp=$LOCALTMP/pcdr

# Unzip the files to a local tmp dir
if [ ! -d $tmp ]; then
  echo "Unzipping..."
  rm -rf $tmp
  mkdir -p $tmp
  unzip -d $tmp $DATA/PCDR2011.zip
fi

# Remove dest dir if it exists
if hadoop fs -test -e $TMP/claims; then
  hadoop fs -rm -r -skipTrash $TMP/claims
fi
hadoop fs -mkdir -p $TMP/claims

# Transform the ASCII delimited text to TSV as we copy it to HDFS so it's easier to explore
echo "Transforming in to HDFS..."
for file in $tmp/*.ADT; do
  name=$(basename $file | sed -e "s/ADT/txt/")
  echo "$file => hdfs://$TMP/claims/$name"
  cat "$file" | tr '\011\037\036' '\000\t\n' | sed -e 's/[ \t]*$//' | hadoop fs -put - "$TMP/claims/$name"
done

# Create claims Hive table
hive -f $CURRENT_DIR/create_claims.hql

#echo "Cleaning up..."
#rm -rf $tmp