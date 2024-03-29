#!/bin/bash

emr=/usr/local/emr-cli/elastic-mapreduce

$emr --create --alive --name "Hive cluster" \
  --num-instances 5 --instance-type m1.large \
  --ami-version 3.1.0 --hive-interactive