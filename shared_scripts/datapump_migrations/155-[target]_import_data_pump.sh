ssh oracle@${TARGET_HOST} ". /home/oracle/.bash_profile;sqlplus ${TARGET_MASTER_USER}/${TARGET_MASTER_PASSWORD}@pdb1 <<EOF
set serveroutput on

DECLARE
hdnl NUMBER;
l_status varchar2(255);
BEGIN
hdnl := DBMS_DATAPUMP.OPEN( operation => 'IMPORT', job_mode => 'SCHEMA', job_name=>null);
DBMS_DATAPUMP.ADD_FILE( handle => hdnl, filename => '${TARGET_EXPORT_FILE}', directory => '${TARGET_DATA_PUMP_DIR_NAME}', filetype => 1);
DBMS_DATAPUMP.METADATA_FILTER(hdnl,'SCHEMA_EXPR','IN (''${TARGET_SCHEMA}'')');
DBMS_DATAPUMP.START_JOB(hdnl);
DBMS_DATAPUMP.WAIT_FOR_JOB(handle=>hdnl,job_state=>l_status);
DBMS_OUTPUT.PUT_LINE('State: '||l_status);
END;
/
EOF"
