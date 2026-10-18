# Chapter 5: DML Commands (INSERT, UPDATE, DELETE) and Transactions

## 1. Topic Title
**Data Manipulation Language (DML) and Transaction Management (COMMIT, ROLLBACK, SAVEPOINT)**

---

## 2. Simple Definition
- **DML (Data Manipulation Language)**: Statements used to insert new records, modify existing records, or remove records from tables.
- **`INSERT`**: Appends one or more new rows into a table.
- **`UPDATE`**: Modifies the values of existing columns in one or more rows based on a filter condition.
- **`DELETE`**: Removes specific rows from a table based on a filter condition.
- **Transaction**: A logical unit of work consisting of one or more DML statements that must either all succeed (`COMMIT`) or all be undone (`ROLLBACK`) as a single atomic unit.

---

## 3. Why It Is Used
- **Dynamic Business Operations**: Every application continually creates new records (customer registrations, orders), updates statuses (shipping, payment approved), and removes stale data.
- **ACID Transaction Guarantees**:
  - **Atomicity**: All changes commit, or none do (e.g., money leaves Account A and arrives in Account B).
  - **Consistency**: The database transitions from one valid state to another, obeying all constraints.
  - **Isolation**: Concurrent transactions cannot view each other's uncommitted modifications (no dirty reads).
  - **Durability**: Once committed, changes survive system reboots or power outages.

---

## 4. Syntax
```sql
-- 1. INSERT a single row specifying all columns
INSERT INTO DEPARTMENTS (department_id, department_name, location)
VALUES (70, 'Data Science', 'Innovation Hub 2');

-- 2. INSERT specifying subset of columns (omitted columns take DEFAULT or NULL)
INSERT INTO STUDENTS (student_id, first_name, last_name, email, department_id)
VALUES (11, 'Lucas', 'Moura', 'lucas.moura@univ.edu', 10);

-- 3. INSERT MULTIPLE ROWS in Oracle using INSERT ALL
INSERT ALL
    INTO DEPARTMENTS VALUES (80, 'Biotechnology', 'Bio Wing')
    INTO DEPARTMENTS VALUES (90, 'Physics', 'Science Center')
SELECT * FROM DUAL;

-- 4. UPDATE one or more columns for specific rows
UPDATE EMPLOYEES
SET salary = salary * 1.10,
    commission_pct = NVL(commission_pct, 0) + 0.05
WHERE department_id = 10 AND job_title LIKE '%Engineer%';

-- 5. DELETE specific rows
DELETE FROM STUDENTS
WHERE gpa < 2.0;

-- 6. Transaction Control
COMMIT;      -- Permanently save changes
ROLLBACK;    -- Discard all changes made since the last COMMIT
SAVEPOINT sp1; -- Set intermediate checkpoint
ROLLBACK TO sp1; -- Rollback only up to the checkpoint
```

---

## 5. Explanation of the Syntax
1. **Column List in INSERT**: Always explicitly list the target columns `(col1, col2, ...)`. Relying on positional insertion without column names causes scripts to break whenever the table schema is altered later.
2. **The Critical `WHERE` Clause**:
   - `UPDATE table_name SET col = val;` **(NO WHERE CLAUSE)** will update **EVERY SINGLE ROW** in the table!
   - `DELETE FROM table_name;` **(NO WHERE CLAUSE)** will delete **EVERY SINGLE ROW** in the table!
3. **Transactions in Oracle**:
   - Oracle starts a new transaction automatically on the first executable SQL statement (such as `INSERT`, `UPDATE`, or `DELETE`).
   - The changes are visible only in your session.
   - You must explicitly issue `COMMIT;` to make them permanent and visible to other users.

---

## 6. Example Query: Safe Transaction Flow
Let's see a safe transaction that awards a 5% raise to IT employees, uses a savepoint, and safely commits:

```sql
-- Step 1: Start work and update salary
UPDATE EMPLOYEES
SET salary = salary * 1.05
WHERE department_id = 20;

-- Step 2: Establish a milestone savepoint
SAVEPOINT salary_bump_done;

-- Step 3: Attempt an experiment
UPDATE EMPLOYEES
SET job_title = 'Technician'
WHERE department_id = 20;

-- Step 4: Realize Step 3 was a mistake; rollback only to savepoint
ROLLBACK TO salary_bump_done;

-- Step 5: Commit the genuine salary increase permanently
COMMIT;
```

