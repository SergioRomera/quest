echo "******************************************************************************"
echo "Create Quest Shareplex dedicated tablespace" `date`
echo "******************************************************************************"
sqlplus / as sysdba <<EOF

alter session set container=pdb1;
--DROP TABLESPACE "QUEST_SHAREPLEX" INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
CREATE TABLESPACE "QUEST_SHAREPLEX" DATAFILE '/u01/oradata/cdb1/quest_shareplex.dbf' SIZE 104857600 REUSE;

-- TEST USER
create user test identified by test;
grant connect,resource to test;
alter user test quota unlimited on USERS;

EXIT;
EOF

echo "******************************************************************************"
echo "Quest Shareplex database configuration." `date`
echo "******************************************************************************"
sqlplus / as sysdba <<EOF

--select LOG_MODE, name, SUPPLEMENTAL_LOG_DATA_MIN, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI, SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL from v$database;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY, UNIQUE) COLUMNS;
ALTER SYSTEM SWITCH LOGFILE;
--select LOG_MODE, name, SUPPLEMENTAL_LOG_DATA_MIN, SUPPLEMENTAL_LOG_DATA_PK, SUPPLEMENTAL_LOG_DATA_UI, SUPPLEMENTAL_LOG_DATA_FK, SUPPLEMENTAL_LOG_DATA_ALL from v$database;

create user c##sp_admin identified by sp_admin;
grant dba to c##sp_admin container=ALL;
grant select on sys.user$ to c##sp_admin with grant option container=ALL;
grant select on sys.enc$ to c##sp_admin with grant option container=ALL;

EXIT;
EOF

#mkdir -p /u01/app/quest
rm -fR /u01/app/quest/shareplex9.2/ ; rm -fR /u01/app/quest/vardir/ ; rm -fR /home/oracle/.shareplex/
mkdir -p /u01/app/quest/shareplex9.2/ ; mkdir -p /u01/app/quest/vardir/2100/

cat >> /home/oracle/.bash_profile <<EOF
. /vagrant_scripts/shareplex_functions.sh
EOF

echo "******************************************************************************"
echo "Quest Shareplex installation." `date`
echo "******************************************************************************"
cd /vagrant_software
licence_key=`cat /vagrant_software/shareplex_licence_key.txt`
customer_name=`cat /vagrant_software/shareplex_customer_name.txt`
echo -e "/u01/app/quest/shareplex9.2/\n/u01/app/quest/vardir/2100/\n\n\n\n\n\n\n${licence_key}\n${customer_name}" | ./SharePlex-9.2.0-b42-oracle120-rh-40-amd64-m64.tpm

echo "******************************************************************************"
echo "Quest Shareplex configuration." `date`
echo "******************************************************************************"
cd /u01/app/quest/shareplex9.2/bin
echo -e "n\n\npdb1\nc##sp_admin\nsp_admin\n\n\n\nQUEST_SHAREPLEX\n\nQUEST_SHAREPLEX\n\n" | ./ora_setup

echo "******************************************************************************"
echo "Quest Shareplex start process." `date`
echo "******************************************************************************"
cd /u01/app/quest/shareplex9.2/bin
./sp_cop -u2100 &
sleep 5

echo "******************************************************************************"
echo "Quest Shareplex show configuration." `date`
echo "******************************************************************************"
echo -e ""
echo -e "show\nstatus" | /u01/app/quest/shareplex9.2/bin/sp_ctrl

echo "******************************************************************************"
echo "Quest Shareplex create configuration file." `date`
echo "******************************************************************************"
echo -e ""
echo -e "show\nstatus" | /u01/app/quest/shareplex9.2/bin/sp_ctrl

