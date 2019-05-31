
. ./config.env

ssh oracle@${TARGET_HOST} ". /home/oracle/.bash_profile;sqlplus ${TARGET_SCHEMA}/${TARGET_SCHEMA_PASSWORD}@${TARGET_INSTANCE} << EOF
DROP TABLE cdc;
DROP TABLE cdc2;
EOF"

sqlplus ${SOURCE_SCHEMA}/${SOURCE_SCHEMA_PASSWORD}@${SOURCE_INSTANCE} <<EOF
DROP TABLE cdc;
DROP TABLE cdc2;
EOF

ssh oracle@${TARGET_HOST} ". /home/oracle/.bash_profile;sqlplus ${TARGET_CDC_SCHEMA_USER}/${TARGET_CDC_SCHEMA_PASSWORD}@${TARGET_INSTANCE} << EOF
DROP TABLE cdc;
DROP TABLE cdc2;
EOF"

