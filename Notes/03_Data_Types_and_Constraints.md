# Chapter 3: Data Types and Constraints

## 1. Topic Title
**SQL Data Types, Integrity Constraints, and Data Validation Rules**

---

## 2. Simple Definition
- **Data Type**: An attribute that specifies the kind of data a column can hold (e.g., numbers, text strings, calendar dates, precise timestamps).
- **Constraint**: A declarative rule enforced by the database engine on table columns to prevent invalid, corrupt, or inconsistent data from entering the database.

### Common Oracle Data Types
1. **`NUMBER(p, s)`**: Stores numeric data. `p` is precision (total digits, 1–38), `s` is scale (digits to right of decimal). E.g., `NUMBER(10, 2)` can store up to `99999999.99`.
2. **`VARCHAR2(size)`**: Variable-length alphanumeric character string up to 4,000 bytes (or 32,767 in extended mode). Saves storage space.
3. **`CHAR(size)`**: Fixed-length character string up to 2,000 bytes. Pads unused characters with blank spaces.
4. **`DATE`**: Stores century, year, month, day, hour, minute, and second (e.g., `01-JAN-2023 14:30:00`).
5. **`TIMESTAMP`**: Extends `DATE` to include fractional seconds (up to 9 digits of precision, e.g., nanoseconds).

### Core Integrity Constraints
1. **`NOT NULL`**: Guarantees that a column cannot store a `NULL` (empty/missing) value.
2. **`UNIQUE`**: Ensures all values in a column (or set of columns) are distinct. Allows `NULL` unless paired with `NOT NULL`.
3. **`PRIMARY KEY`**: Uniquely identifies each record. Automatically combines `NOT NULL` + `UNIQUE`. A table can have only one Primary Key.
4. **`FOREIGN KEY`**: Ensures that values in the child column must exist in the referenced parent table's Primary/Unique key column (or be `NULL`).
5. **`CHECK`**: Enforces a condition that all values in the column must satisfy (e.g., `salary > 0` or `gpa BETWEEN 0 AND 4`).
6. **`DEFAULT`**: Automatically populates a specified default value if no value is supplied during an `INSERT`. (Technically a column clause/literal).

---

## 3. Why It Is Used
- **Defense in Depth**: Enforcing rules at the database level ensures bad data cannot enter, regardless of bugs in user interfaces, mobile apps, or backend microservices.
- **Data Quality**: Protects against nonsensical values (e.g., negative salaries, invalid emails, missing IDs).
- **Referential Consistency**: Guarantees that invoices cannot exist without valid customers, or enrollments without real students.
- **Performance Optimization**: The database query optimizer uses constraints and data types to create efficient indexes and execution plans.

---

## 4. Syntax
```sql
-- Creating a table demonstrating all major constraints and data types
CREATE TABLE STUDENTS_DEMO (
    student_id      NUMBER(5)           CONSTRAINT pk_student_demo PRIMARY KEY,
    first_name      VARCHAR2(50)        NOT NULL,
    last_name       VARCHAR2(50)        NOT NULL,
    email           VARCHAR2(100)       CONSTRAINT uq_student_demo_email UNIQUE,
    gender          CHAR(1)             CONSTRAINT chk_student_gender CHECK (gender IN ('M', 'F', 'O')),
    date_of_birth   DATE,
    gpa             NUMBER(3, 2)        CONSTRAINT chk_student_gpa CHECK (gpa BETWEEN 0.00 AND 4.00),
    department_id   NUMBER(5)           CONSTRAINT fk_student_dept_demo REFERENCES DEPARTMENTS(department_id),
    enrollment_date DATE                DEFAULT SYSDATE NOT NULL
);
```

---

## 5. Explanation of the Syntax
- `student_id NUMBER(5) CONSTRAINT pk_student_demo PRIMARY KEY`: Designates `student_id` as the primary key and names the constraint `pk_student_demo` for easy identification during debugging.
- `first_name VARCHAR2(50) NOT NULL`: Disallows null entries.
- `email VARCHAR2(100) CONSTRAINT uq_student_demo_email UNIQUE`: Forbids duplicate email addresses.
- `gender CHAR(1) CHECK (...)`: Accepts only `'M'`, `'F'`, or `'O'`.
- `department_id REFERENCES DEPARTMENTS(department_id)`: Enforces foreign key relation pointing to the parent table `DEPARTMENTS`.
- `enrollment_date DEFAULT SYSDATE`: Automatically fills with the current system date and time if omitted.

---

