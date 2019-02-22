. /vagrant_config/install.env

sh /vagrant_scripts/prepare_u01_disk.sh

sh /vagrant_scripts/install_os_packages.sh

echo "******************************************************************************"
echo "Set root and oracle password and change ownership of /u01." `date`
echo "******************************************************************************"
echo -e "${ROOT_PASSWORD}\n${ROOT_PASSWORD}" | passwd
echo -e "${ORACLE_PASSWORD}\n${ORACLE_PASSWORD}" | passwd oracle
chown -R oracle:oinstall /u01
chmod -R 775 /u01

sh /vagrant_scripts/configure_hosts_base.sh

sh /vagrant_scripts/configure_chrony.sh

su - oracle -c 'sh /vagrant/scripts/oracle_user_environment_setup.sh'
. /home/oracle/scripts/setEnv.sh

sh /vagrant_scripts/configure_hostname.sh

su - oracle -c 'sh /vagrant_scripts/oracle_db_software_installation.sh'

echo "******************************************************************************"
echo "Run DB root scripts." `date` 
echo "******************************************************************************"
sh ${ORA_INVENTORY}/orainstRoot.sh
sh ${ORACLE_HOME}/root.sh

su - oracle -c 'sh /vagrant/scripts/oracle_create_database.sh'

echo "******************************************************************************"
echo "Install Quest Shareplex." `date` 
echo "******************************************************************************"
su - oracle -c 'sh /vagrant_scripts/shareplex_install.sh'

echo "******************************************************************************"
echo "Quest Shareplex queue configuration." `date`
echo "******************************************************************************"
su - oracle -c 'cat > /u01/app/quest/vardir/2100/config/my_config_oracle.cfg <<EOF
datasource:o.pdb1
#source tables      target tables           routing map
expand test.%      test.%                   ol7-121-splex2@o.pdb1
EOF'

su - oracle -c 'cat > /u01/app/quest/vardir/2100/config/my_config_postgres.cfg <<EOF
datasource:o.pdb1
#source tables      target tables           routing map
expand test.%      test.%                   ol7-postgresql106-splex3@r.testdb
EOF'

echo "******************************************************************************"
echo "Quest Shareplex configuration." `date`
echo "******************************************************************************"
su - oracle -c 'cd /u01/app/quest/shareplex9.2/bin | echo -e "activate config my_config_oracle.cfg" | sp_ctrl'
#su - oracle -c 'cd /u01/app/quest/shareplex9.2/bin | echo -e "activate config my_config_postgres.cfg" | sp_ctrl'

echo "******************************************************************************"
echo "Quest Shareplex show configuration." `date`
echo "******************************************************************************"
su - oracle -c 'cd /u01/app/quest/shareplex9.2/bin | echo -e "show\nstatus" | sp_ctrl'

echo "******************************************************************************"
echo "Set the PDB to auto-start." `date`
echo "******************************************************************************"
su - oracle -c 'sh /vagrant_scripts/shareplex_create_test_table.sh'
