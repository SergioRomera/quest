#!/bin/sh
# Author         : Sergio ROMERA
# Date           : 4/08/2015
# Description    : Datapump report

. ./config.env

dba_user=$1
dba_password=$2
dba_db=$3

echo "**********************************************"
echo "Show oracle datapump jobs"
echo "User     : ${dba_user}"
echo "Database : ${dba_db}"
echo "**********************************************"

sqlplus -s ${dba_user}/${dba_password}@${dba_db} <<EOF

set pagesize 100
set linesize 200
set feedback off

column HOST               format A30
column database           format A10
column owner_name         format A20
column job_name           format A30
column OPERATION          format A20
column JOB_MODE           format A20
column degree             format 9999
column state              format A15
--column attached_sessions  format A9999
--column datapump_sessions  format A9999

select (select host_name from v\$instance) as "HOST",
       (select name from v\$database) as "Database",
       owner_name,job_name
       ,substr(operation,1,19) as "OPERATION"
       ,substr(job_mode,1,10)  as "JOB_MODE"
       ,state,degree
from dba_datapump_jobs
where state<>'NOT RUNNING';

exit;
EOF

echo ""
