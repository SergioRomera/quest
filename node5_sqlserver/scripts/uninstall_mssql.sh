#! /bin/sh

#Uninstall
##########

sudo systemctl stop mssql-server

#Delete previous tools
#sudo yum remove unixODBC-utf16 unixODBC-utf16-devel
sudo yum remove -y mssql-tools unixODBC-devel

sudo yum remove -y mssql-server
