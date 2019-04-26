
########################################################################################################################################
#All Varaibles being defined:

########################################################################################################################################
checkDir="/Applications/softwareNameforwarder"
port="8089"
hostname=$HOSTNAME
installFile="abc.tgz"
########################################################################################################################################
# If statement to assign deployment server
########################################################################################################################################
deploymentServer=""
if [ "${hostname:0:3}" == "he3" ]; then
	deploymentServer="softwareName-deploy-xyz"
elif [ "${hostname:0:2}" == "or" ]; then
	if [ "${hostname:3:1}" == "a" -o "${hostname:3:1}" == "d" ]; then
		deploymentServer="softwareName-deploy-or2-apz"
	else
		deploymentServer="softwareName-deploy-or2"
	fi
elif [ "${hostname:3:1}" == "a" -o "${hostname:3:1}" == "d" ]; then
	deploymentServer="softwareName-deploy-apz"
else
	deploymentServer="softwareName-deploy"
fi

########################################################################################################################################
# If statement to assign networkZone
########################################################################################################################################

networkZone=""
if [ "${hostname:3:1}" == "d" ]; then
  networkZone="DMZ"
elif [ "${hostname:3:1}" == "a" ]; then
  networkZone="APZ"
elif [ "${hostname:3:1}" != "a" -o "${hostname:4:1}" != "d" ]; then
  networkZone="ROTN"
fi
########################################################################################################################################
# All variables being echoed
########################################################################################################################################
#All Variable being echoed:
echo "Host Name is $hostname"
echo "Port is $port"
echo "Directory to check is $checkDir"
echo "Intallation file is $installFile"
echo "The Deployment Server is $deploymentServer"
echo "The Network Zone is $networkZone"

########################################################################################################################################
# If statement to check if the directory is present
########################################################################################################################################

if [ -d "$checkDir" ]; then

########################################################################################################################################
# If the directory is present following commands are going to be executed****COMMANDS WILL BE DIFFERENT FOR WINDOWS MACHINES
########################################################################################################################################

  echo "The directory is Present"
  version=$(/Applications/softwareNameforwarder/bin/softwareName version)
  echo "The current Version is $version"

  echo "This is an upgrade"
  echo "Disabling boot-start"
  /opt/softwareNameforwarder/bin/softwareName disable boot-start
  sleep 10
  echo "Stopping softwareNameforwarder forwarder"
  /opt/softwareNameforwarder/bin/softwareName stop
  sleep 10
  echo "Upgrading softwareName forwarder to $version"
  tar -xf $installFile -C /opt
  sleep 10
  echo "Starting softwareNameforwarder and accepting the license"
  /opt/softwareNameforwarder/bin/softwareName start --accept-license --answer-yes
  sleep 10
  echo "Removing deployment client Apps from /etc/apps"
  rm -r /opt/softwareNameforwarder/etc/apps/*deployment*
  sleep 10
  echo "Removing deploymentlient.conf from /etc/system/local"
  rm /opt/softwareNameforwarder/etc/system/local/deploymentclient.conf
  sleep 10
  echo "Making a new directory for deployment client companyName_all_deploymentclient"
  mkdir -p /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local
  sleep 10
  echo "Making a new directory for network _meta tag input"
  mkdir -p /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local
  sleep 10
########################################################################################################################################
# Text files with the following text being created in the above mentioned folders
########################################################################################################################################

  echo "Creating a new deploymentclient.conf in /etc/apps"
  cat >/opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf<<EOL
[deployment-client]

[target-broker:deploymentServer]
targetUri = $deploymentServer:$port
EOL

  cat /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf
  echo "Deployment Client Created"
  sleep 10

  echo "Creating Inputs.conf with meta tags"
  cat >/opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf<<EOL
[default]
host = $hostname

_meta = networkZone::$networkZone
EOL
  cat /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf
  echo "Inputs.conf Created"
  sleep 60
  echo "Restarting softwareNameforwarder Forwarder"
  /opt/softwareNameforwarder/bin/softwareName restart
  newVersion=$(/opt/softwareNameforwarder/bin)
  echo "The new version is $newVersion"

########################################################################################################################################
# Else this is a fresh install. The below commands will be executed
########################################################################################################################################

else
  echo "This is a new install"

########################################################################################################################################
# After execution, Text files with the following text being created in the above mentioned folders
########################################################################################################################################

  echo "Creating a new deploymentclient.conf in /etc/apps"
  cat >/opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf<<EOL
[deployment-client]

[target-broker:deploymentServer]
targetUri = $deploymentServer:$port
EOL
  cat /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf
  echo "Deployment Client Created"
  sleep 10

  echo "Creating Inputs.conf with meta tags"
  cat >/opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf<<EOL
[default]
host = $hostname

_meta = networkZone::$networkZone
EOL
  cat /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf
  echo "Inputs.conf Created"
  sleep 60
  echo "Restarting softwareNameforwarder Forwarder"
  /opt/softwareNameforwarder/bin/softwareName restart
  newVersion=$(/opt/softwareNameforwarder/bin)
  echo "The new version is $newVersion"
########################################################################################################################################
########################################################################################################################################

fi