set serveroutput on

DECLARE
hdnl NUMBER;
l_status varchar2(255);
BEGIN
hdnl := DBMS_DATAPUMP.OPEN( operation => 'IMPORT', job_mode => 'SCHEMA', job_name=>null);
DBMS_DATAPUMP.ADD_FILE( handle => hdnl, filename => '&1', directory => '&2', filetype => dbms_datapump.ku$_file_type_dump_file);
DBMS_DATAPUMP.METADATA_FILTER(hdnl,'SCHEMA_EXPR','IN (''&3'')');
DBMS_DATAPUMP.START_JOB(hdnl);
DBMS_DATAPUMP.WAIT_FOR_JOB(handle=>hdnl,job_state=>l_status);
DBMS_OUTPUT.PUT_LINE('State: '||l_status);
END;
/
