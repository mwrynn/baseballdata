#!/bin/sh
csvdir=csv
year=2013
./dl_stats.sh $csvdir/$1
cat $csvdir/$1.csv | ./process.sh $year > $csvdir/$1_proc.csv #replace with year from date
rm csv/$1.csv
mv csv/$1_proc.csv csv/$1.csv
