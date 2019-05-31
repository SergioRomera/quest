sqlplus ${SOURCE_MASTER_USER}/${SOURCE_MASTER_PASSWORD}@cdb1 <<EOF
alter system archive log current;
EOF

