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

#sudo yum install java -y

cd /tmp
rm kafka_2.12-2.2.0.tgz
rm -Rf kafka_2.12-2.2.0
rm -Rf kafka-logs
rm -Rf zookeeper

#Kafka download
#wget http://apache.crihan.fr/dist/kafka/2.2.0/kafka_2.12-2.2.0.tgz
wget https://www.dropbox.com/s/c9jar5zcjl8cdhf/kafka_2.12-2.2.0.tgz > /dev/null 2>&1
r=$?
msg="Download kafka binaries"
verify $msg $r


tar -xzf kafka_2.12-2.2.0.tgz > /dev/null 2>&1
r=$?
msg="untar kafka binaires"
verify $msg $r


ssh oracle@ol7-121-splex1 'echo -e "deactivate config kafka.cfg\n" | /u01/app/quest/shareplex9.2/bin/sp_ctrl' > /dev/null 2>&1
r=$?
msg="Deactivate kafka shareplex config"
verify $msg $r
sleep 5

ssh oracle@ol7-121-splex1 'echo -e "activate config kafka.cfg\n" | /u01/app/quest/shareplex9.2/bin/sp_ctrl' > /dev/null 2>&1
r=$?
msg="Activate kafka shareplex config"
verify $msg $r
sleep 5

cd kafka_2.12-2.2.0

#Start zookeeper
bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
r=$?
msg="Start zookeeper server"
verify $msg $r

sleep 10

#Start kafka
bin/kafka-server-start.sh config/server.properties > /dev/null 2>&1 &
r=$?
msg="Start kafka server"
verify $msg $r

sleep 10

#Create topic
#bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test  > /dev/null 2>&1 &

#List topic
info "Listing kafka topics"
bin/kafka-topics.sh --list --bootstrap-server localhost:9092  > /dev/null 2>&1 &

#Produce topic
#echo "test local machine"  | bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

#Consume topic
#bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning

cd /tmp/kafka_2.12-2.2.0

