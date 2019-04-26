
@ECHO OFF
GOTO initializeVar

# Created By Gayan Kaviarthne on 26-04-2019 github:gayansandaruwan #
########################################################################################################################################
#All Varaibles being defined:
########################################################################################################################################

:initializeVar
SET checkDir="/Applications/softwareNameforwarder"
SET port="8089"
SET hostname=%COMPUTERNAME%
SET installFile="abc.tgz"

GOTO setDeploymentServer

########################################################################################################################################
# If statement to assign deployment server
########################################################################################################################################

:setDeploymentServer
SET deploymentServer=""
IF "%hostname:~0,3%"=="he3" (
	SET deploymentServer="softwareName-deploy-xyz"
) ELSE (

	IF "%hostname:~0,2%"=="or" (
		IF "%hostname:~3,1%"=="a" (
			SET deploymentServer="softwareName-deploy-or2-apz"

		)
		ELSE (
			IF "%hostname:~3,1%"=="d" (
				SET deploymentServer="softwareName-deploy-or2-apz"
			) ELSE (
				SET deploymentServer="softwareName-deploy-or2"
			)
		)
	) ELSE (

		IF "%hostname:~3,1%"=="a" (
			SET deploymentServer="softwareName-deploy-apz"
		) ELSE (
			IF "%hostname:~3,1%"=="d" (
				SET deploymentServer="softwareName-deploy-apz"
			) ELSE (
				SET deploymentServer="softwareName-deploy"
			)
		)
	)
)

GOTO setNzone

########################################################################################################################################
# If statement to assign networkZone
########################################################################################################################################

:setNzone
SET networkZone=""

IF "%hostname:~3,1%"=="d" (
	SET networkZone="DMZ"
) ELSE (
	IF "%hostname:~3,1%"=="a" (
		SET networkZone="APZ"
	)
	ELSE (
		SET networkZone="ROTN"
	)
)

GOTO echoVariables

########################################################################################################################################
# All variables being echoed
########################################################################################################################################
#All Variable being echoed:

:echoVariables
echo Host Name is %hostname%
echo Port is %port%
echo Directory to check is %checkDir%
echo Intallation file is %installFile%
echo The Deployment Server is %deploymentServer%
echo The Network Zone is %networkZone%

GOTO checkDir
########################################################################################################################################
# If statement to check if the directory is present
########################################################################################################################################

:checkDir

IF EXIST %checkDir% (

	GOTO dirExists
) ELSE (
	GOTO dirDoesntExist
)


########################################################################################################################################
# If the directory is present following commands are going to be executed****COMMANDS WILL BE DIFFERENT FOR WINDOWS MACHINES
########################################################################################################################################

:dirExists

echo The directory is Present
FOR /F  %%g IN ('/Applications/softwareNameforwarder/bin/softwareName version') do (SET version=%%g)
echo The current Version is %version%
echo This is an upgrade
echo Disabling boot-start

/opt/softwareNameforwarder/bin/softwareName disable boot-start
timeout /t 10 /nobreak > NUL

echo Stopping softwareNameforwarder forwarder
/opt/softwareNameforwarder/bin/softwareName stop
timeout /t 10 /nobreak > NUL
echo Upgrading softwareName forwarder to %version%
tar -xf $installFile -C /opt
timeout /t 10 /nobreak > NUL

echo Starting softwareNameforwarder and accepting the license
/opt/softwareNameforwarder/bin/softwareName start --accept-license --answer-yes
timeout /t 10 /nobreak > NUL

echo Removing deployment client Apps from /etc/apps
rmdir \s \q /opt/softwareNameforwarder/etc/apps/*deployment*
timeout /t 10 /nobreak > NUL

echo Removing deploymentlient.conf from /etc/system/local
del /opt/softwareNameforwarder/etc/system/local/deploymentclient.conf
timeout /t 10 /nobreak > NUL

echo Making a new directory for deployment client companyName_all_deploymentclient
mkdir /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local
timeout /t 10 /nobreak > NUL

echo Making a new directory for network _meta tag input
mkdir /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local
timeout /t 10 /nobreak > NUL

GOTO createConfigFiles

########################################################################################################################################
# Text files with the following text being created in the above mentioned folders
########################################################################################################################################

:createConfigFiles
echo Creating a new deploymentclient.conf in "/etc/apps"
(
	echo [deployment-client]
	echo 
	echo [target-broker:%deploymentServer%]
	echo targetUri = %deploymentServer%:%port% ) > /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf
echo Deployment Client Created
timeout /t 10 /nobreak > NUL

echo Creating Inputs.conf with meta tags
(
	echo [default]
	echo host = %hostname%
	echo
	echo _meta = networkZone::%networkZone% ) > /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf
echo "Inputs.conf Created"
timeout /t 60 /nobreak > NUL

echo Restarting softwareNameforwarder Forwarder
/opt/softwareNameforwarder/bin/softwareName restart
FOR /F  %%g IN ('/opt/softwareNameforwarder/bin') do (SET newVersion=%%g)
echo The new version is %newVersion%

GOTO endOfScript


########################################################################################################################################
# Else this is a fresh install. The below commands will be executed
########################################################################################################################################
########################################################################################################################################
# After execution, Text files with the following text being created in the above mentioned folders
########################################################################################################################################

:dirDoesntExist
echo "This is a new install"


echo Creating a new deploymentclient.conf in "/etc/apps"
( 
	echo [deployment-client]
	echo 
	echo [target-broker:%deploymentServer%]
	echo targetUri = $deploymentServer:%port% ) >/opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf

  echo Deployment Client Created
  timeout /t 10 /nobreak > NUL

  echo Creating Inputs.conf with meta tags

(
	echo [default]
	echo host = %hostname%

	echo _meta = networkZone::%networkZone%
) > /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf
echo Inputs.conf Created
  timeout /t 60 /nobreak > NUL
echo Restarting softwareNameforwarder Forwarder
/opt/softwareNameforwarder/bin/softwareName restart
FOR /F  %%g IN ('/opt/softwareNameforwarder/bin') do (SET newVersion=%%g)
echo The new version is %newVersion%

GOTO endOfScript
########################################################################################################################################
########################################################################################################################################

:endOfScript
echo Done!