#!/bin/bash

source ../conf/env.conf

curl http://www.retrosheet.org/parkcode.txt > ${ORIGINAL_DIR}/parkcode.csv
