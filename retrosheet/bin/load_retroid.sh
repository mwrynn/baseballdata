#!/bin/bash

source ../conf/env.conf

dir=${ORIGINAL_DIR}

psql ${PGDATABASE} ${PGUSER} <<EOF
begin;
set search_path to ${PGSCHEMA};
drop table if exists retroid_tmp;
create table retroid_tmp as select * from retroid where 1=2;
\copy retroid_tmp from '$dir/retroid.csv' csv header
insert into retroid
  select * from retroid_tmp 
  on conflict (id) do update set
    last=excluded.last,
    first=excluded.first,
    debut=excluded.debut;
delete from id where parkid not in (select id from retroid_tmp);
drop table retroid_tmp;
end;
\q
EOF
