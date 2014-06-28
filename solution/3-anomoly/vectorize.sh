#!/bin/bash

src="s3n://ccp-medicare/patient_claims"
dest="s3n://ccp-medicare/patient_claim_vectors"
mapper="s3n://ccp-medicare/mr/features_map.py"
reducer="s3n://ccp-medicare/mr/features_reduce.py"
streamjar="/home/hadoop/contrib/streaming/hadoop-streaming.jar"

if hadoop fs -test -e $dest; then
  hadoop fs -rm -r $dest
fi

hadoop jar $streamjar \
  -files $mapper,$reducer \
  -input $src \
  -output $dest \
  -mapper $(basename $mapper) \
  -reducer $(basename $reducer)