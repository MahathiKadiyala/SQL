-- ============================================================================
-- File: 09_Mixed_Practice_Questions.sql
-- Topic: Mixed Comprehensive Practice Questions (Basics to Joins & Subqueries)
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================
-- HOW TO USE THIS WORKSPACE FILE:
--   Part 1 lists 25 practice questions with difficulty tags and expected results.
--   Try solving each question in your own scratch buffer before scrolling down!
--   Part 2 contains the complete, tested solution queries for every question.
-- ============================================================================

-- ============================================================================
-- PART 1: PRACTICE QUESTIONS (TRY SOLVING THESE FIRST!)
-- ============================================================================

-- [Q01] [Easy]
-- Select the first name, last name, and hire date of all employees hired in 2021 or later.
-- Expected: Carlos Mendoza, Elena Rostova, James Wilson, Jessica Taylor, Bruce Wayne.

-- [Q02] [Easy]
-- Find all courses that carry 4 credits, ordered by course code.
-- Expected: CS101, CS201, EE102, ME101.

-- [Q03] [Easy]
-- Display the full name of all students in uppercase with their GPA, sorted from highest to lowest GPA.
-- Expected: 10 rows headed by Sophia Chen (3.92) down to Noah Brown (2.80).

-- [Q04] [Easy]
-- Find all employees whose commission percentage is NULL.
-- Expected: 7 rows (Robert King, Michael Scott, Elena Rostova, James Wilson, Carlos Mendoza, Jessica Taylor, Bruce Wayne).

-- [Q05] [Medium]
-- Display the top 3 highest earning employees with their name, job title, and salary.
-- Expected: Robert King (125k), Arthur Dent (110k), Alice Smith (95k).

-- [Q06] [Easy]
-- Find all employees whose last name ends with the letter 'n'.
-- Expected: James Wilson, Arthur Dent, Bruce Wayne.

-- [Q07] [Medium]
-- List each department and calculate the total number of characters in its department name.
-- Expected: 6 rows with lengths ranging from 15 to 22 characters.

-- [Q08] [Medium]
-- Display each student's date of birth formatted as 'DD-Month-YYYY' (e.g., '12-April-2003').
-- Expected: 10 rows formatted with full month names.

-- [Q09] [Easy]
-- Find all students who have a GPA strictly between 3.00 and 3.70 (exclusive).
-- Expected: Liam OConnor (3.20), Rohan Verma (3.40), Maya Lin (3.50), Emma Watson (3.60).

-- [Q10] [Medium]
-- Calculate the net salary for each record in the SALARIES table (base_salary + bonus - deductions)
-- alongside the employee_id, ordered by net salary descending.
-- Expected: 11 rows headed by Employee 101 ($136,500.00).

-- [Q11] [Medium]
-- Group employees by department_id and show the maximum and minimum salary for each department.
-- Expected: 4 rows for departments 10, 20, 30, and 60.

-- [Q12] [Medium]
-- Find departments that have more than 2 employees and where the minimum salary is at least $60,000.
-- Expected: Department 10 (min 65k) and Department 20 (min 60k).

-- [Q13] [Medium]
-- List each student's name along with the title of their department using an INNER JOIN.
-- Expected: 9 rows (excludes Maya Lin whose department_id is NULL).

-- [Q14] [Medium]
-- List ALL departments and the count of employees in each department using a LEFT JOIN
-- so that departments with zero employees (like HR) show a count of 0.
-- Expected: 6 rows, including Human Resources (0) and Electrical Engineering (0).

-- [Q15] [Medium]
-- Display every employee's name along with their direct manager's name using a SELF JOIN.
-- If the employee has no manager (CEO), display 'NO MANAGER'.
-- Expected: 12 rows with CEO showing 'NO MANAGER'.

-- [Q16] [Medium]
-- Find all courses taught by the 'Computer Science' department by joining COURSES and DEPARTMENTS.
-- Expected: CS101 (Intro to CS) and CS201 (Data Structures & Algorithms).

