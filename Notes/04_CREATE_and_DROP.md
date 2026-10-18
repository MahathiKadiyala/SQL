# Chapter 4: DDL Commands (CREATE, ALTER, DROP, TRUNCATE, RENAME)

## 1. Topic Title
**Data Definition Language (DDL): Creating, Modifying, Truncating, and Dropping Tables**

---

## 2. Simple Definition
- **DDL (Data Definition Language)**: Statements used to build, alter, and delete database structures (tables, views, indexes).
- **`CREATE TABLE`**: Instantiates a new table structure with specified column specifications and constraints.
- **`ALTER TABLE`**: Modifies an existing table's schema (adding columns, modifying datatypes, dropping columns, or attaching new constraints) without destroying existing data.
- **`RENAME`**: Renames a table or column to a new identifier.
- **`TRUNCATE TABLE`**: Deletes all rows from a table rapidly while keeping the table structure intact.
- **`DROP TABLE`**: Completely destroys the table structure, its columns, constraints, indexes, and all stored data.

---

## 3. Why It Is Used
- **Schema Evolution**: Application requirements change over time. `ALTER TABLE` allows developers to add new features (e.g., adding an `is_active` flag) without rebuilding the database from scratch.
- **Storage Cleanup**: `TRUNCATE` offers an ultra-fast way to reset testing or staging tables without generating massive undo/redo transaction logs.
- **Resource Decommissioning**: `DROP TABLE` removes obsolete entities and frees up tablespace storage.

---

## 4. Syntax
```sql
-- 1. CREATE TABLE
CREATE TABLE PROJECT_TEAMS (
    project_id      NUMBER(5) PRIMARY KEY,
    project_name    VARCHAR2(100) NOT NULL,
    start_date      DATE DEFAULT SYSDATE
);

-- 2. ALTER TABLE - ADD Column
ALTER TABLE PROJECT_TEAMS ADD (
    budget          NUMBER(12, 2) DEFAULT 0 NOT NULL,
    status          VARCHAR2(20) DEFAULT 'PLANNING'
);

-- 3. ALTER TABLE - MODIFY Column Datatype or Nullability
ALTER TABLE PROJECT_TEAMS MODIFY (
    project_name    VARCHAR2(150)
);

-- 4. ALTER TABLE - RENAME Column
ALTER TABLE PROJECT_TEAMS RENAME COLUMN status TO project_status;

-- 5. ALTER TABLE - DROP Column
ALTER TABLE PROJECT_TEAMS DROP COLUMN budget;

-- 6. RENAME TABLE
RENAME PROJECT_TEAMS TO ACTIVE_PROJECTS;

-- 7. TRUNCATE TABLE (Removes all rows, structure stays)
TRUNCATE TABLE ACTIVE_PROJECTS;

-- 8. DROP TABLE (Destroys rows AND structure)
DROP TABLE ACTIVE_PROJECTS CASCADE CONSTRAINTS;
```

---

## 5. Explanation of the Syntax
1. **Implicit Commit in Oracle DDL**:
   - Every single DDL statement issues an implicit `COMMIT` before execution and an implicit `COMMIT` immediately after.
   - You **CANNOT** issue a `ROLLBACK` to undo an `ALTER TABLE`, `TRUNCATE TABLE`, or `DROP TABLE`.
2. **`CASCADE CONSTRAINTS`**:
   - If other tables reference this table via foreign keys, a simple `DROP TABLE` will fail. Adding `CASCADE CONSTRAINTS` removes the foreign key definitions automatically before dropping the table.
3. **`TRUNCATE` vs `DELETE`**:
   - `TRUNCATE` deallocates the table's storage extents and resets the High Water Mark (HWM). It does not fire row-level triggers and does not generate undo logs for each row, making it thousands of times faster than `DELETE`.

---

## 6. Example Query: Table Lifecycle
```sql
-- Create a temporary demo table
CREATE TABLE LAB_EXPERIMENTS (
    exp_id      NUMBER(4) PRIMARY KEY,
    exp_name    VARCHAR2(50) NOT NULL,
    run_date    DATE
);

-- Add column
ALTER TABLE LAB_EXPERIMENTS ADD (result_score NUMBER(5, 2));

-- Insert sample rows
INSERT INTO LAB_EXPERIMENTS VALUES (1, 'Acid-Base Titration', SYSDATE, 94.5);
INSERT INTO LAB_EXPERIMENTS VALUES (2, 'Spectrophotometry', SYSDATE, 88.0);
COMMIT;

-- Truncate to wipe data quickly
TRUNCATE TABLE LAB_EXPERIMENTS;

-- Drop table cleanly
DROP TABLE LAB_EXPERIMENTS;
```

