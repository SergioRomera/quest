. /vagrant_config/install.env


echo ""
echo "******************************************************************************"
echo "Binary Foglight download" `date`
echo "******************************************************************************"
if [ -f $FOGLIGHT_SOFTWARE_ZIP ]; then
  echo "Foglight binary found"
else
  echo "Foglight binary not found"
  echo "Download $FOGLIGHT_SOFTWARE_ZIP in progress..."
  cd $FOGLIGHT_BINARIES_INSTALL
  wget -q $FOGLIGHT_BINARY_DOWNLOAD
  
  cd $FOGLIGHT_CARTRIDGES
  echo "Download $FOGLIGHT_CARTRIDGE_ORACLEDB in progress..."
  wget -q $FOGLIGHT_CARTRIDGE_ORACLEDB
  echo "Download $FOGLIGHT_CARTRIDGE_INFRA in progress..."
  wget -q $FOGLIGHT_CARTRIDGE_INFRA
fi

echo ""
echo "******************************************************************************"
echo "Foglight install" `date`
echo "******************************************************************************"
cd $FOGLIGHT_BINARIES_INSTALL
unzip -o $FOGLIGHT_SOFTWARE_ZIP

cd $FOGLIGHT_BINARIES_INSTALL/Server/FoglightServer*
FOGLIGHT_BINARY=`ls -t Foglight*.bin`
./$FOGLIGHT_BINARY -f ./fms_silent_install.properties -i silent

#Trial version
#Free trial from https://www.quest.com/register/55612/
#cd /vagrant_software/
#./Foglight-for-Cross-Platform-Databases-installer-Linux-64bit_59320.bin -f fms_silent_install.properties  -i silent

echo ""
echo "******************************************************************************"
echo "Cartridges" `date`
echo "******************************************************************************"
cp $FOGLIGHT_CARTRIDGES/*.car /home/foglight/Quest/Foglight/upgrade/cartridge

echo ""
echo "******************************************************************************"
echo "Foglight startup" `date`
echo "******************************************************************************"
#cp /vagrant/scripts/cartridges/DB_Oracle_CLI_Installer/oracle_cli_installer.groovy /home/foglight/Quest/Foglight/bin
#cp /vagrant_software/foglight/foglight_cartridges/DB_Oracle_CLI_Installer/oracle_cli_installer.groovy /home/foglight/Quest/Foglight/bin
cd /home/foglight/Quest/Foglight/bin
./fmsStartup.sh
count=0

while [ "$count" -eq 0 ]
do
  count=`ps -ef | grep -E "Quest Application Watchdog" | grep -v grep | wc -l`
  count_sec=`expr $count_sec + 30`

  echo "Waiting for Agent Manager start... $count_sec"
  sleep 30
done;
sleep 30

echo ""
echo "******************************************************************************"
echo "Licenses" `date`
echo "******************************************************************************"
#Install Oracle licenses
#./fglcmd.sh -usr foglight -pwd foglight -cmd license:import -f /vagrant_software/foglight_licenses/142-973-364.license
#Performance Investigator 
#./fglcmd.sh -usr foglight -pwd foglight -cmd license:import -f /vagrant_software/foglight_licenses/142-973-397.license

yourfilenames=`ls $FOGLIGHT_LICENSES/*.license`
for eachfile in $yourfilenames
do
   echo "License: $eachfile"
   ./fglcmd.sh -usr foglight -pwd foglight -cmd license:import -f $eachfile
done


echo ""
echo "******************************************************************************"
echo "Cartridges" `date`
echo "******************************************************************************"
./fglcmd.sh -usr foglight -cmd cartridge:enable -n DB_Oracle -v 5.9.3.20
./fglcmd.sh -usr foglight -cmd cartridge:enable -n DB_Oracle_UI -v 5.9.3.20
#./fglcmd.sh -usr foglight -cmd cartridge:install -f /vagrant_software/foglight_cartridges/DB_Oracle-5_9_3_20.car
#./fglcmd.sh -usr foglight -cmd cartridge:enable -n IntelliProfile -v 5.9.0.1
#./fglcmd.sh -usr foglight -cmd cartridge:enable -n SanHost -v 3.3.0
#./fglcmd.sh -usr foglight -cmd cartridge:enable -n HostAgents -v 5.9.4
#./fglcmd.sh -usr foglight -cmd cartridge:enable -n Infrastructure -v 5.9.4

echo ""
echo "******************************************************************************"
echo "Database monitoring" `date`
echo "******************************************************************************"
fglam=`./fglcmd.sh -cmd agent:list | grep "Host:" | tail -1 | awk '{ print $2 }'`

#-f /home/foglight/Quest/Foglight/bin/oracle_cli_installer.groovy \
#            instances_file_name /vagrant/scripts/cartridges/DB_Oracle_CLI_Installer/oracle_cli_installer_input_template.csv
./fglcmd.sh -srv 127.0.0.1 \
            -port 8080 \
            -usr foglight \
            -pwd foglight \
            -cmd script:run \
            -f $FOGLIGHT_CARTRIDGES/DB_Oracle_CLI_Installer/oracle_cli_installer.groovy \
            fglam_name ${fglam} \
            instances_file_name $FOGLIGHT_CARTRIDGES/DB_Oracle_CLI_Installer/oracle_cli_installer_input_template.csv
#MSSQL
fglam=`./fglcmd.sh -cmd agent:list | grep "Host:" | tail -1 | awk '{ print $2 }'`
./fglcmd.sh -srv 127.0.0.1 \
            -port 8080 \
            -usr foglight \
            -pwd foglight \
            -cmd script:run \
            -f $FOGLIGHT_CARTRIDGES/DB_SQL_Server_CLI_Installer/mssql_cli_installer.groovy \
            fglam_name ${fglam} \
            instances_file_name $FOGLIGHT_CARTRIDGES/DB_SQL_Server_CLI_Installer/silent_installer_input_template.csv
