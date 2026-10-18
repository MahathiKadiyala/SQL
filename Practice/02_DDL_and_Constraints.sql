-- ============================================================================
-- File: 02_DDL_and_Constraints.sql
-- Topic: Data Definition Language (DDL) and Integrity Constraints
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Write a DDL statement to create a table named 'INSTRUCTORS' with:
-- instructor_id (NUMBER(5), Primary Key),
-- instructor_name (VARCHAR2(50), Not Null),
-- email (VARCHAR2(100), Unique),
-- department_id (NUMBER(5), Foreign Key referencing DEPARTMENTS).
-- ----------------------------------------------------------------------------
CREATE TABLE INSTRUCTORS (
    instructor_id   NUMBER(5) CONSTRAINT pk_instructors PRIMARY KEY,
    instructor_name VARCHAR2(50) NOT NULL,
    email           VARCHAR2(100) CONSTRAINT uq_instructor_email UNIQUE,
    department_id   NUMBER(5) CONSTRAINT fk_instructor_dept 
                        REFERENCES DEPARTMENTS(department_id)
);
-- Expected Result: Table INSTRUCTORS created successfully with PK, UNIQUE, NOT NULL, and FK constraints.

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Easy]
-- Add a new column named 'office_room' of type VARCHAR2(30) to the INSTRUCTORS table.
-- ----------------------------------------------------------------------------
ALTER TABLE INSTRUCTORS ADD (office_room VARCHAR2(30));
-- Expected Result: Table INSTRUCTORS altered; office_room column added.

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Medium]
-- Add a CHECK constraint named 'chk_instructor_office' on INSTRUCTORS ensuring
-- office_room starts with 'Room-'.
-- ----------------------------------------------------------------------------
ALTER TABLE INSTRUCTORS ADD CONSTRAINT chk_instructor_office 
    CHECK (office_room LIKE 'Room-%');
-- Expected Result: Table INSTRUCTORS altered; check constraint enforced on office_room.

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Easy]
-- Modify the 'instructor_name' column in INSTRUCTORS to expand its length to VARCHAR2(80).
-- ----------------------------------------------------------------------------
ALTER TABLE INSTRUCTORS MODIFY (instructor_name VARCHAR2(80));
-- Expected Result: Table INSTRUCTORS altered; maximum length expanded from 50 to 80 bytes.

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Medium]
-- Add a column 'status' of type VARCHAR2(15) with a default value of 'ACTIVE'
-- and a NOT NULL constraint to INSTRUCTORS.
-- ----------------------------------------------------------------------------
ALTER TABLE INSTRUCTORS ADD (status VARCHAR2(15) DEFAULT 'ACTIVE' NOT NULL);
-- Expected Result: Table INSTRUCTORS altered; new column status added with default 'ACTIVE'.

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Easy]
-- Rename the column 'office_room' to 'cabin_number' in the INSTRUCTORS table.
-- ----------------------------------------------------------------------------
ALTER TABLE INSTRUCTORS RENAME COLUMN office_room TO cabin_number;
-- Expected Result: Table INSTRUCTORS altered; column office_room renamed to cabin_number.

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Medium]
-- Drop the 'cabin_number' column completely from the INSTRUCTORS table.
-- ----------------------------------------------------------------------------
ALTER TABLE INSTRUCTORS DROP COLUMN cabin_number;
-- Expected Result: Table INSTRUCTORS altered; column removed along with its check constraint.

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Easy]
-- Rename the table 'INSTRUCTORS' to 'FACULTY_MEMBERS'.
-- ----------------------------------------------------------------------------
RENAME INSTRUCTORS TO FACULTY_MEMBERS;
-- Expected Result: Table renamed from INSTRUCTORS to FACULTY_MEMBERS in the schema.

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Insert a test row into FACULTY_MEMBERS and then TRUNCATE the table, explaining
-- the difference from DROP.
-- ----------------------------------------------------------------------------
INSERT INTO FACULTY_MEMBERS (instructor_id, instructor_name, email, department_id)
VALUES (1, 'Dr. Alan Turing', 'alan.turing@univ.edu', 10);
COMMIT;

TRUNCATE TABLE FACULTY_MEMBERS;
-- Expected Result: Row inserted and committed, then table instantly truncated.
-- The row is permanently removed, but the table schema structure remains available for new data.

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- Drop the FACULTY_MEMBERS table completely along with any dependent constraints.
-- ----------------------------------------------------------------------------
DROP TABLE FACULTY_MEMBERS CASCADE CONSTRAINTS;
-- Expected Result: Table FACULTY_MEMBERS dropped permanently. Subsequent queries on this table
-- will return ORA-00942 (table or view does not exist).
