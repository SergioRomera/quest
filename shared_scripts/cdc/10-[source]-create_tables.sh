
. ./config.env

sqlplus ${SOURCE_SCHEMA}/${SOURCE_SCHEMA_PASSWORD}@${SOURCE_INSTANCE} <<EOF
--DROP TABLE cdc;

CREATE TABLE cdc
(
  id number not null,
  description varchar2(100) null,
  CONSTRAINT pk_cdc PRIMARY KEY (id)
);

CREATE TABLE cdc2
(
  id number not null,
  description varchar2(100) null,
  CONSTRAINT pk_cdc2 PRIMARY KEY (id)
);


exit
EOF

