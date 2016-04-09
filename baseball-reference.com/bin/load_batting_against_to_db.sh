#!/bin/sh

source ../conf/env.conf

psql -h localhost <<EOF
truncate table baseball.batting_against;
\copy baseball.batting_against from '${CVS_DIR}/batting_against.csv' CSV HEADER
EOF
