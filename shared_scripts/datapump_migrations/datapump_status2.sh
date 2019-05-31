#!/bin/sh
# Author         : Sergio ROMERA
# Date           : 4/08/2015
# Description    : Datapump report

. ./config.env


dba_user=$1
dba_password=$2
dba_db=$3
dba_job_name=$4

echo ""
echo "**********************************************"
echo "Show oracle datapump jobs"
echo "User     : ${dba_user}"
echo "Database : ${dba_db}"
echo "**********************************************"

sqlplus -s ${dba_user}/${dba_password}@${dba_db} <<EOF

set pagesize 100
set linesize 200
set feedback off

column HOST               format A12
column database           format A10
column owner_name         format A20
column job_name           format A30
column OPERATION          format A20
column JOB_MODE           format A20
column degree             format 9999
column state              format A15
--column attached_sessions  format A9999
--column datapump_sessions  format A9999

set serveroutput on

DECLARE
  ind NUMBER;              -- Loop index
  h1 NUMBER;               -- Data Pump job handle
  percent_done NUMBER;     -- Percentage of job complete
  job_state VARCHAR2(30);  -- To keep track of job state
  js ku\$_JobStatus;        -- The job status from get_status
  ws ku\$_WorkerStatusList; -- Worker status
  sts ku\$_Status;          -- The status object returned by get_status

  cursor c1 is
  SELECT job_name
  FROM dba_datapump_jobs;

  BEGIN
  FOR job_rec in c1
  loop
    h1 := DBMS_DATAPUMP.attach(job_rec.job_name, '${dba_job_name}'); -- job name and owner
    dbms_datapump.get_status(h1,
             dbms_datapump.ku\$_status_job_error +
             dbms_datapump.ku\$_status_job_status +
             dbms_datapump.ku\$_status_wip, 0, job_state, sts);
    js := sts.job_status;
    ws := js.worker_status_list;
    dbms_output.put_line('*********************************************');
    dbms_output.put_line('Job Name         = ' || job_rec.job_name);
    dbms_output.put_line('Percent done     = ' || to_char(js.percent_done));
    dbms_output.put_line('Job mode         = ' || to_char(js.job_mode));
    dbms_output.put_line('State            = ' || to_char(js.state));
    dbms_output.put_line('Degree           = ' || to_char(js.degree));
    dbms_output.put_line('Restarts         - ' || js.restart_count);
    ind := ws.first;
    while ind is not null loop
      dbms_output.put_line('-----');
      dbms_output.put_line('worker_number - '||ws(ind).worker_number);
      dbms_output.put_line('process name - '||ws(ind).process_name);
      dbms_output.put_line('name - '||ws(ind).name);
      dbms_output.put_line('object type - '||ws(ind).object_type);
      dbms_output.put_line('state - '||ws(ind).state);
      dbms_output.put_line('completed objects - '||ws(ind).completed_objects);
      dbms_output.put_line('total objects - '||ws(ind).total_objects);
      dbms_output.put_line('completed rows - '||ws(ind).completed_rows);
      dbms_output.put_line('percent done - '||ws(ind).percent_done);
      dbms_output.put_line('degree - '||ws(ind).degree);
      ind := ws.next(ind);
    end loop;
    DBMS_DATAPUMP.detach(h1);
    end loop;
  
end;
/

exit;
EOF

echo ""
