#!/bin/sh

#expects YYYYMMDD date                                                                                                                                                                                    
csvdir=csv
lookupdate=$1
lookupdate=${lookupdate:-$(date "+%Y%m%d")}
urldate=$(date -j -f "%Y%m%d" "${lookupdate}" "+%m%d") 
urldate=$(echo $urldate | sed 's/^0//g')
curl http://dailybaseballdata.com/dbd/bvp/$urldate.txt > $csvdir/pvb.csv
