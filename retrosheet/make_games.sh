#!/bin/sh

yr=$1

#can end up with a file with dup rows if we don't delete existing file first
rm -f data/processed/games$yr.csv

for file in $(ls data/original/event/$yr*.E??); do gawk -f games.awk ${file} >> data/processed/games$yr.csv; done
