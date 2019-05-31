--Not in AWS: only in premise
--drop directory data_pump_dir_sample;
--create directory data_pump_dir_sample as '&2';

WHENEVER SQLERROR EXIT SQL.SQLCODE

drop user &1 cascade;
create user &1 identified by &1;
--grant create session, resource to &1;
--alter user &1 quota 1000M on users;
grant dba to &1;
alter user &1 quota unlimited on users;

