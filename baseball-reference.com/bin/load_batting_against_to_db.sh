#!/bin/sh                                                                                                                                                                                                 
psql -h localhost <<EOF
truncate table baseball.batting_against;
\copy baseball.batting_against from 'batting_against.csv' CSV HEADER
EOF
