drop user kafka cascade;

create user kafka identified by kafka;
grant dba to kafka;

CREATE TABLE KAFKA.kafka_table
(
  id           NUMBER,
  description  VARCHAR2(100)
);


ALTER TABLE KAFKA.kafka_table ADD (
  PRIMARY KEY
  (id)
  ENABLE VALIDATE);
