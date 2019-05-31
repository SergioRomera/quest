
. ./config.env

sqlplus ${SOURCE_SCHEMA}/${SOURCE_SCHEMA_PASSWORD}@${SOURCE_INSTANCE} <<EOF

delete from cdc;
commit;

delete from cdc2;
commit;

exit
EOF
