#!/bin/sh

source ../conf/env.conf

yr=$1

#can end up with a file with dup rows if we don't delete existing file first
rm -f ${PROCESSED_DIR}/roster$yr.csv

yrloop=$yr
yrout=$yr

for file in $(ls ${ORIGINAL_DIR}/roster/*${yrloop}.ROS | grep -v MASTDEB.ROS); do
  #if yr not specified, parse it from curr file name because roster.awk requires it
  if [ -z $1 ]; then
    yr=$(basename $file | cut -c 4-7);
  fi
  gawk -f roster.awk -v year=$yr $file >> ${PROCESSED_DIR}/roster${yrout}.csv
done
