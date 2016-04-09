#!/bin/sh

source ../conf/env.conf

year=$2
./dl_stats.sh ${CSV_DIR}/$1
cat $csvdir/$1.csv | ./process.sh ${year} > ${CSV_DIR}/$1_proc.csv #replace with year from date
rm ${CSV_DIR}/$1.csv
mv ${CSV_DIR}/$1_proc.csv csv/$1.csv
