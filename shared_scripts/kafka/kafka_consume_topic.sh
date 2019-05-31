cd /tmp/kafka_2.12-2.2.0

#Consume topic
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic shareplex --from-beginning

cd -
