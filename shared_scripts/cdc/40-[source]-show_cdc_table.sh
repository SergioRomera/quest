
. ./config.env

ssh oracle@${TARGET_HOST} ". /home/oracle/.bash_profile;sqlplus ${TARGET_CDC_SCHEMA_USER}/${TARGET_CDC_SCHEMA_PASSWORD}@${TARGET_INSTANCE} << EOF

set linesize 200
column ID                          format 99999                       
column DESCRIPTION                 format a20
column SHAREPLEX_SOURCE_TIME       format a20
column SHAREPLEX_SOURCE_USERID     format a20
column SHAREPLEX_SOURCE_OPERATION  format a20
column SHAREPLEX_SOURCE_SCN        format a20
column SHAREPLEX_SOURCE_ROWID      format a20
column SHAREPLEX_SOURCE_TRANS      format a20
column SHAREPLEX_OPERATION_SEQ     format a20
column SHAREPLEX_SOURCE_HOST       format a20
column SHAREPLEX_QUEUENAME         format a20
column SHAREPLEX_SOURCE_ID         format a20
column SHAREPLEX_CHANGE_ID         format a20
column DESCRIPTION2                format a20

select * from cdc;

exit
EOF"
