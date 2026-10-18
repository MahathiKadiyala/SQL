# Chapter 1: Introduction to SQL and Relational Databases

## 1. Topic Title
**Introduction to SQL, Relational Database Management Systems (RDBMS), and Core SQL Command Categories**

---

## 2. Simple Definition
- **Data**: Raw facts, figures, and symbols with no context (for example: `101`, `"Alice"`, `85000`).
- **Database**: An organized, electronic collection of structured data stored and accessed electronically from a computer system.
- **DBMS (Database Management System)**: Software that handles the storage, retrieval, and updating of data in a computer system (e.g., file-based systems, XML databases).
- **RDBMS (Relational Database Management System)**: A specialized DBMS based on the relational model introduced by E. F. Codd. It stores data in 2-dimensional tables comprising rows and columns and enforces mathematical relationships between tables using keys (e.g., Oracle Database, PostgreSQL, MySQL, Microsoft SQL Server).
- **SQL (Structured Query Language)**: The standardized domain-specific language used to communicate with, manage, and query relational databases.

---

## 3. Why It Is Used
- **Universal Standard**: SQL is the universal language for interacting with relational databases across virtually all industry systems.
- **Declarative Power**: You tell the database *what* data you want, rather than writing procedural loops and memory-allocation routines to tell it *how* to find it.
- **Data Integrity & Safety**: SQL engines enforce constraints (like unique keys and mandatory foreign relationships) to prevent corrupted or orphan data.
- **Concurrency & Transactions**: Handles thousands of simultaneous read and write operations safely using ACID principles (Atomicity, Consistency, Isolation, Durability).
- **Security & Authorization**: Allows fine-grained control over who can view or manipulate specific tables, rows, or columns.

---

## 4. Syntax
SQL commands are broadly classified into 5 major sub-languages:

```sql
-- 1. DDL (Data Definition Language) - Defines schema structure
CREATE TABLE table_name (column1 datatype, column2 datatype);
ALTER TABLE table_name ADD (new_column datatype);
DROP TABLE table_name;
TRUNCATE TABLE table_name;
RENAME old_name TO new_name;

-- 2. DQL (Data Query Language) - Retrieves data
SELECT column1, column2 FROM table_name WHERE condition;

-- 3. DML (Data Manipulation Language) - Modifies table records
INSERT INTO table_name (column1, column2) VALUES (value1, value2);
UPDATE table_name SET column1 = value1 WHERE condition;
DELETE FROM table_name WHERE condition;

-- 4. TCL (Transaction Control Language) - Manages transaction boundaries
COMMIT;
ROLLBACK;
SAVEPOINT savepoint_name;

-- 5. DCL (Data Control Language) - Manages permissions and security
GRANT privilege_name ON object_name TO user_name;
REVOKE privilege_name ON object_name FROM user_name;
```

---

## 5. Explanation of the Syntax
1. **DDL (Data Definition Language)**:
   - Changes the structure/schema of the database objects.
   - **Important in Oracle**: DDL commands issue an implicit `COMMIT` before and after execution; they cannot be rolled back!
2. **DQL (Data Query Language)**:
   - Focuses on reading and filtering stored data (`SELECT`).
   - Does not alter stored records or structure.
3. **DML (Data Manipulation Language)**:
   - Works on the rows inside tables (adding, changing, deleting rows).
   - In Oracle SQL, DML changes are transactional and remain visible only in your current session until you execute `COMMIT` or discard them via `ROLLBACK`.
4. **TCL (Transaction Control Language)**:
   - Controls how groups of DML statements are permanently committed or reversed.
5. **DCL (Data Control Language)**:
   - Grants or takes away access privileges to database objects (executed by DBAs and security administrators).

