#!/bin/sh             

source ../conf/env.conf

psql -h localhost <<EOF
truncate table baseball.pvb;
\copy baseball.pvb from '${CSV_DIR}/pvb.csv' CSV HEADER
EOF
