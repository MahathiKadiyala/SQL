-- ============================================================================
-- File: sample_schema.sql
-- Description: Reusable Sample Database Schema for SQL Learning Workspace
-- Dialect: Oracle SQL (compatible with standard ANSI SQL & Oracle 11g/12c/19c/21c/23c)
-- ============================================================================
-- Tables Created:
--   1. DEPARTMENTS      - Department master records
--   2. EMPLOYEES        - Staff details, salaries, managers, department mappings
--   3. SALARIES         - Historical and current compensation records
--   4. STUDENTS         - Student profiles, GPAs, department affiliations
--   5. COURSES          - Course catalog offered by departments
--   6. STUDENT_COURSES  - Student enrollment, semester, and grade tracking
-- ============================================================================
-- Execution Order:
--   1. Drop child tables first, then parent tables (to respect foreign keys).
--   2. Create parent tables first, then child tables.
--   3. Insert lookup data (Departments, Courses), followed by Parents (Employees, Students),
--      and finally Child relations (Salaries, Student_Courses).
--   4. Run COMMIT to persist all changes.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STEP 1: SAFE DROP OF EXISTING TABLES (Child tables dropped before parent tables)
-- ----------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE STUDENT_COURSES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE COURSES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SALARIES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE STUDENTS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE EMPLOYEES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- ----------------------------------------------------------------------------
-- STEP 2: CREATE TABLES AND CONSTRAINTS
-- ----------------------------------------------------------------------------

-- 1. DEPARTMENTS Table
CREATE TABLE DEPARTMENTS (
    department_id       NUMBER(5)           PRIMARY KEY,
    department_name     VARCHAR2(50)        NOT NULL UNIQUE,
    location            VARCHAR2(50)        NOT NULL
);

-- 2. EMPLOYEES Table (Includes Self-Referential Foreign Key for Manager)
CREATE TABLE EMPLOYEES (
    employee_id         NUMBER(5)           PRIMARY KEY,
    first_name          VARCHAR2(50)        NOT NULL,
    last_name           VARCHAR2(50)        NOT NULL,
    email               VARCHAR2(100)       NOT NULL UNIQUE,
    phone_number        VARCHAR2(20),
    hire_date           DATE                NOT NULL,
    job_title           VARCHAR2(50)        NOT NULL,
    salary              NUMBER(10, 2)       NOT NULL CHECK (salary > 0),
    commission_pct      NUMBER(3, 2)        CHECK (commission_pct BETWEEN 0 AND 1),
    manager_id          NUMBER(5),
    department_id       NUMBER(5),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) 
        REFERENCES DEPARTMENTS(department_id),
    CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id) 
        REFERENCES EMPLOYEES(employee_id)
);

-- 3. SALARIES Table (Compensation & Payroll details)
CREATE TABLE SALARIES (
    salary_id           NUMBER(5)           PRIMARY KEY,
    employee_id         NUMBER(5)           NOT NULL,
    effective_date      DATE                NOT NULL,
    base_salary         NUMBER(10, 2)       NOT NULL CHECK (base_salary > 0),
    bonus               NUMBER(10, 2)       DEFAULT 0 CHECK (bonus >= 0),
    deductions          NUMBER(10, 2)       DEFAULT 0 CHECK (deductions >= 0),
    CONSTRAINT fk_sal_emp FOREIGN KEY (employee_id) 
        REFERENCES EMPLOYEES(employee_id)
);

-- 4. STUDENTS Table
CREATE TABLE STUDENTS (
    student_id          NUMBER(5)           PRIMARY KEY,
    first_name          VARCHAR2(50)        NOT NULL,
    last_name           VARCHAR2(50)        NOT NULL,
    email               VARCHAR2(100)       NOT NULL UNIQUE,
    gender              CHAR(1)             CHECK (gender IN ('M', 'F', 'O')),
    date_of_birth       DATE,
    department_id       NUMBER(5),
    gpa                 NUMBER(3, 2)        CHECK (gpa BETWEEN 0.00 AND 4.00),
    enrollment_date     DATE                DEFAULT SYSDATE,
    CONSTRAINT fk_stud_dept FOREIGN KEY (department_id) 
        REFERENCES DEPARTMENTS(department_id)
);