### Core Concepts: Tables, Rows, Columns, Records, and Fields
- **Table (Relation)**: A two-dimensional collection of rows and columns representing a business entity (e.g., `EMPLOYEES`).
- **Column (Attribute / Field)**: A vertical entity in a table that contains all information associated with a specific property (e.g., `salary`).
- **Row (Record / Tuple)**: A horizontal entity representing a single, complete unit of data (e.g., Employee #102: Alice Smith).

### SQL vs. Procedural Programming Languages
| Feature | SQL | Programming Languages (Python, Java, C++) |
| :--- | :--- | :--- |
| **Paradigm** | Declarative (*specify WHAT result you want*) | Imperative / Procedural (*specify HOW step-by-step*) |
| **Execution** | Database query optimizer creates the plan | Compiled or interpreted line-by-line |
| **Data Scope** | Works natively on entire sets of records | Works primarily on individual variables/loops |
| **State Storage** | Persistent data stored on disk/server | Temporary memory (RAM) during execution |

---

## 6. Example Query
Let's see an initial query that retrieves data from a database and verifies the connection:

```sql
-- DQL query selecting employee information
SELECT employee_id, first_name, last_name, job_title, salary
FROM EMPLOYEES
WHERE department_id = 10;
```

---

## 7. Sample Input Table: `EMPLOYEES`
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | SALARY | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | President & CEO | 125000.00 | 10 |
| 102 | Alice | Smith | Engineering Director | 95000.00 | 10 |
| 103 | David | Clark | IT Manager | 88000.00 | 20 |
| 104 | Michael | Scott | Senior Software Engineer | 82000.00 | 10 |
| 105 | Elena | Rostova | Software Engineer | 65000.00 | 10 |

---

## 8. Expected Output
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | SALARY |
| :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | President & CEO | 125000.00 |
| 102 | Alice | Smith | Engineering Director | 95000.00 |
| 104 | Michael | Scott | Senior Software Engineer | 82000.00 |
| 105 | Elena | Rostova | Software Engineer | 65000.00 |

---

## 9. Step-by-Step Explanation of How the Query Works
1. **`FROM EMPLOYEES`**: The SQL engine first identifies the data source table (`EMPLOYEES`).
2. **`WHERE department_id = 10`**: It evaluates every row in the table, keeping only rows where the `department_id` evaluates to `10`. Employee 103 (Dept 20) is filtered out.
3. **`SELECT ...`**: For the surviving rows, only the requested columns (`employee_id`, `first_name`, `last_name`, `job_title`, `salary`) are projected and formatted in the result set.

---

## 10. Common Mistakes
1. **Forgetting String Quotes**: Writing `WHERE job_title = Software Engineer` instead of `'Software Engineer'`. In SQL, string and date literals must be enclosed in single quotes `'...'`.
2. **Confusing DDL and DML**: Expecting `DROP TABLE` or `TRUNCATE TABLE` to be reversible with `ROLLBACK` in Oracle. (DDL commits immediately!).
3. **Assuming SQL Execution Order matches written order**: SQL is written as `SELECT -> FROM -> WHERE`, but logically executed as `FROM -> WHERE -> SELECT`.
4. **Case Sensitivity Confusion**: SQL keywords (`SELECT`, `FROM`) and column names are case-insensitive in Oracle, but string values inside quotes (`'Engineering Director'`) are strictly case-sensitive.

---

## 11. Interview Questions
1. **What is the difference between DBMS and RDBMS?**
   - *Answer*: DBMS stores data as files or hierarchies without enforcing relational integrity rules across tables; RDBMS stores data in structured tables with primary/foreign key relations, normalization, and ACID compliance.
2. **What are the five categories of SQL statements? Give one example of each.**
   - *Answer*: DDL (`CREATE`), DML (`INSERT`), DQL (`SELECT`), TCL (`COMMIT`), DCL (`GRANT`).
3. **Why is SQL called a declarative language?**
   - *Answer*: Because developers define *what* dataset they want rather than coding the algorithmic procedure to retrieve it.
4. **What happens if you execute DML without running COMMIT in Oracle?**
   - *Answer*: Changes exist only in your local session. Other users cannot see them, and if your session crashes or disconnects without committing, changes are automatically rolled back.

---

## 12. Short Summary
- SQL is the standard declarative language for interacting with RDBMS systems like Oracle.
- Data is organized into tables consisting of horizontal rows (records) and vertical columns (attributes).
- SQL statements are categorized into DDL (structure), DQL (query), DML (data manipulation), TCL (transactions), and DCL (security).
- Oracle enforces strict transaction boundaries where DML requires `COMMIT` while DDL auto-commits.
