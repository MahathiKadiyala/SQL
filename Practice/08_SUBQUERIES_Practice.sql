-- ============================================================================
-- File: 08_SUBQUERIES_Practice.sql
-- Topic: Subqueries (Single-Row, Multi-Row, Inline Views, Correlated, and EXISTS)
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Find all employees who earn strictly more than the overall average company salary.
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, salary
FROM EMPLOYEES
WHERE salary > (SELECT AVG(salary) FROM EMPLOYEES)
ORDER BY salary DESC;
-- Expected Result: 5 rows (Robert King: 125k, Arthur Dent: 110k, Alice Smith: 95k,
-- Sarah Connor: 91k, David Clark: 88k, Michael Scott: 82k).

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Medium]
-- Find the second highest salary among all employees without using analytical window functions.
-- ----------------------------------------------------------------------------
SELECT MAX(salary) AS second_highest_salary
FROM EMPLOYEES
WHERE salary < (SELECT MAX(salary) FROM EMPLOYEES);
-- Expected Result: 1 row showing 110000.00 (Arthur Dent's salary).

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Medium]
-- Find all employees who earn more than the average salary of their OWN department
-- (Correlated Subquery).
-- ----------------------------------------------------------------------------
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary
FROM EMPLOYEES e
WHERE e.salary > (
    SELECT AVG(d_avg.salary)
    FROM EMPLOYEES d_avg
    WHERE d_avg.department_id = e.department_id
)
ORDER BY e.department_id, e.salary DESC;
-- Expected Result: 6 rows (Dept 10: Robert King & Alice Smith; Dept 20: David Clark & Priya Patel;
-- Dept 30: Sarah Connor & Carlos Mendoza).

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Easy]
-- Find all students who have a GPA higher than student 'Aarav Sharma' (student_id = 1).
-- ----------------------------------------------------------------------------
SELECT student_id, first_name, last_name, gpa
FROM STUDENTS
WHERE gpa > (SELECT gpa FROM STUDENTS WHERE student_id = 1);
-- Expected Result: 2 rows (Sophia Chen: 3.92, Zoe Kravitz: 3.88).

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Medium]
-- Find departments that have NO employees assigned to them using NOT EXISTS.
-- ----------------------------------------------------------------------------
SELECT d.department_id, d.department_name, d.location
FROM DEPARTMENTS d
WHERE NOT EXISTS (
    SELECT 1 
    FROM EMPLOYEES e 
    WHERE e.department_id = d.department_id
);
-- Expected Result: 2 rows (Dept 40: Electrical Engineering, Dept 50: Human Resources).

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Medium]
-- Find departments that have NO enrolled students using NOT IN (ensuring no NULLs are returned).
-- ----------------------------------------------------------------------------
SELECT d.department_id, d.department_name
FROM DEPARTMENTS d
WHERE d.department_id NOT IN (
    SELECT s.department_id 
    FROM STUDENTS s 
    WHERE s.department_id IS NOT NULL
);
-- Expected Result: 2 rows (Dept 50: Human Resources, Dept 60: Research & Development).

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Medium]
-- Find all courses that have at least one enrolled student using EXISTS.
-- ----------------------------------------------------------------------------
SELECT c.course_id, c.course_code, c.course_name
FROM COURSES c
WHERE EXISTS (
    SELECT 1 
    FROM STUDENT_COURSES sc 
    WHERE sc.course_id = c.course_id
)
ORDER BY c.course_id;
-- Expected Result: 7 rows (Courses 201, 202, 203, 204, 205, 206, 207). Course 208 has no enrollments.

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Medium]
-- Find employees who earn more than ANY employee working in Department 20 (using > ANY).
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, salary, department_id
FROM EMPLOYEES
WHERE salary > ANY (
    SELECT salary 
    FROM EMPLOYEES 
    WHERE department_id = 20
)
ORDER BY salary DESC;
-- Expected Result: All employees earning strictly more than the minimum salary in Dept 20 (60,000).

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Find employees who earn more than ALL employees working in Department 30 (using > ALL).
-- ----------------------------------------------------------------------------
SELECT employee_id, first_name, last_name, salary, department_id
FROM EMPLOYEES
WHERE salary > ALL (
    SELECT salary 
    FROM EMPLOYEES 
    WHERE department_id = 30
)
ORDER BY salary DESC;
-- Expected Result: Employees earning strictly more than the maximum salary in Dept 30 (91,000):
-- Robert King (125k), Arthur Dent (110k), and Alice Smith (95k).

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- Use an Inline View (subquery in the FROM clause) to query departments whose
-- average employee salary exceeds $80,000.
-- ----------------------------------------------------------------------------
SELECT 
    dept_summary.department_id,
    dept_summary.staff_count,
    dept_summary.dept_avg_sal
FROM (
    SELECT 
        department_id,
        COUNT(*) AS staff_count,
        ROUND(AVG(salary), 2) AS dept_avg_sal
    FROM EMPLOYEES
    WHERE department_id IS NOT NULL
    GROUP BY department_id
) dept_summary
WHERE dept_summary.dept_avg_sal > 80000
ORDER BY dept_summary.dept_avg_sal DESC;
-- Expected Result: 2 rows (Dept 60: avg 110,000, Dept 10: avg 91,750).