-- 5. COURSES Table
CREATE TABLE COURSES (
    course_id           NUMBER(5)           PRIMARY KEY,
    course_code         VARCHAR2(10)        NOT NULL UNIQUE,
    course_name         VARCHAR2(100)       NOT NULL,
    credits             NUMBER(2)           NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id       NUMBER(5),
    CONSTRAINT fk_course_dept FOREIGN KEY (department_id) 
        REFERENCES DEPARTMENTS(department_id)
);

-- 6. STUDENT_COURSES Table (Many-to-Many Bridge Table)
CREATE TABLE STUDENT_COURSES (
    enrollment_id       NUMBER(5)           PRIMARY KEY,
    student_id          NUMBER(5)           NOT NULL,
    course_id           NUMBER(5)           NOT NULL,
    semester            VARCHAR2(20)        NOT NULL,
    grade               VARCHAR2(2)         CHECK (grade IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F')),
    CONSTRAINT fk_sc_student FOREIGN KEY (student_id) 
        REFERENCES STUDENTS(student_id),
    CONSTRAINT fk_sc_course FOREIGN KEY (course_id) 
        REFERENCES COURSES(course_id),
    CONSTRAINT uq_student_course_sem UNIQUE (student_id, course_id, semester)
);

-- ----------------------------------------------------------------------------
-- STEP 3: INSERT REALISTIC SAMPLE DATA
-- ----------------------------------------------------------------------------

-- Insert Departments
-- Note: Dept 50 (Human Resources) has no employees or students (useful for outer join tests)
-- Note: Dept 60 (Research) has employees but no students
INSERT INTO DEPARTMENTS (department_id, department_name, location) 
VALUES (10, 'Computer Science', 'Tech Hall 1');

INSERT INTO DEPARTMENTS (department_id, department_name, location) 
VALUES (20, 'Information Technology', 'Tech Hall 2');

INSERT INTO DEPARTMENTS (department_id, department_name, location) 
VALUES (30, 'Mechanical Engineering', 'Engineering Block A');

INSERT INTO DEPARTMENTS (department_id, department_name, location) 
VALUES (40, 'Electrical Engineering', 'Engineering Block B');

INSERT INTO DEPARTMENTS (department_id, department_name, location) 
VALUES (50, 'Human Resources', 'Admin Building');

INSERT INTO DEPARTMENTS (department_id, department_name, location) 
VALUES (60, 'Research & Development', 'Innovation Hub');

-- Insert Employees
-- Hierarchy:
-- 101 (CEO/Director - manager_id NULL)
--   ├── 102 (Tech Manager, Dept 10)
--   │     ├── 104 (Senior Software Eng, Dept 10)
--   │     └── 105 (Software Eng, Dept 10)
--   ├── 103 (IT Manager, Dept 20)
--   │     ├── 106 (Database Admin, Dept 20)
--   │     └── 107 (Systems Analyst, Dept 20)
--   ├── 108 (Engineering Lead, Dept 30)
--   │     ├── 109 (Mechanical Eng, Dept 30)
--   │     └── 110 (Junior Designer, Dept 30)
--   ├── 111 (R&D Director, Dept 60)
--   └── 112 (Contract Consultant, unassigned dept NULL, manager 101)

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (101, 'Robert', 'King', 'robert.king@company.com', '555-0101', TO_DATE('2018-01-15', 'YYYY-MM-DD'), 'President & CEO', 125000.00, NULL, NULL, 10);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (102, 'Alice', 'Smith', 'alice.smith@company.com', '555-0102', TO_DATE('2019-03-20', 'YYYY-MM-DD'), 'Engineering Director', 95000.00, 0.15, 101, 10);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (103, 'David', 'Clark', 'david.clark@company.com', '555-0103', TO_DATE('2019-06-10', 'YYYY-MM-DD'), 'IT Manager', 88000.00, 0.10, 101, 20);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (104, 'Michael', 'Scott', 'michael.scott@company.com', '555-0104', TO_DATE('2020-02-01', 'YYYY-MM-DD'), 'Senior Software Engineer', 82000.00, NULL, 102, 10);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (105, 'Elena', 'Rostova', 'elena.rostova@company.com', '555-0105', TO_DATE('2021-08-15', 'YYYY-MM-DD'), 'Software Engineer', 65000.00, NULL, 102, 10);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (106, 'Priya', 'Patel', 'priya.patel@company.com', '555-0106', TO_DATE('2020-11-05', 'YYYY-MM-DD'), 'Database Administrator', 78000.00, 0.05, 103, 20);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (107, 'James', 'Wilson', 'james.wilson@company.com', '555-0107', TO_DATE('2022-01-18', 'YYYY-MM-DD'), 'Systems Analyst', 60000.00, NULL, 103, 20);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (108, 'Sarah', 'Connor', 'sarah.connor@company.com', '555-0108', TO_DATE('2019-09-01', 'YYYY-MM-DD'), 'Mechanical Dept Lead', 91000.00, 0.12, 101, 30);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (109, 'Carlos', 'Mendoza', 'carlos.mendoza@company.com', '555-0109', TO_DATE('2021-04-12', 'YYYY-MM-DD'), 'Mechanical Engineer', 71000.00, NULL, 108, 30);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (110, 'Jessica', 'Taylor', 'jessica.taylor@company.com', '555-0110', TO_DATE('2023-02-20', 'YYYY-MM-DD'), 'Junior CAD Designer', 48000.00, NULL, 108, 30);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (111, 'Arthur', 'Dent', 'arthur.dent@company.com', '555-0111', TO_DATE('2018-05-14', 'YYYY-MM-DD'), 'Principal Scientist', 110000.00, 0.20, 101, 60);

INSERT INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, job_title, salary, commission_pct, manager_id, department_id)
VALUES (112, 'Bruce', 'Wayne', 'bruce.wayne@company.com', '555-0112', TO_DATE('2023-07-01', 'YYYY-MM-DD'), 'External Strategy Advisor', 85000.00, NULL, 101, NULL);

