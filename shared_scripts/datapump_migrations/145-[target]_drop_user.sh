ssh oracle@${TARGET_HOST} ". /home/oracle/.bash_profile;sqlplus -s ${TARGET_MASTER_USER}/${TARGET_MASTER_PASSWORD}@pdb1 <<EOF
drop user $TARGET_SCHEMA cascade;
exit
EOF"
