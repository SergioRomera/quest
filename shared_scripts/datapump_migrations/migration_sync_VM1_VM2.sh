#
# Description: Migration with shareplex from VM1 to VM2
# Shareplex: Migration with reconcile command
# Date: 10/05/2019
# Author: Sergio ROMERA


. ./config.env
. ./common.sh

rm -fR ./log/*
# Delete dmp file if exist in SOURCE
if [ -f $ORACLE_HOME/datapump/${SOURCE_EXPORT_FILE} ]; then
  echo "Deleting $ORACLE_HOME/datapump/${SOURCE_EXPORT_FILE} file...." 
  rm $ORACLE_HOME/datapump/${SOURCE_EXPORT_FILE}
fi
ssh oracle@${TARGET_HOST} rm -f "${TARGET_DATA_PUMP_DIR_PATH}/${TARGET_EXPORT_FILE}"
ssh oracle@${TARGET_HOST} mkdir "${TARGET_DATA_PUMP_DIR_PATH}"

verify ()
{
  if [ $r -eq 0 ]; then
    info "$msg: OK"
  else
    error "$msg: KO. Error: $r"
  fi
}

. ./110-[target]_stop_post.sh > ./log/110.log
. ./115-[target]_status.sh > ./log/115.log
. ./120-[source]_activate_config.sh > ./log/120.log
. ./130-[source]_swithlog.sh > ./log/130.log
. ./140-[source]_confirm_scn.sh > ./log/140.log
. ./145-[target]_drop_user.sh > ./log/145.log
. ./146-[target]_create_directory.sh > ./log/146.log
. ./150-[source]_export_data_pump_flashback.sh > ./log/150.log
. ./151-[source]_insert_line.sh > ./log/151.log
. ./152-[source]_create_dblink.sh > ./log/152.log
. ./153-[source]_file_transfer.sh > ./log/153.log
. ./155-[target]_import_data_pump.sh > ./log/155.log
. ./160-[target]_reconciliate_queue.sh  > ./log/160.log
. ./170-[target]_start_post.sh  > ./log/170.log

