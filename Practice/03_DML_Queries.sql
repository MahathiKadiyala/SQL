-- ============================================================================
-- File: 03_DML_Queries.sql
-- Topic: Data Manipulation Language (DML) and Transaction Control
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Insert a new department record for 'Civil Engineering' with department_id 70
-- and location 'Engineering Block C'.
-- ----------------------------------------------------------------------------
INSERT INTO DEPARTMENTS (department_id, department_name, location)
VALUES (70, 'Civil Engineering', 'Engineering Block C');
-- Expected Result: 1 row inserted into DEPARTMENTS.

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Easy]
-- Insert a new student into the STUDENTS table specifying student_id 11,
-- name 'Vikram Rathore', email 'vikram.r@univ.edu', gender 'M', department_id 70,
-- and GPA 3.45.
-- ----------------------------------------------------------------------------
INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, department_id, gpa)
VALUES (11, 'Vikram', 'Rathore', 'vikram.r@univ.edu', 'M', 70, 3.45);
-- Expected Result: 1 row inserted into STUDENTS with default enrollment_date (SYSDATE).

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Medium]
-- Use Oracle's INSERT ALL statement to insert two new courses in one operation:
-- Course 209: 'CE101', 'Structural Mechanics', 4 credits, dept 70
-- Course 210: 'CE202', 'Fluid Dynamics for Civil', 3 credits, dept 70
-- ----------------------------------------------------------------------------
INSERT ALL
    INTO COURSES (course_id, course_code, course_name, credits, department_id)
    VALUES (209, 'CE101', 'Structural Mechanics', 4, 70)
    INTO COURSES (course_id, course_code, course_name, credits, department_id)
    VALUES (210, 'CE202', 'Fluid Dynamics for Civil', 3, 70)
SELECT * FROM DUAL;
-- Expected Result: 2 rows inserted into COURSES simultaneously.

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Easy]
-- Update the GPA of student 11 to 3.65.
-- ----------------------------------------------------------------------------
UPDATE STUDENTS
SET gpa = 3.65
WHERE student_id = 11;
-- Expected Result: 1 row updated; student 11's GPA changed from 3.45 to 3.65.

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Medium]
-- Award a 7% salary raise to all employees in Department 10 (Computer Science).
-- ----------------------------------------------------------------------------
UPDATE EMPLOYEES
SET salary = salary * 1.07
WHERE department_id = 10;
-- Expected Result: 4 rows updated (Employees 101, 102, 104, 105).

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Medium]
-- Update both phone_number to '555-0999' and commission_pct to 0.08 for employee 107.
-- ----------------------------------------------------------------------------
UPDATE EMPLOYEES
SET phone_number = '555-0999',
    commission_pct = 0.08
WHERE employee_id = 107;
-- Expected Result: 1 row updated for employee 107.

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Easy]
-- Delete the newly created student record (student_id = 11).
-- ----------------------------------------------------------------------------
DELETE FROM STUDENTS
WHERE student_id = 11;
-- Expected Result: 1 row deleted from STUDENTS.

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Medium]
-- Delete the newly created courses (course_id 209 and 210) from COURSES.
-- ----------------------------------------------------------------------------
DELETE FROM COURSES
WHERE course_id IN (209, 210);
-- Expected Result: 2 rows deleted from COURSES.

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Demonstrate safe transaction control: Create a SAVEPOINT named 'before_cleanup',
-- delete department 70, verify with a select, then rollback to the savepoint.
-- ----------------------------------------------------------------------------
SAVEPOINT before_cleanup;

DELETE FROM DEPARTMENTS
WHERE department_id = 70;

-- Verification query (department 70 should temporarily not appear)
SELECT * FROM DEPARTMENTS WHERE department_id = 70;

-- Rollback to savepoint to restore department 70
ROLLBACK TO before_cleanup;

-- Verification query (department 70 is restored)
SELECT * FROM DEPARTMENTS WHERE department_id = 70;
-- Expected Result: Row 70 is deleted inside the uncommitted transaction, then restored
-- intact by rolling back to the savepoint.

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- Clean up department 70 permanently and commit all remaining pending updates.
-- ----------------------------------------------------------------------------
DELETE FROM DEPARTMENTS
WHERE department_id = 70;

COMMIT;
-- Expected Result: Department 70 is permanently deleted, the salary increases for
-- Dept 10 and phone update for 107 are committed to the database.
