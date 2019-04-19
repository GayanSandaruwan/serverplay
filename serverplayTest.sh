# Created By Gayan Kavirathne on 11/04/2019
# Give permissions to the script before using by
# sudo chmod +x serverplay.sh
# Then run it from termianl by 
# ./serverplay.sh

hostname=$HOSTNAME										# Read Hostname								
echo $hostname 2>&1 | tee -a output.txt

port="8089"
installFile="abc.tgz"

location="${hostname:0:3}"							# Get first three letters of hostname
nzone="${hostname:3:1}"									# Get forth letter of hostname

echo $location 2>&1 | tee -a output.txt
echo $nzone 2>&1 | tee -a output.txt

deploymentServer=""

if [ "${hostname:0:3}" == "he3" ]; then
	deploymentServer="abc-deploy-xyz"
elif [ "${hostname:0:2}" == "or" ]; then
	if [ "${hostname:3:1}" == "a" -o "${hostname:3:1}" == "d" ]; then
		deploymentServer="abc-deploy-or2-apz"
	else
		deploymentServer="abc-deploy-or2"
	fi
elif [ "${hostname:3:1}" == "a" -o "${hostname:3:1}" == "d" ]; then
	deploymentServer="abc-deploy-apz"
else
	deploymentServer="abc-deploy"
fi

echo "Deployment Server : "$deploymentServer 2>&1 | tee -a output.txt

networkZone=""
case "nzone" in 										# Switch statement for determining network Zone
	"d") networkZone="D" ;;
	"a") networkZone="APP" ;;
	"i") networkZone="inter" ;;
	"s") networkZone="cor" ;;
	"q") networkZone="dta" ;;
	"u") networkZone="usr" ;;
esac

echo "Network Zone : "$networkZone 2>&1 | tee -a output.txt
		
												# Executing the commands
/opt/abc/xyz/bin/abc disable boot-start 2>&1 | tee -a output.txt

sleep 10 2>&1 | tee -a output.txt
/opt/abc/xyz/bin/abc stop 2>&1 | tee -a output.txt
sleep 10 2>&1 | tee -a output.txt
kill -9 `ps -ef | grep abc | grep -v grep | awk '{print $2;}'` 2>&1 | tee -a output.txt
sleep 10 2>&1 | tee -a output.txt
tar -xf $installFile -C /opt/abc 2>&1 | tee -a output.txt
sleep 10 2>&1 | tee -a output.txt
/opt/abc/xyz/bin/abc start --accept-license --answer-yes 2>&1 | tee -a output.txt
sleep 10 2>&1 | tee -a output.txt
rm -rf /opt/abc/xyz/etc/apps/fm_dc 2>&1 | tee -a output.txt
sleep 10 2>&1 | tee -a output.txt
mkdir -p /opt/abc/xyz/etc/apps/fm_dc/local 2>&1 | tee -a output.txt
sleep 10 2>&1 | tee -a output.txt
																		#Writing the config file
cat >/opt/abc/xyz/etc/apps/fm_dc/local/deployclient.conf<<EOL 
# cat >./test.conf<<EOL
[deployment-cl]

[target-broker:dserver]
targetUri = $deploymentServer:$port
EOL
# cat ./test.conf
cat /opt/abc/xyz/etc/apps/fm_dc/local/deployclient.conf 2>&1 | tee -a output.txt

sleep 60 2>&1 | tee -a output.txt
/opt/abc/xyz/bin/abc restart 2>&1 | tee -a output.txt