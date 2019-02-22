====
    This software is confidential. Quest Software Inc., or one of its subsidiaries, has supplied this software to you
    under terms of a license agreement, nondisclosure agreement or both.

    You may not copy, disclose, or use this software except in accordance with those terms.

    Copyright 2017 Quest Software Inc. ALL RIGHTS RESERVED.

    QUEST SOFTWARE INC. MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
    OR NON-INFRINGEMENT. QUEST SOFTWARE SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
    MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
====

The silent installer script creates agents for monitoring Oracle instances, RACs, and nodes on a given Foglight Agent Manager (FglAM), using a CSV file that specifies the list of Oracle instances that are to be monitored.

Requirements
---------------
Foglight Management Server (FMS) is running.
Foglight Agent Manger is running(for the selected FMS).
The Oracle cartridge should be installed.

Getting started
---------------

1. Navigate to Administration > Cartridges > Components for downloads and download the DB_Oracle_Oracle_Installer file to a temporary folder.
2. Extract the DB_Oracle_Oracle_Installer.zip file to a temporary folder.
   The DB_Oracle_Oracle_Installer.zip file contains the following files:
   * Readme.txt
   * oracle_cli_installer.groovy - a groovy script file that runs the silent installation. This file should be copied to the <FMS_HOME>/bin directory.
   * oracle_cli_installer_input_template.csv - the input file, which provides a basis for inserting contents into CSV file). This file can be copied to any folder of your choice, provided that the path indicated by the <oracle_instances_file_name> parameter (detailed below) points to the selected path.
   * Check permission script
   * Grant permission script

Running the silent installer
*************************
Copy the oracle_cli_installer.groovy  file to the <FMS_HOME>/bin directory.
Go to the command line and execute the command:
  <FMS_HOME>/bin/fglcmd -srv <fms_host_name> -port <fms_url_port> -usr <fms_user_name> -pwd <fms_user_password> -cmd script:run -f oracle_cli_installer.groovy fglam_name <fglam_name> instances_file_name <instances_file_name> lockbox_name <lockbox_name> lockbox_password <lockbox_password>
The descriptions of the flags and parameters in this command are as follows:

  <FMS_HOME>: The Foglight Management Server installation directory.
  <fms_host_name>: The name of the host where the Foglight Management Server is installed.
  <fms_url_port>: The Foglight Management Server HTTP port.
  <fms_user_name>: The user name used for connecting to the Foglight Management Server.
  <fms_user_password>: The password of the specified user.
  <fglam_name>: The name of the selected Foglight Agent Manager where new agents are to be added.
  <instances_file_name>: The full path and the name of the input CSV file.
  <lockbox_name>: Optional - specifies the name of an existing lockbox to be used.
  <lockbox_password>: Optional - the selected lockbox's password.

Configuration files
============================
The CSV file should contain data about a list of Oracle instances to monitor.
For each instance the following fields should be filled (same as in the "oracle_cli_installer_input_template.csv" file):


RAC Agent Name:
  - If the instance belongs to a RAC, this field has to contain the name of the RAC agent. If this RAC runs multiple nodes, all instances must have the same RAC agent name.  
  This name must be unique per agent.  If the instance does not belong to a RAC, leave this field empty.
Instance Type:
   - The type of the instance to be monitored. The possible values are: SINGLE, NODE, RAC ONE NODE.
     - SINGLE: the instance does not belong to a RAC.
     - NODE:the instance belongs to a RAC that has more than one instance.
     - RAC ONE NODE: the instance belongs to a RAC with a single node.

Agent Name:
  - The requested agent name. This name must be unique per agent. If an agent with the given name already exists, the newly provided agent will not be created. In the case of a RAC Node,the agent name should be different from the RAC agent name.

Host:
  - The host that is serving the Oracle instance or RAC.

Port:
  - The TNS Listener port.

Connection Method:
   - The requested connection method. The possible values are either SERVICE_NAME or SID . If the instance type is a node, the only possible value is SID.


SID/Service Name:
   - The name of the SID or service name used for establishing connection to the instance.

User name
   - The user name to be used for connecting to the instance,

Password
   - The password of the database user name.

Administrator User Name (Optional):
    - The user name of a user that is able to grant privileges to the regular database user; required only if the regular user does not have sufficient privileges.

Administrator Password (Optional):
    - The password of the database administrator user name mentioned above.

Enable OS Monitoring
    - Specifies whether to create an Infrastructure cartridge agent for the given host name; the possible values are "True" or "False". Leaving this field empty indicates a "False" value.

