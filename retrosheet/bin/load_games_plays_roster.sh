#!/bin/sh

source ../conf/env.conf

yr=$1
dir=${PROCESSED_DIR}

psql <<EOF
set search_path to retrosheet;

\copy game from '$dir/games$yr.csv' csv
\copy play from '$dir/plays$yr.csv' csv
\copy roster from '$dir/roster$yr.csv' csv
\q
EOF