---

## 7. Sample Input Table: `EMPLOYEES` (Dept 20 only)
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | SALARY | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 103 | David | Clark | IT Manager | 88000.00 | 20 |
| 106 | Priya | Patel | Database Administrator | 78000.00 | 20 |
| 107 | James | Wilson | Systems Analyst | 60000.00 | 20 |

---

## 8. Expected Output (After the Transaction Commits)
Querying the updated employees:
```sql
SELECT employee_id, first_name, last_name, job_title, salary
FROM EMPLOYEES
WHERE department_id = 20;
```

| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | SALARY |
| :--- | :--- | :--- | :--- | :--- |
| 103 | David | Clark | IT Manager | 92400.00 |
| 106 | Priya | Patel | Database Administrator | 81900.00 |
| 107 | James | Wilson | Systems Analyst | 63000.00 |

*(Note: 88,000 * 1.05 = 92,400; 78,000 * 1.05 = 81,900; 60,000 * 1.05 = 63,000. Job titles were restored via ROLLBACK TO SAVEPOINT).*

---

## 9. Step-by-Step Explanation of How the Transaction Works
1. When `UPDATE` executes, Oracle places exclusive row-level locks on the affected rows (103, 106, and 107).
2. The old values are copied into the undo tablespace, and new values are written to buffer cache.
3. Other connected users querying `EMPLOYEES` read the old values from the undo segments (consistent read).
4. `SAVEPOINT salary_bump_done` records the system change number (SCN) marker.
5. The subsequent `ROLLBACK TO salary_bump_done` reads undo records to revert job titles without touching the salary updates.
6. `COMMIT` writes redo log buffers to disk, releases all row locks, and makes the updated salaries permanent for all database users.

---

## 10. Common Mistakes
1. **Accidental Full-Table Wipeout**: Omitting `WHERE` in `UPDATE` or `DELETE`. **Golden Rule**: Always write `SELECT * FROM tbl WHERE ...` first to verify exactly which rows match before converting it to `UPDATE` or `DELETE`.
2. **Forgetting to COMMIT**: Writing an application or script that runs DML, but closing the terminal or database connection before committing. By default, uncommitted sessions roll back on abnormal disconnection.
3. **Deadlocks**: Session 1 locks Row A and requests Row B, while Session 2 locks Row B and requests Row A. Both wait indefinitely until Oracle detects the deadlock and aborts one statement with `ORA-00060`.
4. **Inserting String Literals into Date Columns Directly**: Writing `INSERT ... VALUES ('2023-05-15')` relies on the system's ambient `NLS_DATE_FORMAT`. Always use explicit conversion: `TO_DATE('2023-05-15', 'YYYY-MM-DD')`.

---

## 11. Interview Questions
1. **What is the difference between `COMMIT` and `ROLLBACK`?**
   - *Answer*: `COMMIT` permanently saves all transaction changes made in the current session to disk and releases row locks. `ROLLBACK` cancels and restores all modified data back to its pre-transaction state.
2. **What does `SAVEPOINT` do?**
   - *Answer*: It creates an intermediate bookmark inside an open transaction, allowing you to selectively rollback a portion of the transaction without discarding the entire sequence of operations.
3. **What happens if two users update the same row at the exact same moment in Oracle?**
   - *Answer*: The first user to issue the `UPDATE` statement acquires an exclusive row-level lock. The second user's session waits (blocks) until the first user either issues a `COMMIT` or `ROLLBACK`.
4. **Can you insert multiple rows in a single SQL statement in Oracle?**
   - *Answer*: Yes, using `INSERT ALL INTO table VALUES (...) INTO table VALUES (...) SELECT * FROM DUAL;` or via `INSERT INTO table SELECT ... FROM source;`. (Oracle 23c also supports standard multi-row `VALUES (..), (..)`).

---

## 12. Short Summary
- DML statements (`INSERT`, `UPDATE`, `DELETE`) alter table records.
- Always be vigilant with the `WHERE` clause in `UPDATE` and `DELETE` to prevent catastrophic table-wide changes.
- Transactions bundle DML statements into atomic operations managed via `COMMIT`, `ROLLBACK`, and `SAVEPOINT`.
