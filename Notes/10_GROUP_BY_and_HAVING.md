# Chapter 10: GROUP BY and HAVING

## 1. Topic Title
**Data Aggregation: Grouping Rows (GROUP BY), Filtering Groups (HAVING), and Multi-Column Aggregation**

---

## 2. Simple Definition
- **`GROUP BY`**: A SQL clause that collects data across multiple rows and groups them into summary rows by one or more common column values.
- **`HAVING`**: A filtering clause designed exclusively to filter grouped records *after* aggregate functions have been calculated.
- **Single-Row Filtering (`WHERE`) vs Group Filtering (`HAVING`)**:
  - `WHERE` filters individual rows **before** any grouping or aggregation takes place.
  - `HAVING` filters aggregated summary groups **after** the `GROUP BY` operation has processed the rows.

---

## 3. Why It Is Used
- **Business Intelligence**: Answering real-world executive questions like: "What is the average salary in each department?", "How many students are enrolled per major?", or "Which departments have more than 3 engineers?"
- **Data Reduction**: Compresses thousands of detailed transactional rows into clean, actionable departmental or category metrics.
- **Outlier & Threshold Detection**: Using `HAVING` to isolate departments whose total payroll exceeds $200,000 or classes where average GPA drops below 3.0.

---

## 4. Syntax and Logical Execution Order
```sql
SELECT 
    column1, 
    column2, 
    AGGREGATE_FUNCTION(column3)
FROM table_name
WHERE row_filter_condition               -- Step 1 & 2: FROM & WHERE
GROUP BY column1, column2                 -- Step 3: GROUP BY
HAVING group_filter_condition             -- Step 4: HAVING
ORDER BY column1;                         -- Step 5 & 6: SELECT & ORDER BY
```

### The Cardinal Rule of GROUP BY
> [!IMPORTANT]
> **Every non-aggregate column present in the `SELECT` list MUST be included in the `GROUP BY` clause!**
> If you write: `SELECT department_id, job_title, AVG(salary) FROM EMPLOYEES GROUP BY department_id;`
> Oracle will immediately throw: `ORA-00979: not a GROUP BY expression` because `job_title` is not in the `GROUP BY`.

---

## 5. WHERE vs. HAVING Comparison Table
| Feature | `WHERE` Clause | `HAVING` Clause |
| :--- | :--- | :--- |
| **When it executes** | **Before** rows are grouped | **After** rows are grouped |
| **Works on** | Individual table rows | Summary / grouped rows |
| **Can use aggregates?**| **NO** (e.g., `WHERE AVG(sal) > 5000` is illegal) | **YES** (e.g., `HAVING AVG(sal) > 5000`) |
| **Can be used without GROUP BY?** | **YES** | **YES** (Treats entire table as 1 group) |
| **Performance** | Faster (reduces rows before grouping) | Applied after grouping cost is incurred |

---

## 6. 10 Explained Queries Demonstrating GROUP BY and HAVING

### Query 1: Basic Count and Average per Department
```sql
-- Count employees and calculate average salary per department
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    ROUND(AVG(salary), 2) AS avg_salary
FROM EMPLOYEES
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
```
*Groups employees by `department_id`. For each department bucket, counts rows and calculates the mathematical average of `salary`.*

### Query 2: Multiple Aggregates in One Summary
```sql
-- Comprehensive payroll metrics per department
SELECT 
    department_id,
    COUNT(*) AS headcount,
    MIN(salary) AS lowest_pay,
    MAX(salary) AS highest_pay,
    SUM(salary) AS total_payroll
FROM EMPLOYEES
GROUP BY department_id;
```
*Demonstrates running multiple aggregate functions (`COUNT`, `MIN`, `MAX`, `SUM`) simultaneously on each grouped department.*

### Query 3: Multi-Column Grouping (Department + Job Title)
```sql
-- Break down employee count and average salary by department and job title
SELECT 
    department_id,
    job_title,
    COUNT(*) AS num_staff,
    ROUND(AVG(salary), 2) AS avg_salary
FROM EMPLOYEES
GROUP BY department_id, job_title
ORDER BY department_id, num_staff DESC;
```
*Creates subgroups for unique pairs of `(department_id, job_title)`. If Dept 10 has 2 Software Engineers, they form their own subgroup.*

