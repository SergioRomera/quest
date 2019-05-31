sleep 5
ssh -t oracle@${TARGET_HOST} 'echo -e "show\nqstatus\n" | /u01/app/quest/shareplex9.2/bin/sp_ctrl'
