sqlplus test/test@pdb1 <<EOF
insert into test values (1);
commit;
EOF
