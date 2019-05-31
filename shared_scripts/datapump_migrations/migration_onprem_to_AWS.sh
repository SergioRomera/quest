. ./config.env
. ./common.sh

rm -fR ./log/*
# Delete dmp file if exist in SOURCE
if [ -f $ORACLE_HOME/datapump/${SOURCE_EXPORT_FILE} ]; then
  echo "Deleting $ORACLE_HOME/datapump/${SOURCE_EXPORT_FILE} file...." 
  rm $ORACLE_HOME/datapump/${SOURCE_EXPORT_FILE}
fi

verify ()
{
  if [ $r -eq 0 ]; then
    info "$msg: OK"
  else
    error "$msg: KO. Error: $r"
  fi
}

#info "*************************************************************"
#info "***                                                       ***"
#info "***    Quest Database Migration from on premise to AWS    ***"
#info "***                                                       ***"
#info "*************************************************************"

#figlet soft
cat banner.txt

echo "exit" | sqlplus -s ${TARGET_MASTER_USER}/${TARGET_MASTER_PASSWORD}@${TARGET_INSTANCE}    @10-[target]_create_user.sql ${TARGET_SCHEMA} ${TARGET_DATA_PUMP_DIR_PATH} > ./log/10.log
r=$?
msg="Create target user"
verify $msg $r

echo "exit" | sqlplus -s ${SOURCE_MASTER_USER}/${SOURCE_MASTER_PASSWORD}@${SOURCE_INSTANCE} @20-[source]_grant_source_user_privileges.sql ${SOURCE_EXPORT_USER} > ./log/20.log
r=$?
msg="Grant source privileges"
verify $msg $r

. ./25-[target]_stop_post.sh > ./log/25.log
r=$?
msg="Stop post"
verify $msg $r

. ./26-[target]_status.sh > ./log/26.log
. ./27-[source]_activate_config.sh > ./log/27.log
r=$?
msg="Activate Shareplex config"
verify $msg $r

. ./28-[source]_swithlog.sh > ./log/28.log
r=$?
msg="Switch log in source database"
verify $msg $r

. ./29-[source]_confirm_scn.sh > ./log/29.log
r=$?
msg="Take SCN in source database to sync"
verify $msg $r

. ./30-[source]_export_data_pump_flashback.sh > ./log/30.log
r=$?
msg="Export datapump"
verify $msg $r

info "Insert some data in source database..... You have 10 seconds"
sleep 10

#info "Export datapump running...."
#echo "exit" | sqlplus -s ${SOURCE_EXPORT_USER}/${SOURCE_EXPORT_USER}@${SOURCE_INSTANCE} @30-[source]_export_data_pump.sql             ${SOURCE_EXPORT_FILE} ${SOURCE_DATA_PUMP_DIR_NAME} ${SOURCE_SCHEMA} > ./log/03.log
#r=$?
#msg="Export source datapump"
#verify $msg $r

. ./35-[source]_insert_line.sh > ./log/35.log

echo "exit" | sqlplus -s ${SOURCE_EXPORT_USER}/${SOURCE_EXPORT_USER}@${SOURCE_INSTANCE} @40-[source]_create_dblink.sql                ${TARGET_MASTER_USER} ${TARGET_MASTER_PASSWORD} ${TARGET_HOST} ${TARGET_DB} > ./log/40.log
r=$?
msg="Create dblink"
verify $msg $r

echo "exit" | sqlplus -s ${TARGET_MASTER_USER}/${TARGET_MASTER_PASSWORD}@${TARGET_INSTANCE}    @80-[target]_cleanup_datapump_file.sql        ${TARGET_DATA_PUMP_DIR_NAME} ${TARGET_EXPORT_FILE} > ./log/80.log
r=$?
msg="Cleanup target datapump"
verify $msg $r

info "File transfer running..."
echo "exit" | sqlplus -s ${SOURCE_EXPORT_USER}/${SOURCE_EXPORT_USER}@${SOURCE_INSTANCE} @50-[source]_file_transfer.sql                ${SOURCE_DATA_PUMP_DIR_NAME} ${SOURCE_EXPORT_FILE} ${TARGET_DATA_PUMP_DIR_NAME} ${TARGET_EXPORT_FILE}  > ./log/50.log
r=$?
msg="File transfer"
verify $msg $r

info "Import data pump running..."
echo "exit" | sqlplus -s ${TARGET_MASTER_USER}/${TARGET_MASTER_PASSWORD}@${TARGET_INSTANCE}    @60-[target]_import_data_pump.sql             ${TARGET_EXPORT_FILE} ${TARGET_DATA_PUMP_DIR_NAME} ${TARGET_SCHEMA} > ./log/60.log
r=$?
msg="Import data pump"
verify $msg $r

. ./65-[target]_reconciliate_queue.sh  > ./log/65.log
r=$?
msg="Reconcile queue"
verify $msg $r

. ./66-[target]_start_post.sh  > ./log/66.log
r=$?
msg="Start post"
verify $msg $r

echo "exit" | sqlplus -s ${SOURCE_EXPORT_USER}/${SOURCE_EXPORT_USER}@${SOURCE_INSTANCE} @70-[source]_cleanup_datapump_file.sql        ${SOURCE_DATA_PUMP_DIR_NAME} ${SOURCE_EXPORT_FILE} > ./log/70.log
r=$?
msg="Cleanup source data pump"
verify $msg $r


