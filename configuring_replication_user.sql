/*
 This is a script to support the configuration of a dedidated user
 to establish logical replication between PostgreSQL servers
*/
 
-- 1. Create the user
CREATE USER replication_user WITH PASSWORD 'Test12345678910A';
GRANT azure_pg_admin to replication_user;
 
-- 2. Grant necessary attributes for replication connection
ALTER ROLE replication_user WITH REPLICATION LOGIN;
 
-- 3. Grant connection to the specific database(s) being replicated
GRANT CONNECT ON DATABASE postgres TO replication_user;
 
-- 4. Grant privileges for creating publications (if this user will create/alter publications)
-- In Azure, if you need FOR ALL TABLES or FOR ALL TABLES IN SCHEMA,
-- `replication_user` might need to be a member of `azure_pg_admin`.
-- If not, ensure the user owns the tables being published.
-- For simpler setup with Azure's managed environment, often the initial `admin`
-- user creates the publication.
GRANT CREATE ON DATABASE postgres TO replication_user;
 
-- 5. Grant SELECT on tables for publishing
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replication_user; -- Or your specific schema
 
-- 6. Grant DML permissions on tables for subscribing (applying changes)
-- This assumes you use run_as_owner = true for simplicity.
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public TO replication_user; -- Or your specific schema
 
 
-- 7. Grant permission to create subscriptions (PostgreSQL 15+)
-- If on PG 14 or older, or if Azure still requires it for the initial CREATE SUBSCRIPTION,
-- you might need to use the `azure_pg_admin` user for the CREATE SUBSCRIPTION command itself,
-- then optionally ALTER SUBSCRIPTION OWNER TO replication_user;
GRANT pg_create_subscription TO replication_user;