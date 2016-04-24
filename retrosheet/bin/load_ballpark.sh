#!/bin/bash

source ../conf/env.conf

dir=${ORIGINAL_DIR}

psql ${PGDATABASE} ${PGUSER} <<EOF
begin;
set search_path to ${PGSCHEMA};
drop table if exists ballpark_tmp;
create table ballpark_tmp as select * from ballpark where 1=2;
\copy ballpark_tmp from '$dir/parkcode.csv' csv header
insert into ballpark
  select * from ballpark_tmp 
  on conflict (parkid) do update set
    name=excluded.name,
    aka=excluded.aka,
    city=excluded.city,
    state=excluded.state,
    startdate=excluded.startdate,
    enddate=excluded.enddate,
    league=excluded.league,
    notes=excluded.notes;
delete from ballpark where parkid not in (select parkid from ballpark_tmp);
drop table ballpark_tmp;
end;
\q
EOF
