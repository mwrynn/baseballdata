#!/bin/sh

#expects YYYYMMDD date

source ../conf/env.conf

lookupdate=$1
lookupdate=${lookupdate:-$(date "+%Y%m%d")}
urldate=$(date -j -f "%Y%m%d" "${lookupdate}" "+%m%d") 
urldate=$(echo $urldate | sed 's/^0//g')
curl http://dailybaseballdata.com/dbd/bvp/$urldate.txt > $${CSV_DIR}/pvb.csv
