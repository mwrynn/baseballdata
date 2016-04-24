#!/bin/bash

source ../conf/env.conf

last_dir=$(pwd)

cd ${SQL_DIR}

psql ${PGDATABASE} ${PGUSER} -f $1