### Query 4: Filtering Groups with HAVING
```sql
-- Find departments with more than 2 employees
SELECT 
    department_id,
    COUNT(*) AS total_staff
FROM EMPLOYEES
GROUP BY department_id
HAVING COUNT(*) > 2;
```
*`HAVING COUNT(*) > 2` discards any department group that has 2 or fewer employees, keeping only large departments (Dept 10 has 4 employees, Dept 20 has 3, Dept 30 has 3).*

### Query 5: Combining WHERE and HAVING in the Same Query
```sql
-- High earner departments: departments where staff earning > 60k average over 80k
SELECT 
    department_id,
    COUNT(*) AS qualifying_staff,
    ROUND(AVG(salary), 2) AS dept_avg_salary
FROM EMPLOYEES
WHERE salary > 60000                     -- 1. Filters out low-paid rows FIRST
GROUP BY department_id                   -- 2. Groups the remaining qualifying rows
HAVING AVG(salary) >= 80000;             -- 3. Filters out groups with low group averages
```
*`WHERE` filters the individual rows first; `HAVING` filters the resulting aggregate averages.*

### Query 6: Counting Distinct Values within Groups
```sql
-- Count how many distinct job titles exist within each department
SELECT 
    department_id,
    COUNT(DISTINCT job_title) AS unique_roles,
    COUNT(*) AS total_employees
FROM EMPLOYEES
GROUP BY department_id;
```
*`COUNT(DISTINCT job_title)` tallies unique roles within that specific department group.*

### Query 7: Student GPA Metrics by Department
```sql
-- Average student GPA per department, only showing departments with avg GPA >= 3.5
SELECT 
    department_id,
    COUNT(*) AS student_count,
    ROUND(AVG(gpa), 2) AS avg_gpa,
    MAX(gpa) AS highest_gpa
FROM STUDENTS
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING AVG(gpa) >= 3.50;
```
*Evaluates the `STUDENTS` table, grouping by major and keeping only high-performing departments.*

### Query 8: Grouping on Calculated Expressions
```sql
-- Group employees by hiring decade/year
SELECT 
    TO_CHAR(hire_date, 'YYYY') AS hire_year,
    COUNT(*) AS employees_hired,
    ROUND(AVG(salary), 2) AS avg_starting_salary
FROM EMPLOYEES
GROUP BY TO_CHAR(hire_date, 'YYYY')
ORDER BY hire_year;
```
*Groups records by the result of an expression (`TO_CHAR(hire_date, 'YYYY')`).*

### Query 9: Course Enrollment Analysis
```sql
-- Find courses with at least 2 student enrollments
SELECT 
    course_id,
    COUNT(student_id) AS total_enrolled
FROM STUDENT_COURSES
GROUP BY course_id
HAVING COUNT(student_id) >= 2
ORDER BY total_enrolled DESC;
```
*Aggregates bridge records in `STUDENT_COURSES` by `course_id` and filters out lightly attended courses.*

### Query 10: HAVING with Multiple Aggregate Conditions
```sql
-- Departments with at least 3 employees AND total payroll exceeding $200,000
SELECT 
    department_id,
    COUNT(*) AS staff_count,
    SUM(salary) AS total_payroll
FROM EMPLOYEES
GROUP BY department_id
HAVING COUNT(*) >= 3 AND SUM(salary) > 200000;
```
*Applies compound Boolean logic inside the `HAVING` clause using `AND`.*

---

## 7. Sample Input Table: `EMPLOYEES`
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | DEPARTMENT_ID | SALARY |
| :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | 10 | 125000 |
| 102 | Alice | Smith | 10 | 95000 |
| 104 | Michael | Scott | 10 | 82000 |
| 105 | Elena | Rostova | 10 | 65000 |
| 103 | David | Clark | 20 | 88000 |
| 106 | Priya | Patel | 20 | 78000 |
| 107 | James | Wilson | 20 | 60000 |
| 108 | Sarah | Connor | 30 | 91000 |
| 109 | Carlos | Mendoza | 30 | 71000 |
| 110 | Jessica | Taylor | 30 | 48000 |
| 111 | Arthur | Dent | 60 | 110000 |

