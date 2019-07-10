# Vagrant for Quest Shareplex and Foglight to Oracle 12R1 Build

The Vagrant scripts here will allow you to build 2 virtual machines in your comuter with an Oracle Database 12cR1 and Shareplex 9.2.0 in each node (1 and 2) and Foglight 5.9.2 by just starting the VMs in the correct order.

Three new features has been added:

* Shareplex Change Data Capture
* On premise to AWS RDS database migration
* Kafka replication from Node 1 to Node 2

## Required Software

Download and install the following software.

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)
* SharePlex licenses
* Foglight licenses


## Clone Repository

Pick an area on your file system to act as the base for this git repository and issue the following command. If you are working on Windows remember to check your Git settings for line terminators. If the bash scripts are converted to Windows terminators you will have problems.

```
git clone https://github.com/SergioRomera/quest.git
```

Copy the software under the "quest" directory.

Or download the quest-master.zip file in a directory and unzip.


## Architecture

![](quest_poc_architecture.png)

![](foglight_monitoring.png)

![](foglight_monitoring_instance.png)

![](virtualbox_instances.png)


# POC
This scripts containts severals POC's.
Shareplex: Schema test in pdb1 database in Node 1 is replicated in Node 2.
Foglight: Foglight will monitor all the activity from Node 1 and Node 2.

## Licenses
Shareplex and Foglight require licenses. This step is mandatory. Put your licenses in this 2 directories:

* Shareplex license

```
└───software
        shareplex_customer_name.txt
        shareplex_licence_key.txt
```

* Foglight license

Put your *.license files in this directory. You can obtain your licences from [licenses](https://support.quest.com).

```
└───software
    ├───foglight
    │   ├───foglight_licenses
    │   │   │   put_foglight_licenses_here.txt
```

## Build the Shareplex System

The following commands will leave you with a functioning Shareplex installation.

Start the first node and wait for it to complete. This will create the primary database.

```
#Primary Oracle DB
cd node1
vagrant up
```

Start the second node and wait for it to complete. This will create the second database.

```
#Secondary Oracle DB
cd ../node2
vagrant up
```

## Build the Foglight System

The following commands will leave you with a functioning Foglight installation.

Start the forth node and wait for it to complete.

```
cd ../node4
vagrant up
```


## Turn Off System

Perform the following to turn off the system cleanly.


```
cd ../node4
vagrant halt

cd ../node2
vagrant halt

cd ../node1
vagrant halt
```

## Remove Whole System

The following commands will destroy all VMs and the associated files, so you can run the process again.

```
cd ../node4
vagrant destroy -f

cd ../node2
vagrant destroy -f

cd ../node1
vagrant destroy -f
```

## Shareplex configuration
Oracle user test is created in VM1 in pdb1 database and is replicated. Here the shareplex configuration:

```
datasource:o.pdb1
#source tables      target tables           routing map
expand test.%       test.%                  ol7-121-splex2@o.pdb1

```

## Shareplex Change Data Capture

Sample scripts are included in ./shared_scripts/cdc directory.
Amend file config.env if necessary.
Tables created in test schema in Node 1 in pdb1 database will be replicated to test schema in target database (Node 2). A new schema in target is created (cdc schema) that contains all modifications from tables cdc and cdc2 in test schema.

## AWS migration
Scripts are in ./shared_scripts/datapump_migrations directory.
Amend file config.env to configure your AWS RDS.
This migrations use Shareplex to copy source schema (SOURCE_SCHEMA=QUEST_PERF) schema to target schema (TARGET_SCHEMA=QUEST_PERF). Check config.env file to setup.

```
__  __ _                 _   _                 __
|  \/  (_) __ _ _ __ __ _| |_(_) ___  _ __     / _|_ __ ___  _ __ ___
| |\/| | |/ _` | '__/ _` | __| |/ _ \| '_ \   | |_| '__/ _ \| '_ ` _ \
| |  | | | (_| | | | (_| | |_| | (_) | | | |  |  _| | | (_) | | | | | |
|_|  |_|_|\__, |_|  \__,_|\__|_|\___/|_| |_|  |_| |_|  \___/|_| |_| |_|
          |___/
  ___                                    _             _
/ _ \ _ __     _ __  _ __ ___ _ __ ___ (_)___  ___   | |_ ___
| | | | '_ \   | '_ \| '__/ _ \ '_ ` _ \| / __|/ _ \  | __/ _ \
| |_| | | | |  | |_) | | |  __/ | | | | | \__ \  __/  | || (_) |
\___/|_| |_|  | .__/|_|  \___|_| |_| |_|_|___/\___|   \__\___/

    _     __        __  ____      __  _               ___                  _    __
   / \    \ \      / / / ___|    / / | |__  _   _    / _ \ _   _  ___  ___| |_  \ \
  / _ \    \ \ /\ / /  \___ \   | |  | '_ \| | | |  | | | | | | |/ _ \/ __| __|  | |
