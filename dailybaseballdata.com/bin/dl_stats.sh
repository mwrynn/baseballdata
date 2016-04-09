#!/bin/bash

function is_final {
  grep "(final)" $1 > /dev/null
  if [ $? -eq 0 ]; then
    echo 0
  else
    echo 1
  fi
}

#expects YYYYMMDD date
lookupdate=$1
lookupdate=${lookupdate:-$(date "+%Y%m%d")}
urldate=$(date -j -f "%Y%m%d" "${lookupdate}" "+%m%d")

while true; do
  filename=$lookupdate.csv
  echo "filename=$filename"
  url="http://dailybaseballdata.com/cgi-bin/getstats.pl?date=$urldate&out=csv"
  echo ${url}
  curl ${url} > $filename

  if [ $(is_final $filename) -eq 0 ]; then
    break
  else
    #rm $filename 
    #sleep 3600
    break
  fi
done