---

## 7. Sample Input Table: Before & After `TRUNCATE`
### `LAB_EXPERIMENTS` (Before TRUNCATE)
| EXP_ID | EXP_NAME | RUN_DATE | RESULT_SCORE |
| :--- | :--- | :--- | :--- |
| 1 | Acid-Base Titration | 18-OCT-2026 | 94.5 |
| 2 | Spectrophotometry | 18-OCT-2026 | 88.0 |

---

## 8. Expected Output (After TRUNCATE)
Querying the table after TRUNCATE:
```sql
SELECT * FROM LAB_EXPERIMENTS;
```
| EXP_ID | EXP_NAME | RUN_DATE | RESULT_SCORE |
| :--- | :--- | :--- | :--- |
| *(no rows selected)* | | | |

Querying the table after DROP:
```sql
SELECT * FROM LAB_EXPERIMENTS;
-- ORA-00942: table or view does not exist
```

---

## 9. Step-by-Step Explanation: DELETE vs. TRUNCATE vs. DROP
Here is the definitive comparison essential for both day-to-day database development and technical interviews:

| Feature | `DELETE` | `TRUNCATE` | `DROP` |
| :--- | :--- | :--- | :--- |
| **Command Type** | **DML** (Data Manipulation) | **DDL** (Data Definition) | **DDL** (Data Definition) |
| **What it removes** | Specific rows (or all rows if no `WHERE`) | All rows only | All rows **AND** table schema |
| **WHERE Clause** | **Supported** (`WHERE id = 5`) | **Not supported** (wipes table) | **Not applicable** |
| **Rollback / Undo** | Can be rolled back via `ROLLBACK` | **Cannot be rolled back** in Oracle | **Cannot be rolled back** |
| **Execution Speed** | Slower (logs every row deletion) | Ultra-fast (resets storage pointers) | Instantaneous |
| **Triggers** | Fires `ON DELETE` database triggers | **Does not fire triggers** | Does not fire triggers |
| **Table Structure** | Stays intact | Stays intact | **Completely deleted** |
| **Storage Space** | Keeps allocated blocks for reuse | Deallocates space back to tablespace | Frees all allocated space |

---

## 10. Common Mistakes
1. **Trying to `TRUNCATE` a Parent Table**: If a child table has a foreign key pointing to the table, Oracle throws `ORA-02266: unique/primary keys in table referenced by enabled foreign keys`. You must disable or drop the foreign key constraint first.
2. **Forgetting that DDL Commits Pending Transactions**: If you insert 10 rows into `EMPLOYEES` without committing, and then run `CREATE TABLE test (...)`, Oracle automatically commits your pending employee rows!
3. **Dropping a Column That is Part of a Multi-Column Constraint**: Must drop or disable the composite constraint first.
4. **Modifying Column Datatype with Incompatible Existing Data**: You cannot convert a `VARCHAR2` column containing letters into `NUMBER` if rows are already present.

---

## 11. Interview Questions
1. **Can a `TRUNCATE` statement be rolled back in Oracle?**
   - *Answer*: No. Because `TRUNCATE` is a DDL command, it executes an implicit commit before and after the operation, resetting the table storage without recording row-by-row undo data.
2. **What is the difference between `DELETE` and `TRUNCATE`?**
   - *Answer*: `DELETE` is a DML command that can filter rows with `WHERE`, generates undo records, can be rolled back, and fires triggers. `TRUNCATE` is a DDL command that wipes all rows instantly, cannot use `WHERE`, resets high water mark, cannot be rolled back, and does not fire triggers.
3. **How do you drop a table if other tables reference it via foreign keys?**
   - *Answer*: Use `DROP TABLE table_name CASCADE CONSTRAINTS;`.
4. **Can you add a `NOT NULL` column to a table that already contains rows?**
   - *Answer*: Yes, provided you specify a `DEFAULT` value for the column (e.g., `ALTER TABLE tbl ADD status VARCHAR2(10) DEFAULT 'ACTIVE' NOT NULL;`).

---

## 12. Short Summary
- `CREATE` builds schemas; `ALTER` evolves columns and constraints; `DROP` destroys the entire table.
- `TRUNCATE` resets table contents instantly, preserving the structure for fresh inserts.
- All DDL statements in Oracle commit immediately and cannot be undone using `ROLLBACK`.
