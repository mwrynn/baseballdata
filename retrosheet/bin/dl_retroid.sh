#!/bin/bash

source ../conf/env.conf

curl http://www.retrosheet.org/retroID.htm | awk '/^\s*$/ {next;} ; $0 ~ /<\/pre>/{pre=0} ; {if (pre==1) {print $0}} ; $0 ~ /<pre>/{pre=1}'  > ${ORIGINAL_DIR}/retroid.csv
