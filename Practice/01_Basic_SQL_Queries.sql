-- ============================================================================
-- File: 01_Basic_SQL_Queries.sql
-- Topic: Basic SQL Queries, Table Metadata Inspection, and Simple Retrieval
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Retrieve all columns and all records from the DEPARTMENTS table.
-- ----------------------------------------------------------------------------
SELECT * 
FROM DEPARTMENTS;
-- Expected Result: 6 rows representing all university departments (Computer Science,
-- IT, Mechanical, Electrical, HR, R&D).

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Easy]
-- Retrieve only the first name, last name, and email address of all students.
-- ----------------------------------------------------------------------------
SELECT first_name, last_name, email 
FROM STUDENTS;
-- Expected Result: 10 rows displaying the names and academic emails of all registered students.

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Easy]
-- Retrieve distinct job titles from the EMPLOYEES table to see all unique roles.
-- ----------------------------------------------------------------------------
SELECT DISTINCT job_title 
FROM EMPLOYEES;
-- Expected Result: 10 distinct job titles across the organization without duplicates.

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Easy]
-- Select employee ID, first name, last name, and monthly salary, giving the salary
-- column a friendly alias "Monthly Base Pay".
-- ----------------------------------------------------------------------------
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary AS "Monthly Base Pay"
FROM EMPLOYEES;
-- Expected Result: 12 rows with four columns, where the last header is formatted as 'Monthly Base Pay'.

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Easy]
-- Display each course's code and title combined into a single string formatted like:
-- "CS101: Introduction to Computer Science" under the alias "Course Full Name".
-- ----------------------------------------------------------------------------
SELECT 
    course_code || ': ' || course_name AS "Course Full Name"
FROM COURSES;
-- Expected Result: 8 formatted course titles combining the code and catalog description.

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Medium]
-- Query the Oracle Data Dictionary (USER_TABLES) to list all tables created in the
-- current schema, ordered alphabetically.
-- ----------------------------------------------------------------------------
SELECT table_name 
FROM user_tables
ORDER BY table_name ASC;
-- Expected Result: Alphabetical list including COURSES, DEPARTMENTS, EMPLOYEES,
-- SALARIES, STUDENTS, STUDENT_COURSES.

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Medium]
-- Query the Oracle Data Dictionary (USER_TAB_COLUMNS) to list all column names,
-- data types, and nullability flags for the 'EMPLOYEES' table.
-- ----------------------------------------------------------------------------
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'EMPLOYEES'
ORDER BY column_id;
-- Expected Result: 11 rows showing metadata for EMPLOYEE_ID, FIRST_NAME, LAST_NAME,
-- EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_TITLE, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID.

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Easy]
-- Calculate the estimated annual salary (salary * 12) for all employees along with
-- their full name.
-- ----------------------------------------------------------------------------
SELECT 
    first_name || ' ' || last_name AS employee_name,
    salary,
    salary * 12 AS annual_salary
FROM EMPLOYEES;
-- Expected Result: 12 rows showing monthly salary alongside annual earnings.

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Display the current system date, timestamp, and a literal calculation using the
-- Oracle DUAL pseudo-table.
-- ----------------------------------------------------------------------------
SELECT 
    SYSDATE AS current_server_date,
    CURRENT_TIMESTAMP AS current_server_timestamp,
    (150 * 4) + 25 AS math_result
FROM DUAL;
-- Expected Result: 1 row showing server date, timestamp with fractional seconds/timezone,
-- and 625.

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- Select employee ID, first name, last name, and department ID, sorting by employee ID
-- in ascending order.
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, department_id
FROM EMPLOYEES
ORDER BY employee_id ASC;
-- Expected Result: 12 rows strictly ordered from Employee 101 to 112.
