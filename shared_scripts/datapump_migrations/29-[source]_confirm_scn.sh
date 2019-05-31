sqlplus -s ${SOURCE_MASTER_USER}/${SOURCE_MASTER_PASSWORD}@pdb1 <<EOF
set headsep off
set pagesize 0
set trimspool on

spool ./current_scn.log
select current_scn from v\$database;
spool off
exit
EOF
