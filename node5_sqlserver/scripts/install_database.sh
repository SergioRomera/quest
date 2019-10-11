#! /bin/sh

. /vagrant_config/install.env

echo "Downloadind AdventureWorks database"
mkdir /tmp/AdventureWorks
cd /tmp/AdventureWorks
wget -q https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip
unzip AdventureWorks-oltp-install-script.zip
#Change file charset 
iconv -f utf-16le -t utf-8 instawdb.sql -o install_tmp.sql
sed -e 's/C:\\Samples\\AdventureWorks\\/\/tmp\/AdventureWorks\//g' install_tmp.sql >install_sed.sql
echo "Download AdventureWorks finished"

echo "Downloading AdventureWorksDW database"
mkdir /tmp/AdventureWorksDW
cd /tmp/AdventureWorksDW
wget -q https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW-data-warehouse-install-script.zip
unzip AdventureWorksDW-data-warehouse-install-script.zip
#Change file charset
iconv -f utf-16le -t utf-8 instawdbdw.sql -o installdw_tmp.sql
sed -e 's/C:\\Samples\\AdventureWorksDW\\/\/tmp\/AdventureWorksDW\//g' installdw_tmp.sql >installdw_sed.sql
sed -i 's/CREATE TABLE \[/SET QUOTED_IDENTIFIER ON;\nCREATE TABLE [/g' installdw_sed.sql
echo "Download AdventureWorksDW finished"

echo "Creating AdventureWorks database..."
cd /tmp/AdventureWorks
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -i install_sed.sql
echo "AdventureWorks database created."

echo "Creating AdventureWorksDW database..."
cd /tmp/AdventureWorksDW
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -i installdw_sed.sql
echo "AdventureWorks databaseDW created."