---

## 8. Expected Output for Query 10
Running Query 10:
```sql
SELECT 
    department_id,
    COUNT(*) AS staff_count,
    SUM(salary) AS total_payroll
FROM EMPLOYEES
GROUP BY department_id
HAVING COUNT(*) >= 3 AND SUM(salary) > 200000;
```

| DEPARTMENT_ID | STAFF_COUNT | TOTAL_PAYROLL |
| :--- | :--- | :--- |
| 10 | 4 | 367000 |
| 20 | 3 | 226000 |
| 30 | 3 | 210000 |

*(Note: Dept 60 has total salary 110,000 and staff count 1, so it fails both HAVING conditions and is omitted).*

---

## 9. Step-by-Step Explanation of How the Grouping Engine Works
1. **Row Collection (`FROM EMPLOYEES`)**: All 11 records are gathered.
2. **Partitioning into Buckets (`GROUP BY department_id`)**: The engine sorts/hashes rows into distinct bins:
   - Bucket `10`: Rows (101, 102, 104, 105)
   - Bucket `20`: Rows (103, 106, 107)
   - Bucket `30`: Rows (108, 109, 110)
   - Bucket `60`: Row (111)
3. **Aggregate Calculation**:
   - Bucket `10`: `COUNT = 4`, `SUM = 367,000`
   - Bucket `20`: `COUNT = 3`, `SUM = 226,000`
   - Bucket `30`: `COUNT = 3`, `SUM = 210,000`
   - Bucket `60`: `COUNT = 1`, `SUM = 110,000`
4. **Group Filtering (`HAVING COUNT(*) >= 3 AND SUM(salary) > 200000`)**:
   - Bucket 10: `4 >= 3` (True) and `367k > 200k` (True) -> **PASS**
   - Bucket 20: `3 >= 3` (True) and `226k > 200k` (True) -> **PASS**
   - Bucket 30: `3 >= 3` (True) and `210k > 200k` (True) -> **PASS**
   - Bucket 60: `1 >= 3` (False) -> **DISCARDED**
5. **Projection (`SELECT`)**: Produces the final summary table.

---

## 10. Common Mistakes
1. **The ORA-00979 Error (Not a GROUP BY expression)**: Including columns in `SELECT` that are neither aggregated nor part of the `GROUP BY` clause.
2. **Putting Aggregate Conditions in WHERE**: Writing `WHERE AVG(salary) > 50000`. Aggregate calculations do not exist yet when `WHERE` is being evaluated! You must place group conditions in `HAVING`.
3. **Filtering Non-Aggregates in HAVING**: Writing `HAVING department_id = 10`. While technically legal in SQL, it is poor practice because it forces the database to group rows it could have filtered earlier in `WHERE`. Non-aggregate row filters belong in `WHERE`.
4. **Using Column Aliases in GROUP BY / HAVING**: In standard Oracle SQL, you cannot use an alias defined in `SELECT` inside the `GROUP BY` or `HAVING` clause because `GROUP BY` executes before `SELECT`.

---

## 11. Interview Questions
1. **What is the difference between `WHERE` and `HAVING`?**
   - *Answer*: `WHERE` filters individual rows before grouping occurs and cannot contain aggregate functions. `HAVING` filters grouped summary records after aggregation and is used with aggregate functions.
2. **Can `HAVING` be used without a `GROUP BY` clause?**
   - *Answer*: Yes. If used without `GROUP BY`, `HAVING` treats the entire result set as a single group (e.g., `SELECT AVG(salary) FROM EMPLOYEES HAVING AVG(salary) > 50000;`).
3. **What causes the `ORA-00979: not a GROUP BY expression` error?**
   - *Answer*: Selecting an individual non-aggregated column in the `SELECT` list that was omitted from the `GROUP BY` clause.
4. **Can you group by more than one column?**
   - *Answer*: Yes. Grouping by multiple columns creates sub-categories for each distinct combination of values across all specified columns.

---

## 12. Short Summary
- `GROUP BY` summarizes rows into buckets based on matching values.
- Every non-aggregate column in the `SELECT` list must be listed in `GROUP BY`.
- `WHERE` filters raw rows before aggregation; `HAVING` filters summary metrics after aggregation.
