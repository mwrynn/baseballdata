#!/bin/bash

source ../conf/env.conf

curl http://www.retrosheet.org/Rosters.zip > ${ORIGINAL_DIR}/roster/Rosters.zip
unzip -o ${ORIGINAL_DIR}/roster/Rosters.zip -d  ${ORIGINAL_DIR}/roster
rm ${ORIGINAL_DIR}/roster/Rosters.zip



