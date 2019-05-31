set serveroutput on

BEGIN
DBMS_FILE_TRANSFER.PUT_FILE(
source_directory_object => '&1',
source_file_name => '&2',
destination_directory_object => '&3',
destination_file_name => '&4',
destination_database => 'to_rds'
);
END;
/
