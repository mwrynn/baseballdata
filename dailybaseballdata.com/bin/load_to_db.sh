#!/bin/sh

csvdir=csv
psql -h localhost <<EOF
DELETE FROM baseball.player_stats WHERE game_date='$1';
\copy baseball.player_stats from '$csvdir/$1.csv' CSV
\q
EOF
