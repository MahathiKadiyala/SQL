-- ============================================================================
-- File: 04_SELECT_and_Filtering.sql
-- Topic: SELECT Queries, WHERE Filters, Range/Set Operators, Wildcards, and Sorting
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Find all employees whose salary is strictly greater than 80,000.
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, job_title, salary
FROM EMPLOYEES
WHERE salary > 80000
ORDER BY salary DESC;
-- Expected Result: 6 rows (Robert King, Arthur Dent, Alice Smith, Sarah Connor, David Clark, Michael Scott).

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Easy]
-- Find all students who belong to either Department 10 or Department 20.
-- ----------------------------------------------------------------------------
SELECT student_id, first_name, last_name, department_id, gpa
FROM STUDENTS
WHERE department_id IN (10, 20)
ORDER BY department_id, last_name;
-- Expected Result: 5 rows (Aarav Sharma, Sophia Chen, Noah Brown in Dept 10; Ananya Iyer, Liam OConnor in Dept 20).

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Easy]
-- Retrieve all students with a GPA between 3.50 and 4.00 (inclusive), ordered by GPA descending.
-- ----------------------------------------------------------------------------
SELECT student_id, first_name, last_name, gpa
FROM STUDENTS
WHERE gpa BETWEEN 3.50 AND 4.00
ORDER BY gpa DESC;
-- Expected Result: 6 rows (Sophia Chen: 3.92, Zoe Kravitz: 3.88, Aarav Sharma: 3.85, Ananya Iyer: 3.75, Emma Watson: 3.60, Maya Lin: 3.50).

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Medium]
-- Find employees who work in Department 10 OR Department 30 AND earn at least 70,000.
-- Make sure the department grouping is explicitly prioritized with parentheses.
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, department_id, salary
FROM EMPLOYEES
WHERE (department_id = 10 OR department_id = 30)
  AND salary >= 70000
ORDER BY department_id, salary DESC;
-- Expected Result: 5 rows (Robert King, Alice Smith, Michael Scott in Dept 10; Sarah Connor, Carlos Mendoza in Dept 30).

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Easy]
-- Find all employees whose last name begins with the letter 'C' or 'M'.
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, job_title
FROM EMPLOYEES
WHERE last_name LIKE 'C%' OR last_name LIKE 'M%'
ORDER BY last_name;
-- Expected Result: 3 rows (David Clark, Sarah Connor, Carlos Mendoza).

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Medium]
-- Find courses whose course_code contains a 4-credit course or starts with 'IT'.
-- ----------------------------------------------------------------------------
SELECT course_id, course_code, course_name, credits
FROM COURSES
WHERE credits = 4 OR course_code LIKE 'IT%'
ORDER BY course_code;
-- Expected Result: 6 rows (CS101, CS201, EE102, IT105, IT220, ME101).

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Easy]
-- Find all employees who receive a sales commission (commission_pct is not null).
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, commission_pct
FROM EMPLOYEES
WHERE commission_pct IS NOT NULL
ORDER BY commission_pct DESC;
-- Expected Result: 5 rows (Arthur Dent: 0.20, Alice Smith: 0.15, Sarah Connor: 0.12, David Clark: 0.10, Priya Patel: 0.05).

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Medium]
-- Find students who have NOT declared a major (department_id is null).
-- ----------------------------------------------------------------------------
SELECT student_id, first_name, last_name, email, gpa
FROM STUDENTS
WHERE department_id IS NULL;
-- Expected Result: 1 row (Maya Lin, student_id 10).

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Find employees hired between January 1, 2020 and December 31, 2021, ordered by hire date.
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, hire_date, job_title
FROM EMPLOYEES
WHERE hire_date BETWEEN TO_DATE('2020-01-01', 'YYYY-MM-DD') 
                    AND TO_DATE('2021-12-31', 'YYYY-MM-DD')
ORDER BY hire_date ASC;
-- Expected Result: 4 rows (Michael Scott: Feb 2020, Priya Patel: Nov 2020, Carlos Mendoza: Apr 2021, Elena Rostova: Aug 2021).

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- List all employees ordered by department_id ascending with NULLs last, and secondarily
-- by salary descending.
-- ----------------------------------------------------------------------------
SELECT 
    employee_id, 
    first_name || ' ' || last_name AS full_name, 
    department_id, 
    salary
FROM EMPLOYEES
ORDER BY department_id ASC NULLS LAST, salary DESC;
-- Expected Result: 12 rows grouped by department (10, 20, 30, 60), tie-broken by salary descending,
-- with Bruce Wayne (department_id NULL) placed last.
