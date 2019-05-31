sqlplus -s ${SOURCE_EXPORT_USER}/${SOURCE_EXPORT_USER}@${SOURCE_INSTANCE} <<EOF
set serveroutput on

BEGIN
DBMS_FILE_TRANSFER.PUT_FILE(
source_directory_object => '${SOURCE_DATA_PUMP_DIR_NAME}',
source_file_name => '${SOURCE_EXPORT_FILE}',
destination_directory_object => '${TARGET_DATA_PUMP_DIR_NAME}',
destination_file_name => '${TARGET_EXPORT_FILE}',
destination_database => 'to_rds'
);
END;
/
EOF
