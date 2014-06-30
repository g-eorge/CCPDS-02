# Cloudera Certified Professional Data Scientist 
## Challenge 2 - Anomaly Detection

This is the source code for my submission. In order to run the tools, the data files (not included) need to be placed in the data directory.

In general, with the exception of part three, each sub-question has a shell script that can be used to produce the solution files. For example `part1a.sh`. Intermediate data is created in `solution/.tmp`.

### Data files

The data files that are provided as part of the challenge need to be placed in the data directory (`PCDR2011.ZIP`, `PNTDUMP.ZIP` and `REVIEW.ZIP`). There are scripts in the `0-exploring` directory for extracting and processing these files.

### Requirements

I used Mac OS X to develop and test all of the scripts. A Hadoop MapReduce and Hive environment is required to extract and transform the patient data, I used Amazon EMR for this. A recent JDK is required to build the Hadoop job in `tools/medicare`. A Spark 1.x cluster is required for part three. Other scripts depend on R or Python.

### Challenge Instructions

See `Challenge Instructions.pdf` for the original questions to be answered and other challenge information.

### Solution Abstract

See `Solution Abstract.pdf` for more details on my solution.