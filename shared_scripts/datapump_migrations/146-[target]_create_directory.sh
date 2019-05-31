ssh oracle@${TARGET_HOST} ". /home/oracle/.bash_profile;sqlplus -s ${TARGET_MASTER_USER}/${TARGET_MASTER_PASSWORD}@pdb1 <<EOF
drop directory $SOURCE_DATA_PUMP_DIR_NAME;
create directory $SOURCE_DATA_PUMP_DIR_NAME as '$SOURCE_DATA_PUMP_DIR_PATH';
exit
EOF"
