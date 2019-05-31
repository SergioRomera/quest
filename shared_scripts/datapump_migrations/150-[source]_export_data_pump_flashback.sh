#Connect to surce database
#impdp quest/questuser@//aws-db-instance.cixdbkviwolw.eu-west-3.rds.amazonaws.com:1521/quest \
#     directory=data_pump_dir \
#     dumpfile=sample_copied.dmp \
#     logfile=logfile.log

scn=`head -1 current_scn.log`

mkdir ${SOURCE_DATA_PUMP_DIR_PATH}

sqlplus ${SOURCE_MASTER_USER}/${SOURCE_MASTER_PASSWORD}@pdb1 <<EOF
drop user $SOURCE_EXPORT_USER cascade;
create user $SOURCE_EXPORT_USER identified by $SOURCE_EXPORT_USER;
grant dba to $SOURCE_EXPORT_USER;

drop directory $SOURCE_DATA_PUMP_DIR_NAME;
create directory $SOURCE_DATA_PUMP_DIR_NAME as '$SOURCE_DATA_PUMP_DIR_PATH';

EOF

expdp ${SOURCE_MASTER_USER}/${SOURCE_MASTER_PASSWORD}@pdb1 schemas=${SOURCE_SCHEMA} \
  directory=data_pump_dir_sample \
  dumpfile=sample.dmp \
  logfile=sample.log \
  parallel=2 \
  compression=all \
  flashback_scn=$scn
  
