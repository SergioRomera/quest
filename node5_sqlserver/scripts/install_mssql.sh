#! /bin/sh

. /vagrant_config/install.env

#Repo
sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo
sudo curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo

#Setup
# MSSQL_SA_PASSWORD=SQLServer01
# MSSQL_PID='Express'
# SQL_INSTALL_AGENT='y'
# SQL_INSTALL_USER='quest'
# SQL_INSTALL_USER_PASSWORD='Questuser01'

sudo yum install -y mssql-server

#ACCEPT_EULA=Y
sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
     MSSQL_PID=$MSSQL_PID \
     /opt/mssql/bin/mssql-conf setup accept-eula

systemctl restart mssql-server
systemctl status mssql-server

#Firewall
#sudo firewall-cmd --zone=public --add-port=1433/tcp --permanent
#sudo firewall-cmd --reload

#Install tools
sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel
#sudo yum install -y mssql-tools unixODBC-devel

# Optional new user creation:
if [ ! -z $SQL_INSTALL_USER ] && [ ! -z $SQL_INSTALL_USER_PASSWORD ]
then
  echo Creating user $SQL_INSTALL_USER
  /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U SA \
    -P $MSSQL_SA_PASSWORD \
    -Q "CREATE LOGIN [$SQL_INSTALL_USER] WITH PASSWORD=N'$SQL_INSTALL_USER_PASSWORD', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON; ALTER SERVER ROLE [sysadmin] ADD MEMBER [$SQL_INSTALL_USER]"
fi

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

