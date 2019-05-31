sqlplus quest_perf/perf@pdb1 <<EOF
create table test (id number);
insert into test values (1);
commit;
EOF
