. /vagrant_config/install.env

sh /vagrant_scripts/prepare_u01_disk.sh

sh /vagrant/scripts/install_os_packages.sh

sh /vagrant_scripts/configure_hosts_base.sh

sh /vagrant_scripts/configure_chrony.sh

#. /home/oracle/scripts/setEnv.sh

sh /vagrant/scripts/configure_hostname.sh

sh /vagrant/scripts/install_mssql.sh

