### **Managing Schema Changes in a Multi-Master Setup**

Making schema changes in a bi-directional replication setup requires careful planning to avoid disrupting replication or causing data inconsistencies. Here's a disciplined, phased approach to adding a new column using native logical replication.

---

### **1. Plan and Prepare**

Before you begin, ensure both servers are running **compatible PostgreSQL versions**. While native logical replication can handle some schema drift, having identical versions and a clear plan is the best way to prevent unexpected issues.

---

### **2. Perform the Schema Change on One Server**

Start by adding the new column to just one of your servers, for example, Server A.

```sql
ALTER TABLE your_table_name ADD COLUMN new_column_name data_type;
