drop user &1 cascade;
create user &1 identified by &1;
grant dba to &1;
drop directory data_pump_dir_sample;
create directory data_pump_dir_sample as '/u01/app/oracle/product/12.1.0.2/dbhome_1/datapump';

--grant create session, create table, create database link to export_user;
--alter user export_user quota 100M on users;

--create directory data_pump_dir as '/tmp';
--grant read, write on directory data_pump_dir to export_user;
--grant select_catalog_role to export_user;
--grant execute on dbms_datapump to export_user;
--grant execute on dbms_file_transfer to export_user;