-- Insert Salaries
INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (501, 101, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 125000.00, 15000.00, 3500.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (502, 102, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 95000.00, 10000.00, 2800.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (503, 103, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 88000.00, 8000.00, 2400.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (504, 104, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 82000.00, 6000.00, 2200.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (505, 105, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 65000.00, 4000.00, 1800.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (506, 106, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 78000.00, 5000.00, 2000.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (507, 107, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 60000.00, 3000.00, 1500.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (508, 108, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 91000.00, 9500.00, 2600.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (509, 109, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 71000.00, 4500.00, 1900.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (510, 110, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 48000.00, 2000.00, 1200.00);

INSERT INTO SALARIES (salary_id, employee_id, effective_date, base_salary, bonus, deductions)
VALUES (511, 111, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 110000.00, 12000.00, 3100.00);

-- Insert Students
-- Note: Student 10 has NULL department_id (unassigned major)
-- Note: Student 9 & 10 have no course enrollments (for testing LEFT/RIGHT JOIN)
INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (1, 'Aarav', 'Sharma', 'aarav.sharma@univ.edu', 'M', TO_DATE('2003-04-12', 'YYYY-MM-DD'), 10, 3.85, TO_DATE('2021-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (2, 'Sophia', 'Chen', 'sophia.chen@univ.edu', 'F', TO_DATE('2002-11-25', 'YYYY-MM-DD'), 10, 3.92, TO_DATE('2020-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (3, 'Liam', 'OConnor', 'liam.oconnor@univ.edu', 'M', TO_DATE('2003-01-18', 'YYYY-MM-DD'), 20, 3.20, TO_DATE('2021-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (4, 'Ananya', 'Iyer', 'ananya.iyer@univ.edu', 'F', TO_DATE('2004-06-30', 'YYYY-MM-DD'), 20, 3.75, TO_DATE('2022-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (5, 'Marcus', 'Johnson', 'marcus.j@univ.edu', 'M', TO_DATE('2002-09-14', 'YYYY-MM-DD'), 30, 2.95, TO_DATE('2020-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (6, 'Emma', 'Watson', 'emma.watson@univ.edu', 'F', TO_DATE('2003-03-05', 'YYYY-MM-DD'), 30, 3.60, TO_DATE('2021-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (7, 'Rohan', 'Verma', 'rohan.verma@univ.edu', 'M', TO_DATE('2004-02-28', 'YYYY-MM-DD'), 40, 3.40, TO_DATE('2022-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (8, 'Zoe', 'Kravitz', 'zoe.k@univ.edu', 'F', TO_DATE('2003-12-19', 'YYYY-MM-DD'), 40, 3.88, TO_DATE('2021-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (9, 'Noah', 'Brown', 'noah.brown@univ.edu', 'M', TO_DATE('2004-07-22', 'YYYY-MM-DD'), 10, 2.80, TO_DATE('2022-08-01', 'YYYY-MM-DD'));

INSERT INTO STUDENTS (student_id, first_name, last_name, email, gender, date_of_birth, department_id, gpa, enrollment_date)
VALUES (10, 'Maya', 'Lin', 'maya.lin@univ.edu', 'F', TO_DATE('2004-10-10', 'YYYY-MM-DD'), NULL, 3.50, TO_DATE('2022-08-01', 'YYYY-MM-DD'));

-- Insert Courses
-- Note: Course 304 has department_id NULL (general university elective)
-- Note: Course 305 has no enrolled students (useful for outer join tests)
INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (201, 'CS101', 'Introduction to Computer Science', 4, 10);

INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (202, 'CS201', 'Data Structures & Algorithms', 4, 10);

INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (203, 'IT105', 'Database Management Systems', 3, 20);

INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (204, 'IT220', 'Web Technologies', 3, 20);

INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (205, 'ME101', 'Engineering Thermodynamics', 4, 30);

INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (206, 'EE102', 'Circuits and Systems', 4, 40);

INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (207, 'GEN100', 'Critical Thinking & Ethics', 2, NULL);

INSERT INTO COURSES (course_id, course_code, course_name, credits, department_id)
VALUES (208, 'ME302', 'Robotics and Automation', 3, 30);

-- Insert Student Courses (Enrollments)
-- Student 1
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1001, 1, 201, 'Fall 2021', 'A');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1002, 1, 202, 'Spring 2022', 'A');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1003, 1, 203, 'Fall 2022', 'A+');

-- Student 2
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1004, 2, 201, 'Fall 2020', 'A+');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1005, 2, 202, 'Spring 2021', 'A');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1006, 2, 203, 'Fall 2021', 'A');

-- Student 3
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1007, 3, 203, 'Fall 2021', 'B');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1008, 3, 204, 'Spring 2022', 'B+');

-- Student 4
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1009, 4, 203, 'Fall 2022', 'A');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1010, 4, 204, 'Spring 2023', 'A');

-- Student 5
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1011, 5, 205, 'Fall 2020', 'C+');

-- Student 6
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1012, 6, 205, 'Fall 2021', 'B+');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1013, 6, 207, 'Spring 2022', 'A');

-- Student 7
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1014, 7, 206, 'Fall 2022', 'B');

-- Student 8
INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1015, 8, 206, 'Fall 2021', 'A');

INSERT INTO STUDENT_COURSES (enrollment_id, student_id, course_id, semester, grade)
VALUES (1016, 8, 207, 'Spring 2022', 'A');

-- ----------------------------------------------------------------------------
-- STEP 4: PERSIST ALL TRANSACTIONS
-- ----------------------------------------------------------------------------
COMMIT;

-- Verification Query to check row counts
SELECT 'DEPARTMENTS' AS table_name, COUNT(*) AS total_rows FROM DEPARTMENTS
UNION ALL
SELECT 'EMPLOYEES', COUNT(*) FROM EMPLOYEES
UNION ALL
SELECT 'SALARIES', COUNT(*) FROM SALARIES
UNION ALL
SELECT 'STUDENTS', COUNT(*) FROM STUDENTS
UNION ALL
SELECT 'COURSES', COUNT(*) FROM COURSES
UNION ALL
SELECT 'STUDENT_COURSES', COUNT(*) FROM STUDENT_COURSES;
