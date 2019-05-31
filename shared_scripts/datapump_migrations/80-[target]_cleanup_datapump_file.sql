column FILENAME format a40

select * from table(RDSADMIN.RDS_FILE_UTIL.LISTDIR('&1')) order by mtime;
exec utl_file.fremove('DATA_PUMP_DIR','&2');
select * from table(RDSADMIN.RDS_FILE_UTIL.LISTDIR('&1')) order by mtime;
