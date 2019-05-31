echo -e "activate config my_config_AWS_oracle.cfg\n" | /u01/app/quest/shareplex9.2/bin/sp_ctrl
sleep 5
echo -e "show\nqstatus\nshow config\n" | /u01/app/quest/shareplex9.2/bin/sp_ctrl