-- [Q17] [Medium]
-- Find all students who received a grade of 'A' or 'A+' in any course, listing student name,
-- course code, and grade.
-- Expected: 10 enrollment rows.

-- [Q18] [Medium]
-- Find all employees who earn strictly more than the company-wide average salary using a subquery.
-- Expected: 6 rows (Robert King, Arthur Dent, Alice Smith, Sarah Connor, David Clark, Michael Scott).

-- [Q19] [Medium]
-- Find the 2nd lowest salary among all employees using a subquery.
-- Expected: $60,000.00 (James Wilson), since the lowest is $48,000 (Jessica Taylor).

-- [Q20] [Medium]
-- Find departments that have NO courses registered under them using NOT EXISTS.
-- Expected: Department 50 (Human Resources) and Department 60 (Research & Development).

-- [Q21] [Medium]
-- Find all students enrolled in the course 'Database Management Systems' (course_code 'IT105')
-- using a subquery in WHERE.
-- Expected: 4 students (Aarav Sharma, Sophia Chen, Liam OConnor, Ananya Iyer).

-- [Q22] [Medium]
-- Find the department name that has the highest average employee salary using an inline view or subquery.
-- Expected: 'Research & Development' (average 110,000).

-- [Q23] [Medium]
-- List each employee's name, salary, and how much their salary differs from the company average salary.
-- Expected: 12 rows showing positive differences for high earners and negative for lower earners.

-- [Q24] [Medium]
-- Using a CASE expression, categorize each course as 'Introductory' if code ends with '101' or '100',
-- 'Intermediate' if code contains '20', and 'Advanced' otherwise.
-- Expected: 8 courses classified into Introductory, Intermediate, and Advanced tiers.

-- [Q25] [Medium]
-- Find all students who have enrolled in more than 2 courses using a subquery or GROUP BY with HAVING.
-- Expected: Aarav Sharma (3 courses) and Sophia Chen (3 courses).


-- ============================================================================
-- PART 2: COMPLETE SOLUTIONS AND QUERY ANSWERS
-- ============================================================================

-- [Solution Q01]
SELECT first_name, last_name, hire_date
FROM EMPLOYEES
WHERE hire_date >= TO_DATE('2021-01-01', 'YYYY-MM-DD')
ORDER BY hire_date;

-- [Solution Q02]
SELECT course_code, course_name, credits
FROM COURSES
WHERE credits = 4
ORDER BY course_code;

-- [Solution Q03]
SELECT 
    UPPER(first_name || ' ' || last_name) AS student_name,
    gpa
FROM STUDENTS
ORDER BY gpa DESC;

-- [Solution Q04]
SELECT employee_id, first_name, last_name, job_title
FROM EMPLOYEES
WHERE commission_pct IS NULL;

-- [Solution Q05]
SELECT * FROM (
    SELECT first_name, last_name, job_title, salary
    FROM EMPLOYEES
    ORDER BY salary DESC
)
WHERE ROWNUM <= 3;

-- [Solution Q06]
SELECT employee_id, first_name, last_name
FROM EMPLOYEES
WHERE last_name LIKE '%n';

-- [Solution Q07]
SELECT 
    department_name, 
    LENGTH(department_name) AS name_length
FROM DEPARTMENTS
ORDER BY name_length DESC;

-- [Solution Q08]
SELECT 
    first_name || ' ' || last_name AS student_name,
    TO_CHAR(date_of_birth, 'DD-Month-YYYY') AS formatted_dob
FROM STUDENTS
WHERE date_of_birth IS NOT NULL;

-- [Solution Q09]
SELECT student_id, first_name, last_name, gpa
FROM STUDENTS
WHERE gpa > 3.00 AND gpa < 3.70
ORDER BY gpa DESC;

-- [Solution Q10]
SELECT 
    salary_id,
    employee_id,
    base_salary,
    bonus,
    deductions,
    (base_salary + NVL(bonus, 0) - NVL(deductions, 0)) AS net_salary
