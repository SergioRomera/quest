/**
 * This software is confidential. Quest Software Inc., or one of its subsidiaries, has supplied this software to you
 * under terms of a license agreement, nondisclosure agreement or both.
 *
 * You may not copy, disclose, or use this software except in accordance with those terms.
 *
 * Copyright 2017 Quest Software Inc. ALL RIGHTS RESERVED.
 *
 * QUEST SOFTWARE INC. MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * OR NON-INFRINGEMENT. QUEST SOFTWARE SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 */
/**
* This script invoke the cli installer by using the  
 * Required input:
 *    fglam_name          - The name of the FglAM on which to install the new agents
 *    instances_file_name - The full path of the input instances CSV file
 *    lockbox_name        - The name of the Lockbox on which to add new credentials (Optional input)
 *    lockbox_password    - The Lockbox password (Optional input)
*/

import com.quest.wcf.servicelayer.*;

FGLAM_PREFIX = "fglam_name";
INSTANCES_FILE_PREFIX = "instances_file_name";
LOCKBOX_NAME_PREFIX = "lockbox_name";
LOCKBOX_PASSWORD = "lockbox_password";

// parameters that need to be filled and transfered to the next groovy script
argFglamName = "";
argInstancesFileName="";
argLockboxName = ""; 
argLockboxPassword = "";

/**********************************
 *            Functions
 **********************************/
/**
* Reading parameters from the command line
**/
def readParameters() {
	println("Reading input parameters. " + args.size());
	def i = 1;
	while (i < args.size()) {
		println(" parameters ["+ i + "] = " + args[i]);
		if (args[i].equals(FGLAM_PREFIX)) {
			argFglamName = args[i+1];
			println("fglamName = " + argFglamName);
		}
		else if (args[i].equals(INSTANCES_FILE_PREFIX)) {
			argInstancesFileName = args[i+1];
			println("instancesFileName = " + argInstancesFileName);
		}
		else if (args[i].equals(LOCKBOX_NAME_PREFIX)) {
			argLockboxName = args[i+1];
			println("lockboxName = " + argLockboxName);
		}
		else if (args[i].equals(LOCKBOX_PASSWORD)) {
			argLockboxPassword = args[i+1];
			println("lockboxPassword = " + argLockboxPassword);
		}
		else {
			println("Invalid parameter name " + args[i] + ".");			
		}
		i = i+2;
	}
	if (!verifyParameterExist(FGLAM_PREFIX, argFglamName))
		return false;
		
	if (!verifyParameterExist(INSTANCES_FILE_PREFIX, argInstancesFileName))
		return false;
		
	if (!checkIsFileExist()){
		println( "The system cannot find the file specified : " + argInstancesFileName);
		return false;
	}	
		
	if (!verifyLockboxInputs(argLockboxName, argLockboxPassword))
		return false;
		
	println("Finished reading input parameters.");
	return true;
}

def checkIsFileExist() {
	File f = new File(argInstancesFileName);
	return f.exists();	
}

/**
* checking that a required paramter has an input value
**/
def verifyParameterExist(paramName, paramValue) {
	if (paramValue == null) {
		println("Parameter " + paramName + " cannot be empty. Please enter parameters again.");
		return false;
	}
	return true;
}

/**
* verifying that both the lockbox name and password were supplied (or non at all, since this is an optional input.)
**/
def verifyLockboxInputs(lockboxName, lockboxPassword) {
	if ((lockboxName != null) && (lockboxPassword == null)) {
		println("Lockbox name was supplied but lockbox password was not. Please enter parameters again.");
		return false;
	}
	if ((lockboxName == null) && (lockboxPassword != null)) {
		println("Lockbox password was supplied but lockbox name was not. Please enter parameters again.");
		return false;
	}
	
	return true;
}

/**
* cmd help
**/
def help() {
	println("Activates the silent installation.");
	println("Usage: groovy silentInstallation.groovy [options] [args]");
	println("Options:");
	println(FGLAM_PREFIX + " <" + FGLAM_PREFIX.replace("-", "") + ">\t\tRequired input. The name of the FglAM on which to install the new agents.");
	println(INSTANCES_FILE_PREFIX + " <" + INSTANCES_FILE_PREFIX.replace("-", "") + ">\t\tRequired input. The full path of the input instances file.");
	println("[" + LOCKBOX_NAME_PREFIX + " <" + LOCKBOX_NAME_PREFIX.replace("-", "") + ">]\t\tOptional input. The name of the Lockbox on which to add new credentials.");
	println("[" + LOCKBOX_PASSWORD + " <" + LOCKBOX_PASSWORD.replace("-", "") + ">]\t\tvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv.");
	println("");
}

/**********************************
 *              MAIN
 **********************************/ 
if ((args.size() == 0) || ((args.size() == 1) && (args[0].equalsIgnoreCase("-help") || args[0].equalsIgnoreCase("help")))) {
	help();
} else {
	println("Starting the Oracle cli install.");
	if (!readParameters()) 
		return;
    try {
	  ServiceRegistry.getEvaluationService().invokeFunction("system:oracle_installer_apis_silent_installer.executeSilentInstaller", [false,argFglamName, argInstancesFileName, argLockboxName, argLockboxPassword], null, null);
	}  catch(e) {
		while (e.cause != null) {
			e = e.cause;
		}	
		println("The Oracle cli install failed with error :\n " + e.getMessage() );
	}
	
	println("Finished Oracle cli install.");
}
