### **Managing Schema Changes in a bi-directional Setup in PostgreSQL**

Making schema changes in a bi-directional replication setup requires careful planning to avoid disrupting replication or causing data inconsistencies. Here's a disciplined, phased approach to adding a new column using native logical replication.

---

### **Plan and Prepare**

Before you begin, ensure both servers are running **compatible PostgreSQL versions**. While native logical replication can handle some schema drift, having identical versions and a clear plan is the best way to prevent unexpected issues.
In a bi-directional replication scenario, it does not matter what server you apply the DDL first. On a traditional uni-directional scenario, the recommended approach is to apply schema changes always on the subscriber first.

---

## **Scenario 1: Adding a new Nullable column**
Let's assume we have two Azure Database for PostgreSQL servers named Server 1 and Server 2.

####  1. Perform the schema change on Server 1

Start by adding the new column to just one of your servers. In this case, Server 1

```sql
ALTER TABLE your_table_name ADD COLUMN new_column_name data_type NULL;
```
This command will make the new column available on Server 1.

####  2. Perform the schema change on Server 2

```sql
ALTER TABLE your_table_name ADD COLUMN new_column_name data_type NULL;
```

####	3. Re-enable Replication:
If you paused replication, re-enable it after both servers have been updated to have the same schema.

#### Potential Issues to Consider:
1.	Replication Compatibility:
o	If you were to add a column on one server without making the corresponding change on the other server, logical replication would still work for existing rows, but you might encounter issues for any operations that reference the new column.
2.	Rows with the New Column:
o	Newly inserted rows after adding the column on Server 1 will reflect that new structure. Any inserts or updates referencing the new column may lead to complications if Server 2 is still unaware of that column or does not perform the same schema change.

## **Scenario 2: Adding a new NOT NULL column**

Let's assume we have two Azure Database for PostgreSQL servers named Server 1 and Server 2.

####  1. Add the new column as nullable first with a default in Server 1 and Server 2

Start by adding the new column on Server 1 and Server 2 with a default value, whenever possible.

```sql
ALTER TABLE your_table_name ADD COLUMN important_value numeric default 0 NULL;
```

####  2. Convert the column from NULL to NOT NULL

```sql
ALTER TABLE your_table_name MODIFY important_value numeric NOT NULL;
```

####	Re-enable Replication:
If you paused replication, re-enable it after both servers have been updated to have the same schema.

#### Potential Issues to Consider:

