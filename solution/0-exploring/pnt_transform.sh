#!/bin/bash

# Transform the XML data using the XmlTransform Crunch job in /tools
# Depends: hadoop client, hive client

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../config/env.sh

#input=$TMP/pnt_sample.xml
input=$TMP/pntxml/PNTSDUMP.XML

# Remove dest dir if it exists
if hadoop fs -test -e $TMP/patients; then
  hadoop fs -rm -r -skipTrash $TMP/patients
fi

hadoop jar $SRC/tools/medicare/target/scala-2.10/medicare-assembly-1.0.0-SNAPSHOT.jar medicare.etl.XmlTransform \
  -Dmapred.output.compress=true \
  -Dmapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec \
  $input  \
  $TMP/patients

# Create claims Hive table  
hive -d loc=$TMP/patients -f $CURRENT_DIR/create_patients.hql

#echo "Cleaning up..."
#rm -rf $tmp