/ ___ \    \ V  V /    ___) |  | |  | |_) | |_| |  | |_| | |_| |  __/\__ \ |_   | |
/_/   \_\    \_/\_/    |____/   | |  |_.__/ \__, |   \__\_\\__,_|\___||___/\__|  | |
                                 \_\        |___/                               /_/


[20190523-071517] Create target user: OK
[20190523-071517] Grant source privileges: OK
[20190523-071517] Stop post: OK
[20190523-071525] Activate Shareplex config: OK
[20190523-071525] Switch log in source database: OK
[20190523-071525] Take SCN in source database to sync: OK
mkdir: cannot create directory ‘/u01/app/oracle/product/12.1.0.2/dbhome_1/datapump’: File exists

Export: Release 12.1.0.2.0 - Production on Thu May 23 07:15:25 2019

Copyright (c) 1982, 2014, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options
FLASHBACK automatically enabled to preserve database integrity.
Starting "SYSTEM"."EXPORT_QUEST_PERF":  system/********@pdb1 schemas=QUEST_PERF directory=data_pump_dir_sample dumpfile=sample.dmp logfile=sample.log job_name=export_quest_perf parallel=2 compression=all flashback_scn=4048877
Estimate in progress using BLOCKS method...
Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
Total estimation using BLOCKS method: 325.5 MB
Processing object type SCHEMA_EXPORT/USER
. . exported "QUEST_PERF"."EMPLOYEE"                     41.10 MB  599998 rows
Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
Processing object type SCHEMA_EXPORT/ROLE_GRANT
Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
Processing object type SCHEMA_EXPORT/SYNONYM/SYNONYM
Processing object type SCHEMA_EXPORT/TYPE/TYPE_SPEC
Processing object type SCHEMA_EXPORT/SEQUENCE/SEQUENCE
Processing object type SCHEMA_EXPORT/TABLE/TABLE
Processing object type SCHEMA_EXPORT/TABLE/FGA_POLICY
Processing object type SCHEMA_EXPORT/PACKAGE/PACKAGE_SPEC
Processing object type SCHEMA_EXPORT/FUNCTION/FUNCTION
Processing object type SCHEMA_EXPORT/PROCEDURE/PROCEDURE
Processing object type SCHEMA_EXPORT/PACKAGE/COMPILE_PACKAGE/PACKAGE_SPEC/ALTER_PACKAGE_SPEC
Processing object type SCHEMA_EXPORT/FUNCTION/ALTER_FUNCTION
Processing object type SCHEMA_EXPORT/PROCEDURE/ALTER_PROCEDURE
Processing object type SCHEMA_EXPORT/VIEW/VIEW
Processing object type SCHEMA_EXPORT/PACKAGE/PACKAGE_BODY
Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/REF_CONSTRAINT
Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
. . exported "QUEST_PERF"."EMPLOYEEX"                    32.58 MB  599998 rows
. . exported "QUEST_PERF"."EMP_SAL_HIST"                 21.26 MB 1700000 rows
. . exported "QUEST_PERF"."EMP_SMALL"                    3.093 MB   92193 rows
. . exported "QUEST_PERF"."JOB_HISTORY"                  522.1 KB   48063 rows
. . exported "QUEST_PERF"."STRESSTESTTABLE"              680.1 KB    1737 rows
. . exported "QUEST_PERF"."EMP_SAL_HISTX"                142.6 KB   10000 rows
. . exported "QUEST_PERF"."EMP_SMALLX"                   116.2 KB    3000 rows
. . exported "QUEST_PERF"."GRADE"                        29.83 KB    1100 rows
. . exported "QUEST_PERF"."LOCATIONS"                    23.22 KB     784 rows
. . exported "QUEST_PERF"."AWS_TEST"                     4.929 KB       2 rows
. . exported "QUEST_PERF"."COUNTRIES"                    6.843 KB     196 rows
. . exported "QUEST_PERF"."DEPARTMENT"                   13.84 KB     306 rows
. . exported "QUEST_PERF"."DEPARTMENTX"                  14.13 KB     306 rows
. . exported "QUEST_PERF"."GRADEX"                       20.60 KB    1100 rows
. . exported "QUEST_PERF"."JOBS"                         5.453 KB      19 rows
. . exported "QUEST_PERF"."PERSONLIST"                   5.125 KB       2 rows
. . exported "QUEST_PERF"."REGIONS"                      4.906 KB       6 rows
. . exported "QUEST_PERF"."T_PERSON"                     6.273 KB       0 rows
Master table "SYSTEM"."EXPORT_QUEST_PERF" successfully loaded/unloaded
******************************************************************************
Dump file set for SYSTEM.EXPORT_QUEST_PERF is:
  /u01/app/oracle/product/12.1.0.2/dbhome_1/datapump/sample.dmp
Job "SYSTEM"."EXPORT_QUEST_PERF" successfully completed at Thu May 23 07:16:04 2019 elapsed 0 00:00:38

[20190523-071605] Export datapump: OK
[20190523-071605] Insert some data in source database..... You have 60 seconds!
[20190523-071706] Create dblink: OK
[20190523-071706] File transfer running...
[20190523-071719] File transfer: OK
[20190523-071719] Import data pump running...
[20190523-071851] Import data pump: OK
[20190523-071851] Reconcile queue: OK
[20190523-071851] Start post: OK
[20190523-071851] Cleanup source data pump: OK
[20190523-071856] Cleanup target datapump: OK

```

## Kafka
Scripts are in ./shared_scripts/kafka directory.
This scripts will download, install and start Kafka software in the Node 2.
A tests is done from KAFKA user in Node 1 Oracle database to Node 2.

```
#Start Kafka test
cd /vagrant_scripts/kafka
sh kafka_poc_install.sh

 _  __           __   _               ____     ___     ____
| |/ /   __ _   / _| | | __   __ _   |  _ \   / _ \   / ___|
| ' /   / _` | | |_  | |/ /  / _` |  | |_) | | | | | | |
| . \  | (_| | |  _| |   <  | (_| |  |  __/  | |_| | | |___
|_|\_\  \__,_| |_|   |_|\_\  \__,_|  |_|      \___/   \____|
  __  _                 ___                         _    __
 / / | |__    _   _    / _ \   _   _    ___   ___  | |_  \ \
| |  | '_ \  | | | |  | | | | | | | |  / _ \ / __| | __|  | |
| |  | |_) | | |_| |  | |_| | | |_| | |  __/ \__ \ | |_   | |
| |  |_.__/   \__, |   \__\_\  \__,_|  \___| |___/  \__|  | |
 \_\          |___/                                      /_/

[20190531-144430] Create kafka sql user: OK
[20190531-144439] Download kafka binaries: OK
[20190531-144439] untar kafka binaires: OK
[20190531-144441] Deactivate kafka shareplex config: OK
[20190531-144448] Activate kafka shareplex config: OK
[20190531-144453] Start zookeeper server: OK
[20190531-144503] Start kafka server: OK
[20190531-144513] Listing kafka topics
[20190531-144513] Please, start consumer process and press ENTER to continue

[20190531-144743] Insert in kafka sql user: OK
[20190531-144743] Execute next command to check kafka messages from oracle
[20190531-144743] sh kafka_consume_topic.sh
```
