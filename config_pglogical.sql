/* Step 1) Create a table on Server 1 and Server 2 */

--Please note that the schema must be identical in both servers before replication begins

--on Server 1
create table dummy_x(
id numeric primary key not null,
name text not null,
event_date timestamp default current_timestamp
);

--on Server 2
create table dummy_x(
id numeric primary key not null,
name text not null,
event_date timestamp default current_timestamp
);
 

/* Step 2) Create the provider nodes: */

--on Server 1
select pglogical.create_node(node_name := 'primary1', ' host= <server1>.postgres.database.azure.com port=5432 dbname=postgres user=demo password=<pwd>');

--on Server 2
select pglogical.create_node(node_name := 'primary2', dsn := ' host=<server2>.postgres.database.azure.com port=5432 dbname=postgres user=demo password=<pwd>' );
 

/* Step 3) Add table(s) to the replication set in both servers */

--on Server 1
SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);

--on Server 2
SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);
 

/* Step 4) Create the subscriber on Server 2  */

--on Server 2
select pglogical.create_subscription (
subscription_name := 'primary2-sub',
replication_sets := array['default/<replicationsetname>'],
synchronize_data := true,
forward_origins := '{}'
provider_dsn := 'host=<server1>.postgres.database.azure.com port=5432 dbname=postgres user=demo password=<pwd>');
 

/* Step 5) Verify the subscription status on Server 1 */

--on Server 1
SELECT subscription_name, status FROM pglogical.show_subscription_status();
 

/* Step 6) Test the replication from Server 1 to Server 2 */

--on Server 1
INSERT INTO dummy_x (id, name, event_date)
VALUES (1, 'Sample Name x 1', DEFAULT),
       (3, 'Sample Name x 3', DEFAULT),
       (5, 'Sample Name x 5', DEFAULT);

--On Server 2
Select * from dummy_x;
--3 rows selected
 

/* Step 7)  Configure Server1 as subscriber of Server 2  */

--on Server 1
 select pglogical.create_subscription (
 subscription_name := 'primary1-sub',
 replication_sets := array['default/<replicationsetname>'],
 synchronize_data := false,
 forward_origins := '{}'
 provider_dsn := 'host=<server2>.postgres.database.azure.com port=5432  dbname=postgres user=demo password=<pwd>');
 

/* Step 8) Test the replication from Server 2 to Server 1 */

--on Server 2
INSERT INTO dummy_x (id, name, event_date)
VALUES (2, 'Sample Name x 2', DEFAULT),
       (4, 'Sample Name x 4', DEFAULT),
       (6, 'Sample Name x 6', DEFAULT);


--on Server 2 and Server 1
Select * from dummy_x order by id asc;
-- 6 rows selected