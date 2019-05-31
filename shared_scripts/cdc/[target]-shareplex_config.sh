
. ./config.env


ssh oracle@${TARGET_HOST} 'echo -e "stop post\n" | /u01/app/quest/shareplex9.2/bin/sp_ctrl'

sleep 7

ssh oracle@${TARGET_HOST} 'echo -e "set param SP_OPO_TRACK_PREIMAGE 0\nstart post\n" | /u01/app/quest/shareplex9.2/bin/sp_ctrl'


