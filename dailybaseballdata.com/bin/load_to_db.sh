#!/bin/sh

source ../conf/env.conf

psql -h localhost <<EOF
DELETE FROM baseball.player_stats WHERE game_date='$1';
\copy baseball.player_stats from '${CSV_DIR}/$1.csv' CSV
\q
EOF
