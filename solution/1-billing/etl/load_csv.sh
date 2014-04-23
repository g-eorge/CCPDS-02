#!/bin/bash

# Load the CSV in to Hive / Impala

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

# Remove dest dir if it exists
if hadoop fs -test -e $TMP/provider_charge; then
  hadoop fs -rm -r -skipTrash $TMP/provider_charge
fi
hadoop fs -mkdir -p $TMP/provider_charge


tail -n+2 $LOCALTMP/provider_charge.csv | sed -rn -e 's/^(.+),(.+),"(.+)",(.+),(.+),(.+),(.+),(.+)$/\1\t\2\t\3\t\4\t\5\t\6\t\7\t\8/p' \
  -e 's/^(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)$/\1\t\2\t\3\t\4\t\5\t\6\t\7\t\8/p' | hadoop fs -put - $TMP/provider_charge/provider_charge.txt

hive -f $CURRENT_DIR/create_provider_charge.hql