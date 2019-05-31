sqlplus -s ${SOURCE_EXPORT_USER}/${SOURCE_EXPORT_USER}@${SOURCE_INSTANCE} <<EOF
-- In source
drop database link to_rds;

create database link to_rds 
connect to ${TARGET_MASTER_USER}
identified by ${TARGET_MASTER_PASSWORD}
using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${TARGET_HOST})(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=${TARGET_DB})))';
EOF
