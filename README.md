# Vagrant for Quest Shareplex and Foglight to Oracle 12R1 Build

The Vagrant scripts here will allow you to build an Oracle Database 12cR1 and a Shareplex 9.2.0 and Foglight 5.9.2 by just starting the VMs in the correct order.

Two new features has been added:

* Shareplex Change Data Capture
* On premise to AWS RDS database migration

## Required Software

Download and install the following software.

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)
* Git client (not mandatory). You can download manually and unzip the file.
* [Oracle 12R1](https://www.oracle.com/technetwork/database/enterprise-edition/downloads/database12c-linux-download-2240591.html)
* Shareplex 9.2.0 will be installed
* Foglight for Databases 5.9.3 will be installed
* [Foglight Cartridge for Oracle](https://support.quest.com/fr-FR/Login?kc_locale=fr-FR&dest=%2ffr-fr%2ffoglight-for-databases%2f5.9.3%2fdownload-new-releases%3fstarted%3d6093814)
* [Foglight licenses](https://support.quest.com/fr-fr/contact-us/licensing)


## Clone Repository

Pick an area on your file system to act as the base for this git repository and issue the following command. If you are working on Windows remember to check your Git settings for line terminators. If the bash scripts are converted to Windows terminators you will have problems.

```
git clone https://github.com/SergioRomera/quest.git
```

Copy the software under the "quest" directory.


## Licences
Shareplex and Foglight require licenses. This step is mandatory. Put your licenses in this 2 directories:

* Shareplex license

```
└───software
        shareplex_customer_name.txt
        shareplex_licence_key.txt
```

* Foglight license

Put your *.license files in this directory. You can obtain your licences from [licences](https://support.quest.com).

```
└───software
    ├───foglight
    │   ├───foglight_licenses
    │   │   │   put_foglight_licenses_here.txt
```
* Foglight cartridge

Copy your additional cartridge files in this directory:

```
.
│
└───software
    ├───foglight
    │   ├───foglight_cartridges
    │   │   │   DB_Oracle-5_9_3_20.car
    │   │   │   Infrastructure-5_9_4.car
    │   │   │   *.car
```

## Build the Shareplex System

The following commands will leave you with a functioning Shareplex installation.

Modify this files with the correct licence information:

```
└───software
    │   shareplex_customer_name.txt
    │   shareplex_licence_key.txt
```

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
User test is replicated. Here the shareplex configuration:

```
datasource:o.pdb1
#source tables      target tables           routing map
expand test.%       test.%                  ol7-121-splex2@o.pdb1

```

## Change Data Capture

Scripts are in ./shared_scripts/cdc directory.
Amend file config.env if necessary.
Tables created in test schema in source database will be replicated to test schema in target database. A new schema in target is created (cdc schema) that contains all modifications from tables cdc and cdc2 in test schema.

## AWS migration
Scripts are in ./shared_scripts/datapump_migrations directory.
Amend file config.env to configure your AWS RDS.
This migrations use Shareplex to copy source schema (SOURCE_SCHEMA=QUEST_PERF) schema to target schema (TARGET_SCHEMA=QUEST_PERF). Check config.env file to setup.

##Kafka
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


## Architecture

![](quest_poc_architecture.png)

![](foglight_monitoring.png)

![](foglight_monitoring_instance.png)

![](virtualbox_instances.png)


# POC
Schema test in pdb1 database is replicated.
Test table is created in pdb1 database in Node 1 with 1 record. This record is replicated in Node 2.
You can create other objects in Node 1 that will be replicated in Node 2.
Foglight will monitor all the activity of this 2 servers.

