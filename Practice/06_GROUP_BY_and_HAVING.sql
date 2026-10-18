-- ============================================================================
-- File: 06_GROUP_BY_and_HAVING.sql
-- Topic: Grouping Records (GROUP BY) and Filtering Aggregates (HAVING)
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Count the number of employees in each department.
-- ----------------------------------------------------------------------------
SELECT 
    department_id, 
    COUNT(*) AS total_employees
FROM EMPLOYEES
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
-- Expected Result: 4 rows (Dept 10: 4 employees, Dept 20: 3, Dept 30: 3, Dept 60: 1).

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Easy]
-- Calculate the average salary and total payroll for each department.
-- ----------------------------------------------------------------------------
SELECT 
    department_id,
    ROUND(AVG(salary), 2) AS avg_salary,
    SUM(salary) AS total_payroll
FROM EMPLOYEES
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
-- Expected Result: 4 rows showing aggregated financial metrics per department.

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Medium]
-- Find all departments that have 3 or more employees using HAVING.
-- ----------------------------------------------------------------------------
SELECT 
    department_id,
    COUNT(*) AS employee_count
FROM EMPLOYEES
GROUP BY department_id
HAVING COUNT(*) >= 3
ORDER BY employee_count DESC;
-- Expected Result: 3 rows (Dept 10: 4, Dept 20: 3, Dept 30: 3).

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Medium]
-- Group employees by both department_id and job_title to see headcount and average
-- pay for each specific role within each department.
-- ----------------------------------------------------------------------------
SELECT 
    department_id,
    job_title,
    COUNT(*) AS role_headcount,
    ROUND(AVG(salary), 2) AS avg_role_salary
FROM EMPLOYEES
GROUP BY department_id, job_title
ORDER BY department_id, role_headcount DESC;
-- Expected Result: Distinct groupings by department and job title.

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Medium]
-- Find departments where the average employee salary is greater than $75,000.
-- ----------------------------------------------------------------------------
SELECT 
    department_id,
    ROUND(AVG(salary), 2) AS avg_salary
FROM EMPLOYEES
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING AVG(salary) > 75000
ORDER BY avg_salary DESC;
-- Expected Result: 3 rows (Dept 60: 110,000, Dept 10: 91,750, Dept 20: 75,333.33).

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Medium]
-- Find departments where the total payroll exceeds $200,000, considering only
-- employees who earn more than $50,000.
-- (Demonstrates combining WHERE and HAVING).
-- ----------------------------------------------------------------------------
SELECT 
    department_id,
    COUNT(*) AS qualifying_staff,
    SUM(salary) AS total_qualifying_payroll
FROM EMPLOYEES
WHERE salary > 50000
GROUP BY department_id
HAVING SUM(salary) > 200000;
-- Expected Result: Dept 10 and Dept 20 qualify.

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Easy]
-- Calculate student count and average GPA by department from the STUDENTS table.
-- ----------------------------------------------------------------------------
SELECT 
    department_id,
    COUNT(*) AS total_students,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM STUDENTS
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
-- Expected Result: 4 rows (Dept 10: 3 students, Dept 20: 2, Dept 30: 2, Dept 40: 2).

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Medium]
-- Find departments where the maximum GPA achieved by any student is at least 3.90.
-- ----------------------------------------------------------------------------
SELECT 
    department_id,
    MAX(gpa) AS highest_gpa
FROM STUDENTS
GROUP BY department_id
HAVING MAX(gpa) >= 3.90;
-- Expected Result: Dept 10 (Sophia Chen has 3.92).

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Group course enrollments by course_id and count how many students are enrolled,
-- keeping only courses with at least 2 enrollments.
-- ----------------------------------------------------------------------------
SELECT 
    course_id,
    COUNT(student_id) AS student_enrollment_count
FROM STUDENT_COURSES
GROUP BY course_id
HAVING COUNT(student_id) >= 2
ORDER BY student_enrollment_count DESC;
-- Expected Result: 6 rows (Courses 203, 201, 202, 204, 205, 206, 207).

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- Group employees by hiring year and calculate total hires and highest salary
-- for that year, ordered chronologically.
-- ----------------------------------------------------------------------------
SELECT 
    TO_CHAR(hire_date, 'YYYY') AS hire_year,
    COUNT(*) AS total_hired,
    MAX(salary) AS max_salary_in_year
FROM EMPLOYEES
GROUP BY TO_CHAR(hire_date, 'YYYY')
ORDER BY hire_year ASC;
-- Expected Result: Groups by years (2018, 2019, 2020, 2021, 2022, 2023) with hire metrics.
