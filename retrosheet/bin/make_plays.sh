#!/bin/sh

source ../conf/env.conf

yr=$1

#can end up with a file with dup rows if we don't delete existing file first
rm -f ${PROCESSED_DIR}/plays$yr.csv

for file in $(ls ${ORIGINAL_DIR}/event/$yr*.E??); do 
  gawk -f plays.awk $file >> ${PROCESSED_DIR}/plays$yr.csv
done
