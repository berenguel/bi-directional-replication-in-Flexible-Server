/* Step 1) Create Table, Publication & Replication Slot */
-- on Server 1
create table dummy_x(
id numeric primary key not null,
name text not null,
event_date timestamp default current_timestamp
);

create sequence sq_dummy_x
start with 1
increment by 2;

SELECT pg_create_logical_replication_slot('slot_pub_z1', 'pgoutput');
CREATE PUBLICATION pub_z1 FOR TABLE dummy_x;

--on Server 2
create table dummy_x(
id numeric primary key not null,
name text not null,
event_date timestamp default current_timestamp
);

create sequence sq_dummy_x
start with 2
increment by 2;

SELECT pg_create_logical_replication_slot('slot_pub_z2', 'pgoutput');
CREATE PUBLICATION pub_z2 FOR TABLE dummy_x;

/* Step 2) Create Subscriptions with Origin Filtering & NO DATA COPY*/

--on Server 1
CREATE SUBSCRIPTION sub_z2
CONNECTION 'host=<server2>.postgres.database.azure.com port=5432 user=demo dbname=postgres password=XXXXXXX'
PUBLICATION pub_z2
WITH (create_slot = false, slot_name='slot_pub_z2', origin = 'none', copy_data = false);

--on Server 2
CREATE SUBSCRIPTION sub_z1
CONNECTION 'host=<server1>.postgres.database.azure.com port=5432 user=demo dbname=postgres password=XXXXXX'
PUBLICATION pub_z1
WITH (create_slot = false, slot_name='slot_pub_z1', origin = 'none', copy_data = false);
 

/* Step 3) Test the replication */

--on Server 1
INSERT INTO dummy_x (id, name, event_date)
VALUES (nextval('sq_dummy_x'), 'Sample Name x 1', DEFAULT),
       (nextval('sq_dummy_x'), 'Sample Name x 3', DEFAULT),
       (nextval('sq_dummy_x'), 'Sample Name x 5', DEFAULT);

--on Server 2
INSERT INTO dummy_x (id, name, event_date)
VALUES (nextval('sq_dummy_x'), 'Sample Name x 2', DEFAULT),
       (nextval('sq_dummy_x'), 'Sample Name x 4', DEFAULT),
       (nextval('sq_dummy_x'), 'Sample Name x 6', DEFAULT);
 

/* Step 4) Validate the bi-directional setup */

--In both servers, run:

Select * from dummy_x order by id asc;