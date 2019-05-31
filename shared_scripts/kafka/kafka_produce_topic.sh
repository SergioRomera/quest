cd /tmp/kafka_2.12-2.2.0

#Produce topic
echo "test local machine"  | bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

cd -
