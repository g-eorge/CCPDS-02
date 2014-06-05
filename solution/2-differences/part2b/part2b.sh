#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

source $CURRENT_DIR/../../config/env.sh

data=$CURRENT_DIR/vector_regions.txt

function count_cols() {
  echo $(awk 'BEGIN {FS="\t"}; { print NF }' $1 | tail -n 1)
}

if [ ! -e $data ]; then
  echo "Vectorizing regions..."
  tail -n+2 $LOCALTMP/provider_charge.txt | $CURRENT_DIR/vectorize_regions.py > $data
  echo "$(count_cols $data) columns."
  echo
fi

numcols=$(count_cols $data)

$CURRENT_DIR/../similarity.scala $numcols scale < $data | $SED -e 's/(.+) - (.+)/\2,\1/p' > $CURRENT_DIR/part2b.csv