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

case "$nzone" in 										# switch statement for determining deployment server
	"d") deploymentServer="abc" ;;
	"a") deploymentServer="def" ;;
	"i") deploymentServer="ghi" ;;
	"s") deploymentServer="jkl" ;;
	"q") deploymentServer="mno" ;;
	"u") deploymentServer="pqresac" ;;
esac

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
/opt/abc/xyz/bin/abc stop
kill -9 `ps -ef | grep abc | grep -v grep | awk '{print $2;}'`
tar -xf $installFile -C /opt/abc
/opt/abc/xyz/bin/abc start --accept-license --answer-yes
rm -rf /opt/abc/xyz/etc/apps/fm_dc
mkdir -p /opt/abc/xyz/etc/apps/fm_dc/local
																		#Writing the config file
cat >/opt/abc/xyz/etc/apps/fm_dc/local/deployclient.conf<<EOL
# cat >./test.conf<<EOL
[deployment-cl]

[target-broker:dserver]
targetUri = $deploymentServer:$port
EOL
# cat ./test.conf
cat /opt/abc/xyz/etc/apps/fm_dc/local/deployclient.conf

/opt/abc/xyz/bin/abc restart