OS Platform (Optional):
    - The OS platform that is running on the Oracle instance host; the possible values are either UNIX or WINDOWS.

Authentication (Optional):
    - OS authentication type. This field can have one of the following values:
		-- LOGIN_PASSWORD: user/password authentication
		-- RSA_KEY: RSA-based public key authentication
		-- DSA_KEY: DSA-based public key authentication
		-- CLIENT_LOGIN: uses the Foglight Agent Manager's login
		-- WINDOWS_ACCOUNT: Windows authentication, in the domain\user and password convention

OS User Name (Optional):
	- The user name to be used for connecting to the OS and monitoring it.

OS Password (Optional):
    - The password of the OS user name specified above.

SSH Port (Optional)
    - The port that is used for listening to incoming SSH connections on the monitored hosts; if the monitored host is Windows-based, leave this field empty. If no value is entered in this field, the default port of 22 is used in UNIX       connection.


Private Key File Path (Optional)
    - The full path of the private key file; relevant only to the following credential types: RSA_KEY, DSA_KEY.

Passphrase (Optional)
     - The passphrase of the OS user that is used in public key authentication; relevant only to the following credential types: RSA_KEY, DSA_KEY.

Use sudo (Optional)
    - Used for indicating that the OS user specified above is not an administrator user, but can run certain commands that require administrative privileges as root.
      Possible values: TRUE, FALSE. If the monitored host is Windows-based, leave this field empty to indicate FALSE.

Enable VMware Collection (Optional)
    - Indicates whether to monitor VMware metrics; the possible values are "True" or "False". Leaving this field empty indicates a "False" value.

VMware Host (Optional)
    - The ESX host name.

VMware Port (Optional)
    - The VMware port. If no value is inserted in this field, the port number to be used is the default number 443.

VMware User Name (Optional)
    - The user name required for connecting to the VMware.

VMware Password (Optional)
    - The password of the VMware user specified above.

Enable PI (Optional)
    - Indicates whether to enable PI; the possible values are "True" or "False". Leaving this field empty indicates a "False" value.
	  a PI repository must be already installed and assigned to at least one agent on the monitoring FglAM.
	  
Listener Name (Optional)
	- The instance listener name. Default "LISTENER" name will be used if this field remains empty

Encrypted Passwords	(Optional)
	- Indicates whether the given passwords are already encrypted; the possible values are "True" or "False". Leaving this field empty indicates a "False" value.
	  The password encryption can manually be done by executing 'Dbwc_Common_Oracle_EncryptString(<Password>)' function from Foglight's script console
	  
Is Mounted	(Optional)
    - Indicates whether the given monitored instance is in a mounted stand-by mode (data-guard); the possible values are "True" or "False". Leaving this field empty indicates a "False" value.

Credential Name	(Optional)
    - an Existing credential name.
      When using this property, the 'OS User Name', 'OS Password', 'Private Key File Path' and 'Passphrase' properties will be ignored.
	
Silent installer output files
 ============================
The following additional CSV files will be created in the same folder where the input file resides:
* A file with the input file's name and "_status" suffix (for example: if the input file is named "input", this file is named "input_status"). This file indicates the monitoring situation of all Oracle instances listed in the input CSV file. If monitoring failed for one or more of the instances, the file specifies the error message.
If all instances listed in the input CSV file passed the monitoring validation successfully, no additional file is created.
If one or more instances failed the monitoring validation, another file with input file's name and "_new" suffix is created. This file, which is designed to assist users whose instances, nodes or RACs failed to be monitored, contains all details about the failed instances/RACs/nodes.

Contents of the "_status" file
------------------------------
The CSV file that specifies the monitoring situation of all Oracle instances listed in the input CSV file [original file name + _status.csv] contains the following columns:

- DB Agent name: the name of the monitored Foglight for Oracle agent.
- Host Name: the name of the host that is serving the Oracle instance.
- Instance name: the name of the Oracle instance.

- Status: the result of the monitoring validation process; can be "SUCCESSFUL" or "FAILED".

- Error  message: the given error message in case the agent creation failed.

Contents of the "_new" file
-------------------------------
This file, which is only created if one or more instances, nodes or RACs failed the monitoring validation, contains all details about these instances, RACs, or nodes.
Using this CSV file, the user only needs to fix the errors and re-run the script, this time by specifying this file as the input file. [original file name + new.csv]


