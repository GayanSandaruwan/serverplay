# Created By Gayan Kavirathne on 11/04/2019
# Give permissions to the script before using by
# sudo chmod +x serverplay.sh
# Then run it from termianl by 
# ./serverplay.sh

hostname=$HOSTNAME										# Read Hostname								
echo $hostname

port="8089"
installFile="abc.tgz"

location="${hostname:0:3}"								# Get first three letters of hostname
nzone="${hostname:3:1}"									# Get forth letter of hostname

echo $location
echo $nzone

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


networkZone=""
case "nzone" in 										# Switch statement for determining network Zone
	"d") networkZone="D" ;;
	"a") networkZone="APP" ;;
	"i") networkZone="inter" ;;
	"s") networkZone="cor" ;;
	"q") networkZone="dta" ;;
	"u") networkZone="usr" ;;
esac
														# Executing the commands
/opt/abc/xyz/bin/abc disable boot-start

sleep 10
/opt/abc/xyz/bin/abc stop
sleep 10
kill -9 `ps -ef | grep abc | grep -v grep | awk '{print $2;}'`
sleep 10
tar -xf $installFile -C /opt/abc
sleep 10
/opt/abc/xyz/bin/abc start --accept-license --answer-yes
sleep 10
rm -rf /opt/abc/xyz/etc/apps/fm_dc
sleep 10
mkdir -p /opt/abc/xyz/etc/apps/fm_dc/local
sleep 10
																		#Writing the config file
cat >/opt/abc/xyz/etc/apps/fm_dc/local/deployclient.conf<<EOL
# cat >./test.conf<<EOL
[deployment-cl]

[target-broker:dserver]
targetUri = $deploymentServer:$port
EOL
# cat ./test.conf
cat /opt/abc/xyz/etc/apps/fm_dc/local/deployclient.conf

sleep 60
/opt/abc/xyz/bin/abc restart