FROM SALARIES
ORDER BY net_salary DESC;

-- [Solution Q11]
SELECT 
    department_id,
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM EMPLOYEES
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;

-- [Solution Q12]
SELECT 
    department_id,
    COUNT(*) AS total_staff,
    MIN(salary) AS min_sal
FROM EMPLOYEES
GROUP BY department_id
HAVING COUNT(*) > 2 AND MIN(salary) >= 60000;

-- [Solution Q13]
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    d.department_name
FROM STUDENTS s
INNER JOIN DEPARTMENTS d ON s.department_id = d.department_id;

-- [Solution Q14]
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM DEPARTMENTS d
LEFT JOIN EMPLOYEES e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_employees DESC, d.department_id;

-- [Solution Q15]
SELECT 
    emp.employee_id,
    emp.first_name || ' ' || emp.last_name AS employee_name,
    NVL(mgr.first_name || ' ' || mgr.last_name, 'NO MANAGER') AS manager_name
FROM EMPLOYEES emp
LEFT JOIN EMPLOYEES mgr ON emp.manager_id = mgr.employee_id
ORDER BY emp.employee_id;

-- [Solution Q16]
SELECT 
    c.course_code,
    c.course_name,
    c.credits,
    d.department_name
FROM COURSES c
JOIN DEPARTMENTS d ON c.department_id = d.department_id
WHERE d.department_name = 'Computer Science';

-- [Solution Q17]
SELECT 
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_code,
    sc.grade
FROM STUDENTS s
JOIN STUDENT_COURSES sc ON s.student_id = sc.student_id
JOIN COURSES c          ON sc.course_id = c.course_id
WHERE sc.grade IN ('A', 'A+')
ORDER BY s.first_name;

-- [Solution Q18]
SELECT employee_id, first_name, last_name, salary
FROM EMPLOYEES
WHERE salary > (SELECT AVG(salary) FROM EMPLOYEES)
ORDER BY salary DESC;

-- [Solution Q19]
SELECT MIN(salary) AS second_lowest_salary
FROM EMPLOYEES
WHERE salary > (SELECT MIN(salary) FROM EMPLOYEES);

-- [Solution Q20]
SELECT d.department_id, d.department_name
FROM DEPARTMENTS d
WHERE NOT EXISTS (
    SELECT 1 
    FROM COURSES c 
    WHERE c.department_id = d.department_id
);

-- [Solution Q21]
SELECT student_id, first_name, last_name, email
FROM STUDENTS
WHERE student_id IN (
    SELECT sc.student_id
    FROM STUDENT_COURSES sc
    JOIN COURSES c ON sc.course_id = c.course_id
    WHERE c.course_code = 'IT105'
);

-- [Solution Q22]
SELECT department_name, avg_sal
FROM (
    SELECT 
        d.department_name,
        ROUND(AVG(e.salary), 2) AS avg_sal
    FROM DEPARTMENTS d
    JOIN EMPLOYEES e ON d.department_id = e.department_id
    GROUP BY d.department_name
    ORDER BY avg_sal DESC
)
WHERE ROWNUM = 1;

-- [Solution Q23]
SELECT 
    first_name || ' ' || last_name AS employee_name,
    salary,
    ROUND(salary - (SELECT AVG(salary) FROM EMPLOYEES), 2) AS diff_from_company_avg
FROM EMPLOYEES
ORDER BY diff_from_company_avg DESC;

-- [Solution Q24]
SELECT 
    course_code,
    course_name,
    CASE 
        WHEN course_code LIKE '%101' OR course_code LIKE '%100' THEN 'Introductory'
        WHEN course_code LIKE '%20%' THEN 'Intermediate'
        ELSE 'Advanced'
    END AS course_tier
FROM COURSES
ORDER BY course_code;

-- [Solution Q25]
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    COUNT(sc.course_id) AS enrolled_courses_count
FROM STUDENTS s
JOIN STUDENT_COURSES sc ON s.student_id = sc.student_id
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(sc.course_id) > 2;
