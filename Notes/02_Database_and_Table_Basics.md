# Chapter 2: Database and Table Basics

## 1. Topic Title
**Understanding Schemas, Relational Table Structures, Entity Relationships, and Table Metadata**

---

## 2. Simple Definition
- **Database**: The physical storage system containing all data, log files, and control structures.
- **Schema**: In Oracle, a schema is a logical collection of database objects (tables, views, indexes, constraints) owned by a specific database user.
- **Table**: The fundamental rectangular storage unit containing rows (records) and columns (attributes).
- **Relationship**: A logical association between two or more tables established via common fields (keys):
  - **One-to-One (1:1)**: A record in Table A relates to at most one record in Table B (e.g., Person and Passport).
  - **One-to-Many (1:N)**: A single record in Table A relates to multiple records in Table B (e.g., One Department has many Students).
  - **Many-to-Many (M:N)**: Multiple records in Table A relate to multiple records in Table B (e.g., Students and Courses, implemented via a bridge/junction table `STUDENT_COURSES`).

---

## 3. Why It Is Used
- **Logical Data Separation**: Isolates tables into clean entities to avoid massive data duplication.
- **Eliminating Redundancy**: Storing department details once in `DEPARTMENTS` rather than repeating the name and building address on every single student row.
- **Data Integrity**: Foreign keys ensure a student cannot be assigned to a department that does not exist.
- **Inspection & Troubleshooting**: Schema inspection commands (like `DESCRIBE`) allow developers to verify column names, nullability, and data types before writing application code.

---

## 4. Syntax
```sql
-- 1. Oracle Command to inspect table structure in SQL*Plus or SQL Developer
DESC table_name;
-- or
DESCRIBE table_name;

-- 2. Querying Oracle Data Dictionary views for table info
SELECT table_name FROM user_tables;

-- 3. Querying column details from Data Dictionary
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'STUDENTS';

-- 4. Basic parent-child relationship table creation
CREATE TABLE DEPARTMENTS (
    department_id   NUMBER(5) PRIMARY KEY,
    department_name VARCHAR2(50) NOT NULL
);

CREATE TABLE STUDENTS (
    student_id      NUMBER(5) PRIMARY KEY,
    first_name      VARCHAR2(50) NOT NULL,
    department_id   NUMBER(5) REFERENCES DEPARTMENTS(department_id)
);
```

---

## 5. Explanation of the Syntax
1. **`DESC / DESCRIBE`**: An Oracle client-side utility command that prints the schema layout (Column Name, Null?, Type). Note: Semicolon is optional for `DESC` in SQL*Plus, but standard practice in scripts.
2. **`user_tables` & `user_tab_columns`**: System catalog views maintained by Oracle containing metadata about all objects owned by your user account. Table names are stored in uppercase by default in Oracle's data dictionary (`'STUDENTS'`).
3. **Primary Key (`PRIMARY KEY`)**: Uniquely identifies each record in the table. Must be unique and cannot be NULL.
4. **Foreign Key (`REFERENCES`)**: A column in a child table whose values must match an existing primary key in the parent table.

---

## 6. Example Query
Let's inspect the `DEPARTMENTS` and `STUDENTS` tables and query their relationship:

```sql
-- Query student names alongside their department name
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    d.department_name,
    d.location
FROM STUDENTS s
JOIN DEPARTMENTS d ON s.department_id = d.department_id
WHERE d.department_id = 10;
```

---

## 7. Sample Input Tables
### `DEPARTMENTS`
| DEPARTMENT_ID | DEPARTMENT_NAME | LOCATION |
| :--- | :--- | :--- |
| 10 | Computer Science | Tech Hall 1 |
| 20 | Information Technology | Tech Hall 2 |

### `STUDENTS`
| STUDENT_ID | FIRST_NAME | LAST_NAME | DEPARTMENT_ID | GPA |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Aarav | Sharma | 10 | 3.85 |
| 2 | Sophia | Chen | 10 | 3.92 |
| 3 | Liam | OConnor | 20 | 3.20 |
| 9 | Noah | Brown | 10 | 2.80 |

---

## 8. Expected Output
| STUDENT_ID | FIRST_NAME | LAST_NAME | DEPARTMENT_NAME | LOCATION |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Aarav | Sharma | Computer Science | Tech Hall 1 |
| 2 | Sophia | Chen | Computer Science | Tech Hall 1 |
| 9 | Noah | Brown | Computer Science | Tech Hall 1 |

---

## 9. Step-by-Step Explanation of How the Query Works
1. **Table Identification (`FROM STUDENTS s`)**: Designates the primary table `STUDENTS` with alias `s`.
2. **Relationship Matching (`JOIN DEPARTMENTS d ON s.department_id = d.department_id`)**: Pairs each student record with the corresponding department record where `department_id` matches.
3. **Filtering (`WHERE d.department_id = 10`)**: Keeps only those paired rows that belong to Department 10 (Computer Science).
4. **Column Projection (`SELECT ...`)**: Displays the student's ID, full name, department title, and office location.

---

## 10. Common Mistakes
1. **Querying Data Dictionary with Lowercase**: Running `WHERE table_name = 'students'` will return zero rows because Oracle stores object names in uppercase by default (`'STUDENTS'`).
2. **Deleting Parent Rows with Active Children**: Trying to `DELETE FROM DEPARTMENTS WHERE department_id = 10` while students exist in that department will throw `ORA-02292: integrity constraint violated - child record found`.
3. **Circular Dependencies**: Creating tables where Table A references Table B and Table B references Table A without careful constraint management.
4. **Assuming Schema == Database**: In MySQL, a database and a schema are identical synonyms. In Oracle, a Database is the instance/storage container, whereas a Schema is an individual user's collection of objects.

---

## 11. Interview Questions
1. **What is the difference between a Schema and a Database in Oracle?**
   - *Answer*: A database is the physical container of data files, processes, and memory. A schema is a logical collection of tables and objects owned by a specific database user.
2. **How is a Many-to-Many relationship modeled in relational databases?**
   - *Answer*: Through a junction (or bridge) table containing two foreign keys, each referencing one of the participating parent tables (e.g., `STUDENT_COURSES` bridging `STUDENTS` and `COURSES`).
3. **How can you view the definition and column types of a table in Oracle SQL?**
   - *Answer*: Using the `DESCRIBE table_name;` command or by querying `user_tab_columns`.
4. **What is referential integrity?**
   - *Answer*: A state where all foreign key references are valid, ensuring no child record points to a non-existent parent record.

---

## 12. Short Summary
- Relational databases store data in normalized tables connected through primary and foreign keys.
- Relationships exist in 1:1, 1:N, and M:N forms (M:N requires a bridge table).
- Oracle provides data dictionary views (`user_tables`, `user_tab_columns`) and client commands (`DESCRIBE`) to inspect structures.
- Parent-child integrity ensures consistent data across related business entities.
