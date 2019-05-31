#! /bin/sh
. ./common.sh


verify ()
{
  if [ $r -eq 0 ]; then
    info "$msg: OK"
  else
    error "$msg: KO. Error: $r"
  fi
}

cat banner.txt

sqlplus system/manager@pdb1_vm1 <<EOF > /dev/null 2>&1
@kafka_create_user.sql
EOF
r=$?
msg="Create kafka sql user"
verify $msg $r

sh kafka_installation.sh

cd /vagrant_scripts/kafka/

info "Please, start consumer process and press ENTER to continue"
read a

sqlplus system/manager@pdb1_vm1 <<EOF > /dev/null 2>&1
@kafka_insert_into_table.sql
EOF
r=$?
msg="Insert in kafka sql user"
verify $msg $r

info "Execute next command to check kafka messages from oracle"
info "sh kafka_consume_topic.sh"