## 6. Example Query: Valid vs. Invalid Inserts
```sql
-- 1. VALID INSERT: Satisfies every data type and constraint rule
INSERT INTO STUDENTS_DEMO (student_id, first_name, last_name, email, gender, date_of_birth, gpa, department_id)
VALUES (1, 'Rohan', 'Sharma', 'rohan.sharma@univ.edu', 'M', TO_DATE('2003-05-15', 'YYYY-MM-DD'), 3.75, 10);

-- 2. INVALID INSERT A: Violates NOT NULL on last_name
-- Fails with: ORA-01400: cannot insert NULL into ("STUDENTS_DEMO"."LAST_NAME")
-- INSERT INTO STUDENTS_DEMO (student_id, first_name, last_name, email) VALUES (2, 'Priya', NULL, 'priya@univ.edu');

-- 3. INVALID INSERT B: Violates CHECK constraint on GPA (value 4.5 exceeds 4.00)
-- Fails with: ORA-02290: check constraint (CHK_STUDENT_GPA) violated
-- INSERT INTO STUDENTS_DEMO (student_id, first_name, last_name, email, gpa) VALUES (3, 'Aman', 'Verma', 'aman@univ.edu', 4.50);

-- 4. INVALID INSERT C: Violates FOREIGN KEY (Department 999 does not exist in DEPARTMENTS)
-- Fails with: ORA-02291: integrity constraint (FK_STUDENT_DEPT_DEMO) violated - parent key not found
-- INSERT INTO STUDENTS_DEMO (student_id, first_name, last_name, email, department_id) VALUES (4, 'John', 'Doe', 'john@univ.edu', 999);
```

---

## 7. Sample Input Table: `STUDENTS_DEMO`
| STUDENT_ID | FIRST_NAME | LAST_NAME | EMAIL | GENDER | GPA | DEPARTMENT_ID | ENROLLMENT_DATE |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Rohan | Sharma | rohan.sharma@univ.edu | M | 3.75 | 10 | 18-OCT-2026 |

---

## 8. Expected Output: Querying Constraints Metadata
You can inspect active constraints using the Oracle data dictionary:
```sql
SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'STUDENTS_DEMO';
```

| CONSTRAINT_NAME | CONSTRAINT_TYPE | SEARCH_CONDITION |
| :--- | :--- | :--- |
| PK_STUDENT_DEMO | P | *null* |
| UQ_STUDENT_DEMO_EMAIL | U | *null* |
| CHK_STUDENT_GENDER | C | gender IN ('M', 'F', 'O') |
| CHK_STUDENT_GPA | C | gpa BETWEEN 0.00 AND 4.00 |
| FK_STUDENT_DEPT_DEMO | R | *null* |

*(Note: Constraint Types in Oracle: P = Primary Key, R = Referential/Foreign Key, U = Unique, C = Check/Not Null)*

---

## 9. Step-by-Step Explanation of How Constraints Protect Data
1. When a user submits an `INSERT` or `UPDATE` statement, the Oracle SQL parse engine first validates syntax and data type matching.
2. Next, the transaction coordinator evaluates column-level `CHECK` and `NOT NULL` rules. If any check evaluates to `FALSE`, the statement fails immediately.
3. Then, unique and primary key index trees are searched for duplicate collision.
4. Finally, foreign keys query the referenced parent index to guarantee the parent record exists.
5. If all validations succeed, the row enters the table buffer; if any constraint fails, the engine throws an `ORA-XXXXX` exception and rolls back the single statement.

---

## 10. Common Mistakes
1. **Using `CHAR` for Variable Text**: Using `CHAR(50)` for names causes strings like `'John'` to be padded with 46 blank spaces, breaking subsequent string equality checks like `WHERE name = 'John'`. Always use `VARCHAR2` for variable text.
2. **Forgetting Constraint Names**: Writing `PRIMARY KEY` inline without a name generates automatic system names like `SYS_C007123`. Naming constraints explicitly (e.g., `CONSTRAINT pk_students ...`) makes error diagnostics instantaneous.
3. **Thinking UNIQUE allows only one NULL**: In Oracle and standard SQL, multiple rows *can* have `NULL` in a `UNIQUE` column because `NULL != NULL` in three-valued logic. To forbid duplicates and disallow nulls, apply both `UNIQUE` and `NOT NULL`.
4. **Incorrect Scale and Precision**: Declaring `NUMBER(3, 2)` allows numbers up to `9.99`. Attempting to insert `10.5` will fail with numeric overflow (`ORA-01438`).

---

## 11. Interview Questions
1. **What is the difference between `VARCHAR2` and `CHAR` in Oracle?**
   - *Answer*: `VARCHAR2` stores only the actual characters inserted up to its limit (saving space), whereas `CHAR` pads the string with spaces up to the fixed declared length.
2. **Can a table have multiple PRIMARY KEY constraints?**
   - *Answer*: No. A table can have exactly one Primary Key constraint (though it can be a composite key spanning multiple columns). It can, however, have multiple `UNIQUE` constraints.
3. **What is the difference between Primary Key and Unique Key?**
   - *Answer*: A Primary Key does not allow `NULL` values and defines the primary entity identifier (only 1 per table). A Unique Key prevents duplicate non-null entries, allows multiple `NULL` values in standard SQL, and a table can have multiple unique keys.
4. **What does the `CHECK` constraint do?**
   - *Answer*: It enforces a Boolean expression that every inserted or updated value in that column must satisfy.

---

## 12. Short Summary
- Data types (`NUMBER`, `VARCHAR2`, `DATE`, `TIMESTAMP`) govern what kind of values can be stored and how much space they consume.
- Constraints (`PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`) protect database integrity at the schema level.
- Always name constraints explicitly for maintainability and clear error handling.
