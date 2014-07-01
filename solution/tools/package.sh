#!/bin/bash

CURRENT_DIR=$(dirname $0)
CURRENT_DIR=$( cd $CURRENT_DIR && pwd )

name=CCPDS02-GAGNELLI
tmp=/tmp

rm -rf $tmp/$name
mkdir -p $tmp/$name
cd $CURRENT_DIR/../..

git archive master | tar -x -C $tmp/$name

solution="$tmp/$name/solution"

cp $solution/1-billing/part1a/part1a.csv $solution
cp $solution/1-billing/part1b/part1b.csv $solution
cp $solution/1-billing/part1c/part1c.csv $solution
cp $solution/1-billing/part1d/part1d.csv $solution

cp $solution/2-similarity/part2a/part2a.csv $solution
cp $solution/2-similarity/part2b/part2b.csv $solution

cp $solution/3-anomaly/part3.csv $solution

cd $tmp
tar -cjvf $name.tar.bz2 $name
mv $name.tar.bz2 ~/Desktop
rm -rf $name