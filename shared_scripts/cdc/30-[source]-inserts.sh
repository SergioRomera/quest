
. ./config.env

sqlplus ${SOURCE_SCHEMA}/${SOURCE_SCHEMA_PASSWORD}@${SOURCE_INSTANCE} <<EOF

--alter table cdc drop column description2;

insert into cdc values (1, 'Test1');
insert into cdc values (2, 'Test2');
insert into cdc values (3, 'Test3');
commit;

insert into cdc values (4, 'test4');
commit;

delete from cdc where id=4;
commit;

update cdc set description='333' where id=3;
update cdc set description='222' where id=2;
update cdc set description='111' where id=1;
commit;

--alter table cdc add description2 varchar2(10) null;
--insert into cdc values (10,'Test10','Test10');
--commit;


-- *******************************************************
insert into cdc2 values (10, 'Test10');
insert into cdc2 values (20, 'Test20');
insert into cdc2 values (30, 'Test30');
commit;

exit
EOF
