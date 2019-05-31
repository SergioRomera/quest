
. ./config.env


cd $SP_HOME/bin
echo "shutdown" | $SP_HOME/bin/sp_ctrl
sleep 5

echo -e "Y" | ora_cleansp splex/splex@pdb1
cd -
$SP_HOME/bin/sp_cop -u2100 &
sleep 7

ssh oracle@${TARGET_HOST} '. /home/oracle/.bash_profile;cd $SP_HOME/bin;echo "shutdown" | $SP_HOME/bin/sp_ctrl;sleep 5;echo -e "Y" | ora_cleansp splex/splex@pdb1;'
sleep 2

ssh oracle@${TARGET_HOST} '. /home/oracle/.bash_profile;$SP_HOME/bin/sp_cop -u2100' &
sleep 5

echo "activate config my_config_oracle.cfg" | $SP_HOME/bin/sp_ctrl
sleep 5

echo "show config" | $SP_HOME/bin/sp_ctrl
sleep 5



