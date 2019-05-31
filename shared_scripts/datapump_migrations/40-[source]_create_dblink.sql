-- In source
drop database link to_rds;

create database link to_rds 
connect to &1 
identified by &2
using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=&3)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=&4)))';
--using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=&3)(PORT=1521))(CONNECT_DATA=(SID=&4)))';
