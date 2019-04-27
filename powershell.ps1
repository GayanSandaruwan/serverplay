

# Created By Gayan Kaviarthne on 26-04-2019 github:gayansandaruwan #
########################################################################################################################################
#All Varaibles being defined:
########################################################################################################################################

$checkDir="/Applications/softwareNameforwarder"
$port="8089"
$hostname=$env:computername
$installFile="abc.tgz"

echo "$hostname
#GOTO setDeploymentServer

########################################################################################################################################
# If statement to assign deployment server
########################################################################################################################################

#:setDeploymentServer
$deploymentServer=""
if ($hostname.Substring(0,3) -eq "he3"){
    $deploymentServer="softwareName-deploy-xyz"
}
elseif ($hostname.Substring(0,2) -eq "or"){
    if ($hostname.Substring(3,1) -eq "a" -or $hostname.Substring(3,1) -eq "d"){
        $deploymentServer="softwareName-deploy-or2-apz" 
    }
    else {
        $deploymentServer="softwareName-deploy-or2"
    }
}
elseif($hostname.Substring(3,1) -eq "a" -or $hostname.Substring(3,1) -eq "d"){
    $deploymentServer="softwareName-deploy-apz"
}
else {
    deploymentServer="softwareName-deploy"
} 
echo "$deploymentServer

########################################################################################################################################
# If statement to assign networkZone
########################################################################################################################################


$networkZone=""
IF ($hostname.Substring(3,1) -eq "d"){
    $networkZone="DMZ"
}
ELSEIF ($hostname.Substring(3,1) -eq "a"){
    $networkZone="APZ"
}
ELSE {
    $networkZone="ROTN"
}


echo $networkZone

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



IF ( Test-Path $checkDir ) {

    ########################################################################################################################################
    # If the directory is present following commands are going to be executed****COMMANDS WILL BE DIFFERENT FOR WINDOWS MACHINES
    ########################################################################################################################################



    echo "The directory is Present"
    $version = /Applications/softwareNameforwarder/bin/softwareName version
    echo "The current Version is $version"
    echo "This is an upgrade"
    echo "Disabling boot-start"

    /opt/softwareNameforwarder/bin/softwareName disable boot-start
    timeout /t 10 /nobreak > NUL

    echo "Stopping softwareNameforwarder forwarder"
    /opt/softwareNameforwarder/bin/softwareName stop
    timeout /t 10 /nobreak > NUL
    echo "Upgrading softwareName forwarder to $version"
    Expand-Tar $installFile /opt
    timeout /t 10 /nobreak > NUL

    echo "Starting softwareNameforwarder and accepting the license"
    /opt/softwareNameforwarder/bin/softwareName start --accept-license --answer-yes
    timeout /t 10 /nobreak > NUL

    echo "Removing deployment client Apps from /etc/apps"
    rmdir \s \q /opt/softwareNameforwarder/etc/apps/*deployment*
    timeout /t 10 /nobreak > NUL

    echo "Removing deploymentlient.conf from /etc/system/local"
    del /opt/softwareNameforwarder/etc/system/local/deploymentclient.conf
    timeout /t 10 /nobreak > NUL

    echo "Making a new directory for deployment client companyName_all_deploymentclient"
    mkdir /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local
    timeout /t 10 /nobreak > NUL

    echo "Making a new directory for network _meta tag input"
    mkdir /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local
    timeout /t 10 /nobreak > NUL

    ########################################################################################################################################
    # Text files with the following text being created in the above mentioned folders
    ########################################################################################################################################

    echo "Creating a new deploymentclient.conf in /etc/apps"
    Add-Content -path /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf @"
[deployment-client]

[target-broker:$deploymentServer]
targetUri = $deploymentServer':'$port
"@
    echo "Creating Inputs.conf with meta tags"
    Add-Content -path /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf @"
[default]
host = $hostname
 _meta = networkZone::$networkZone
"@

    echo "Inputs.conf Created"
    timeout /t 60 /nobreak > NUL

    echo "Restarting softwareNameforwarder Forwarder"
    /opt/softwareNameforwarder/bin/softwareName restart
    $newVersion=/opt/softwareNameforwarder/bin
    echo "The new version is $newVersion"

}
ELSE {

    ########################################################################################################################################
    # Else this is a fresh install. The below commands will be executed
    ########################################################################################################################################
    ########################################################################################################################################
    # After execution, Text files with the following text being created in the above mentioned folders
    ########################################################################################################################################

    echo "This is a new install"


    echo "Creating a new deploymentclient.conf in /etc/apps"
    Add-Content -path /opt/softwareNameforwarder/etc/apps/companyName_all_deploymentclient/local/deploymentclient.conf @"
[deployment-client]

[target-broker:$deploymentServer]
targetUri = $deploymentServer':'$port
"@
    echo "Deployment Client Created"
    timeout /t 10 /nobreak > NUL
    echo "Creating Inputs.conf with meta tags"
    Add-Content -path /opt/softwareNameforwarder/etc/apps/companyName_all_metaInputs/local/inputs.conf @"
[default]
host = $hostname
 _meta = networkZone::$networkZone
"@
    echo "Inputs.conf Created"
    timeout /t 60 /nobreak > NUL

    echo "Restarting softwareNameforwarder Forwarder"
    /opt/softwareNameforwarder/bin/softwareName restart
    $newVersion=/opt/softwareNameforwarder/bin
    echo "The new version is $newVersion"
	
}



########################################################################################################################################
########################################################################################################################################



function Expand-Tar($tarFile, $dest) {

    if (-not (Get-Command Expand-7Zip -ErrorAction Ignore)) {
        Install-Package -Scope CurrentUser -Force 7Zip4PowerShell > $null
    }

    Expand-7Zip $tarFile $dest
}