#!/bin/sh             

csvdir=csv                                                                                                                                                                                    
psql -h localhost <<EOF
truncate table baseball.pvb;
\copy baseball.pvb from '$csvdir/pvb.csv' CSV HEADER
EOF
