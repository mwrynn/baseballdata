#!/bin/bash

source ../conf/env.conf

#could improve this whole script - make tmp file that contains all the data, import it all in one she-bang. but this works

roster_dir=${ORIGINAL_DIR}/roster

function load_year {
    #echo $1
    local year_dir=$1
    #echo $year_dir
    local year=$(echo ${year_dir} | rev | cut -d '/' -f 1 | rev)
    #echo $year_dir
    #echo $year
    for roster_file in $(find ${year_dir} -type f -name '*.ros'); do
	#cat ${roster_file} | awk "BEGIN{FS=\",\";OFS=\",\"}{if (NF>1) {print $year, \$1, \$2, \$3, \$4, \$5, \$6, \$7 }}"
	psql ${PGDATABASE} ${PGUSER} <<EOF
begin;
set search_path to ${PGSCHEMA};
\copy roster_tmp from STDIN csv header null '?'
$(cat ${roster_file} | awk "BEGIN{FS=\",\";OFS=\",\"}{if (NF>1) {print $year, \$1, \$2, \$3, \$4, \$5, \$6, \$7 }}")
\.
end;
\q
EOF
    done
}

psql ${PGDATABASE} ${PGUSER} <<EOF
drop table if exists roster_tmp;
create table roster_tmp as select * from roster where 1=2;
truncate table roster;
EOF

for curr_yr_dir in $(find ${roster_dir} -type d | egrep '[1-2][0-9]*'); do  #this has a y10k bug :(
    load_year "${curr_yr_dir}"
done

psql ${PGDATABASE} ${PGUSER} <<EOF
insert into roster
  select * from roster_tmp;
--  on conflict (year, retrosheet_id, team) do update set
--    last=excluded.last,
--    first=excluded.first,
--    bats=excluded.bats,
--    throws=excluded.throws,
--    team=excluded.team,
--    position=excluded.position;
--delete from roster where (year, retrosheet_id, team) not in (select year, retrosheet_id, team from roster_tmp);
truncate table roster_tmp;
EOF
