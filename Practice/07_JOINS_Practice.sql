-- ============================================================================
-- File: 07_JOINS_Practice.sql
-- Topic: Relational Table Joins (INNER, LEFT, RIGHT, FULL, CROSS, and SELF Joins)
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Perform an INNER JOIN between EMPLOYEES and DEPARTMENTS to list each employee's
-- full name, job title, department name, and department location.
-- ----------------------------------------------------------------------------
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_title,
    d.department_name,
    d.location
FROM EMPLOYEES e
INNER JOIN DEPARTMENTS d ON e.department_id = d.department_id
ORDER BY e.employee_id;
-- Expected Result: 11 rows. Note that employee 112 (Bruce Wayne) is omitted because
-- his department_id is NULL.

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Easy]
-- Perform a LEFT OUTER JOIN between EMPLOYEES and DEPARTMENTS so that ALL employees
-- are displayed, including those without an assigned department.
-- ----------------------------------------------------------------------------
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    NVL(d.department_name, 'No Department Assigned') AS department_name
FROM EMPLOYEES e
LEFT OUTER JOIN DEPARTMENTS d ON e.department_id = d.department_id
ORDER BY e.employee_id;
-- Expected Result: 12 rows. Bruce Wayne (112) is included with 'No Department Assigned'.

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Medium]
-- Perform a RIGHT OUTER JOIN between EMPLOYEES and DEPARTMENTS to list all
-- departments, including departments with NO assigned employees (like HR, Dept 50).
-- ----------------------------------------------------------------------------
SELECT 
    d.department_id,
    d.department_name,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name
FROM EMPLOYEES e
RIGHT OUTER JOIN DEPARTMENTS d ON e.department_id = d.department_id
ORDER BY d.department_id, e.employee_id;
-- Expected Result: 12 rows. Department 50 (Human Resources) appears with NULL employee details.

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Medium]
-- Perform a FULL OUTER JOIN between STUDENTS and DEPARTMENTS to display all students
-- (even without a major) and all departments (even without enrolled students).
-- ----------------------------------------------------------------------------
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    d.department_id,
    d.department_name
FROM STUDENTS s
FULL OUTER JOIN DEPARTMENTS d ON s.department_id = d.department_id
ORDER BY s.student_id NULLS LAST, d.department_id;
-- Expected Result: 12 rows. Maya Lin (student without department) and Dept 50/60
-- (departments without students) are both preserved in the result.

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Medium]
-- Perform a SELF JOIN on the EMPLOYEES table to display each employee's name
-- alongside their manager's name. Use a LEFT JOIN so the CEO (whose manager_id is NULL)
-- is still displayed.
-- ----------------------------------------------------------------------------
SELECT 
    emp.employee_id,
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.job_title,
    NVL(mgr.first_name || ' ' || mgr.last_name, 'Top Level Executive (No Manager)') AS manager_name
FROM EMPLOYEES emp
LEFT OUTER JOIN EMPLOYEES mgr ON emp.manager_id = mgr.employee_id
ORDER BY emp.employee_id;
-- Expected Result: 12 rows. Robert King (101) shows 'Top Level Executive (No Manager)'.

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Easy]
-- Generate a Cartesian product (CROSS JOIN) between DEPARTMENTS and COURSES for Dept 10.
-- ----------------------------------------------------------------------------
SELECT 
    d.department_name,
    c.course_code,
    c.course_name
FROM DEPARTMENTS d
CROSS JOIN COURSES c
WHERE d.department_id = 10;
-- Expected Result: 8 rows (1 department multiplied by all 8 courses).

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Medium]
-- Join three tables: STUDENTS, STUDENT_COURSES, and COURSES to display student names,
-- course codes, course names, and the letter grade achieved.
-- ----------------------------------------------------------------------------
SELECT 
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_code,
    c.course_name,
    sc.semester,
    sc.grade
FROM STUDENTS s
JOIN STUDENT_COURSES sc ON s.student_id = sc.student_id
JOIN COURSES c          ON sc.course_id = c.course_id
ORDER BY s.first_name, c.course_code;
-- Expected Result: 16 enrollment records detailing student course history.

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Medium]
-- Find students who have NOT enrolled in any course using a LEFT JOIN and IS NULL.
-- ----------------------------------------------------------------------------
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.email
FROM STUDENTS s
LEFT JOIN STUDENT_COURSES sc ON s.student_id = sc.student_id
WHERE sc.enrollment_id IS NULL;
-- Expected Result: 2 rows (Noah Brown, student 9, and Maya Lin, student 10).

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Join EMPLOYEES, DEPARTMENTS, and SALARIES to calculate total compensation
-- (base salary + bonus - deductions) for all employees in Department 10 and 20.
-- ----------------------------------------------------------------------------
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    s.base_salary,
    s.bonus,
    s.deductions,
    (s.base_salary + NVL(s.bonus, 0) - NVL(s.deductions, 0)) AS net_annual_pay
FROM EMPLOYEES e
JOIN DEPARTMENTS d ON e.department_id = d.department_id
JOIN SALARIES s    ON e.employee_id = s.employee_id
WHERE e.department_id IN (10, 20)
ORDER BY net_annual_pay DESC;
-- Expected Result: 7 rows showing complete audited compensation for Dept 10 and 20.

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- Count how many students are enrolled in each department by joining DEPARTMENTS
-- and STUDENTS using a LEFT JOIN so departments with 0 students are shown.
-- ----------------------------------------------------------------------------
SELECT 
    d.department_id,
    d.department_name,
    COUNT(s.student_id) AS enrolled_students_count
FROM DEPARTMENTS d
LEFT JOIN STUDENTS s ON d.department_id = s.department_id
GROUP BY d.department_id, d.department_name
ORDER BY enrolled_students_count DESC, d.department_id;
-- Expected Result: 6 rows. Dept 10 (3), Dept 20 (2), Dept 30 (2), Dept 40 (2),
-- Dept 50 (0), Dept 60 (0).
