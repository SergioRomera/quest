. /vagrant_config/install.env

echo ""
echo "******************************************************************************"
echo "Unzip database software." `date`
echo "******************************************************************************"
mkdir /u01/software/
cd /u01/software/

echo "******************************************************************************"
echo "Oracle Binaries download" `date`
echo "******************************************************************************"
if [ -f $ORACLE_BINARIES_INSTALL/$ORACLE_SOFTWARE1 ]; then
  echo "Oracle binary 1 found"
else
  echo "Oracle binary 1 not found"
  echo "Download $ORACLE_SOFTWARE1 in progress..."
  cd $ORACLE_BINARIES_INSTALL
  wget -q $ORACLE_BINARY_DOWNLOAD1
fi

if [ -f $ORACLE_BINARIES_INSTALL/$ORACLE_SOFTWARE2 ]; then
  echo "Oracle binary 2 found"
else
  echo "Oracle binary 2 not found"
  echo "Download $ORACLE_SOFTWARE2 in progress..."
  cd $ORACLE_BINARIES_INSTALL
  wget -q $ORACLE_BINARY_DOWNLOAD2
fi

echo "******************************************************************************"
echo "Unzip Oracle database software" `date`
echo "******************************************************************************"
unzip -oq "${ORACLE_BINARIES_INSTALL}/${ORACLE_SOFTWARE1}"
unzip -oq "${ORACLE_BINARIES_INSTALL}/${ORACLE_SOFTWARE2}"
cd database

echo ""
echo "******************************************************************************"
echo "Do database software-only installation." `date`
echo "******************************************************************************"
./runInstaller -ignorePrereq -waitforcompletion -silent \
        -responseFile /u01/software/database/response/db_install.rsp \
        oracle.install.option=INSTALL_DB_SWONLY \
        ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
        UNIX_GROUP_NAME=oinstall \
        INVENTORY_LOCATION=${ORA_INVENTORY} \
        SELECTED_LANGUAGES=${ORA_LANGUAGES} \
        ORACLE_HOME=${ORACLE_HOME} \
        ORACLE_BASE=${ORACLE_BASE} \
        oracle.install.db.InstallEdition=EE \
        oracle.install.db.DBA_GROUP=dba \
        oracle.install.db.BACKUPDBA_GROUP=dba \
        oracle.install.db.DGDBA_GROUP=dba \
        oracle.install.db.KMDBA_GROUP=dba \
        SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
        DECLINE_SECURITY_UPDATES=true
