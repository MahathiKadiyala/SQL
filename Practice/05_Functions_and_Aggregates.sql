-- ============================================================================
-- File: 05_Functions_and_Aggregates.sql
-- Topic: SQL Functions (String, Numeric, Date, NULL, Conversion, Aggregates, and CASE)
-- Dialect: Oracle SQL / ANSI Standard SQL
-- Prerequisites: Run Practice/Data/sample_schema.sql first
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1 [Difficulty: Easy]
-- Display employee names with the first name in UPPERCASE, last name in LOWERCASE,
-- and calculate the character length of the full name.
-- ----------------------------------------------------------------------------
SELECT 
    UPPER(first_name) AS upper_first,
    LOWER(last_name) AS lower_last,
    LENGTH(first_name || ' ' || last_name) AS name_char_count
FROM EMPLOYEES;
-- Expected Result: 12 rows showing formatted names and total length of the combined string.

-- ----------------------------------------------------------------------------
-- Question 2 [Difficulty: Easy]
-- Extract the username (portion before the '@' symbol) from the student emails
-- using SUBSTR and INSTR.
-- ----------------------------------------------------------------------------
SELECT 
    email,
    SUBSTR(email, 1, INSTR(email, '@') - 1) AS student_username
FROM STUDENTS;
-- Expected Result: 10 rows showing usernames (e.g. 'aarav.sharma', 'sophia.chen', 'liam.oconnor').

-- ----------------------------------------------------------------------------
-- Question 3 [Difficulty: Medium]
-- Calculate each employee's tenure in completed months and rounded years as of today.
-- ----------------------------------------------------------------------------
SELECT 
    first_name || ' ' || last_name AS employee_name,
    hire_date,
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS tenure_months,
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date) / 12, 1) AS tenure_years
FROM EMPLOYEES
ORDER BY hire_date;
-- Expected Result: 12 rows showing hiring longevity calculations.

-- ----------------------------------------------------------------------------
-- Question 4 [Difficulty: Easy]
-- Display each employee's salary formatted as currency (e.g., '$85,000.00') using TO_CHAR.
-- ----------------------------------------------------------------------------
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    TO_CHAR(salary, '$999,999.00') AS formatted_salary
FROM EMPLOYEES;
-- Expected Result: 12 rows formatted with dollar sign and commas.

-- ----------------------------------------------------------------------------
-- Question 5 [Difficulty: Medium]
-- Calculate total monthly earnings for employees: base salary + (salary * commission).
-- If commission_pct is NULL, treat it as 0 using NVL.
-- ----------------------------------------------------------------------------
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary,
    NVL(commission_pct, 0) AS commission_rate,
    salary + (salary * NVL(commission_pct, 0)) AS total_monthly_pay
FROM EMPLOYEES;
-- Expected Result: 12 rows with accurate calculations regardless of NULL commissions.

-- ----------------------------------------------------------------------------
-- Question 6 [Difficulty: Medium]
-- Use COALESCE to display an employee's contact method: return phone_number if available;
-- if null, return email; if both null, return 'No Contact Method'.
-- ----------------------------------------------------------------------------
SELECT 
    employee_id,
    first_name,
    last_name,
    COALESCE(phone_number, email, 'No Contact Method') AS primary_contact
FROM EMPLOYEES;
-- Expected Result: 12 rows showing either phone or email fallback.

-- ----------------------------------------------------------------------------
-- Question 7 [Difficulty: Easy]
-- Calculate company-wide salary statistics: total payroll, average salary, minimum,
-- and maximum salary across all employees.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_employees,
    SUM(salary) AS total_payroll,
    ROUND(AVG(salary), 2) AS average_salary,
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary
FROM EMPLOYEES;
-- Expected Result: 1 row summarizing company compensation.

-- ----------------------------------------------------------------------------
-- Question 8 [Difficulty: Medium]
-- Count how many students have an assigned department versus total students.
-- (Demonstrates the difference between COUNT(col) and COUNT(*)).
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_students,
    COUNT(department_id) AS students_with_dept,
    COUNT(*) - COUNT(department_id) AS undeclared_students
FROM STUDENTS;
-- Expected Result: 1 row showing 10 total students, 9 with department, 1 undeclared.

-- ----------------------------------------------------------------------------
-- Question 9 [Difficulty: Medium]
-- Classify students into academic standing tiers using a searched CASE expression:
-- GPA >= 3.8: 'Dean''s Honor List'
-- GPA >= 3.5: 'First Class with Distinction'
-- GPA >= 3.0: 'First Class'
-- ELSE: 'Academic Warning'
-- ----------------------------------------------------------------------------
SELECT 
    student_id,
    first_name || ' ' || last_name AS student_name,
    gpa,
    CASE 
        WHEN gpa >= 3.80 THEN 'Dean''s Honor List'
        WHEN gpa >= 3.50 THEN 'First Class with Distinction'
        WHEN gpa >= 3.00 THEN 'First Class'
        ELSE 'Academic Warning'
    END AS academic_standing
FROM STUDENTS
ORDER BY gpa DESC;
-- Expected Result: 10 rows showing tiered honors classification.

-- ----------------------------------------------------------------------------
-- Question 10 [Difficulty: Medium]
-- Use NVL2 to print whether an employee is eligible for bonus distribution
-- ('Bonus Eligible' if commission_pct is NOT NULL, 'Standard Salary Only' if NULL).
-- ----------------------------------------------------------------------------
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    NVL2(commission_pct, 'Bonus Eligible', 'Standard Salary Only') AS compensation_structure
FROM EMPLOYEES;
-- Expected Result: 12 rows categorizing commissioned vs salaried employees.
