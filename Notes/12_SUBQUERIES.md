# Chapter 12: SUBQUERIES

## 1. Topic Title
**SQL Subqueries: Single-Row, Multi-Row, Inline Views, Correlated Subqueries, and EXISTS/NOT EXISTS**

---

## 2. Simple Definition
- **Subquery (Inner Query / Nested Query)**: A complete `SELECT` query nested inside another SQL statement (the Outer or Main query).
- **Single-Row Subquery**: Returns at most one single value (one column, one row). Used with scalar comparison operators (`=`, `>`, `<`, `>=`, `<=`, `<>`).
- **Multiple-Row Subquery**: Returns multiple rows (one column, many rows). Used with set comparison operators (`IN`, `NOT IN`, `ANY`, `ALL`).
- **Scalar Subquery**: A subquery that returns exactly one row and one column; can be used anywhere an expression is valid (such as within the `SELECT` list).
- **Inline View (Subquery in FROM)**: A subquery located in the `FROM` clause that functions as a temporary virtual table during query execution.
- **Correlated Subquery**: A subquery that references one or more columns from the outer query. It is evaluated repeatedly, once for every candidate row evaluated by the outer query.
- **`EXISTS` / `NOT EXISTS`**: Boolean operators that test for the existence of rows returned by a subquery, terminating evaluation the instant a matching row is found (short-circuit).

---

## 3. Why It Is Used
- **Dynamic Multi-Step Logic**: Often, the criteria needed to filter data are unknown until calculated (e.g., "Find all employees who make more than the average salary" requires calculating the average salary first).
- **Modular Data Pipelines**: Breaking complex calculations into readable stages using inline views in the `FROM` clause.
- **Fast Existence Checks**: `EXISTS` provides high-performance checks when verifying relationships without having to fetch or count millions of child rows.

---

## 4. Syntax and Operator Guide

### 1. Single-Row Subquery in WHERE
```sql
-- Employees earning more than the company average salary
SELECT employee_id, first_name, last_name, salary
FROM EMPLOYEES
WHERE salary > (SELECT AVG(salary) FROM EMPLOYEES);
```

### 2. Multi-Row Subquery with IN and NOT IN
```sql
-- Employees in departments located in 'Tech Hall 1' or 'Tech Hall 2'
SELECT employee_id, first_name, last_name, department_id
FROM EMPLOYEES
WHERE department_id IN (
    SELECT department_id 
    FROM DEPARTMENTS 
    WHERE location LIKE 'Tech Hall%'
);
```

### 3. ANY / ALL Operators
- `> ANY (...)`: Greater than the minimum value returned by the subquery.
- `> ALL (...)`: Greater than the maximum value returned by the subquery.
```sql
-- Employees who earn more than ANY employee in Department 30
SELECT employee_id, first_name, salary
FROM EMPLOYEES
WHERE salary > ANY (SELECT salary FROM EMPLOYEES WHERE department_id = 30);
```

### 4. Scalar Subquery in SELECT
```sql
-- Display each employee alongside the total department headcount
SELECT 
    e.first_name,
    e.department_id,
    (SELECT COUNT(*) FROM EMPLOYEES sub WHERE sub.department_id = e.department_id) AS dept_headcount
FROM EMPLOYEES e;
```

### 5. Inline View (Subquery in FROM)
```sql
-- Treat aggregate results as a derived table
SELECT dept_stats.department_id, dept_stats.avg_sal
FROM (
    SELECT department_id, ROUND(AVG(salary), 2) AS avg_sal
    FROM EMPLOYEES
    GROUP BY department_id
) dept_stats
WHERE dept_stats.avg_sal > 75000;
```

### 6. Correlated Subquery with EXISTS / NOT EXISTS
```sql
-- Find departments that have NO employees assigned
SELECT d.department_id, d.department_name
FROM DEPARTMENTS d
WHERE NOT EXISTS (
    SELECT 1 
    FROM EMPLOYEES e 
    WHERE e.department_id = d.department_id
);
```

---

## 5. Joins vs. Subqueries Comparison
| Feature | JOIN | Subquery |
| :--- | :--- | :--- |
| **Primary Use** | Combining columns from multiple tables into a single row | Filtering rows or computing dynamic lookup values |
| **Output Columns** | Can project columns from all joined tables | Outer query can only project columns from its own tables |
| **Performance** | Usually optimized into hash/merge joins by RDBMS | Independent subqueries run once; correlated run per row |
| **Readability** | Preferred for reporting across related tables | Preferred for multi-stage threshold calculations and `NOT EXISTS` |

---

## 6. Four Classic SQL Interview Queries Solved

### Query A: Finding the 2nd Highest Salary
```sql
-- Solution 1: Pure subquery (Standard across all SQL engines)
SELECT MAX(salary) AS second_highest_salary
FROM EMPLOYEES
WHERE salary < (SELECT MAX(salary) FROM EMPLOYEES);

-- Solution 2: Nth Highest Salary using Correlated Subquery (N = 2)
SELECT e1.salary AS second_highest_salary
FROM EMPLOYEES e1
WHERE 2 = (
    SELECT COUNT(DISTINCT e2.salary)
    FROM EMPLOYEES e2
    WHERE e2.salary >= e1.salary
);
```

### Query B: Employees Earning More than Their Department's Average Salary
```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM EMPLOYEES e
WHERE e.salary > (
    SELECT AVG(sub.salary)
    FROM EMPLOYEES sub
    WHERE sub.department_id = e.department_id
);
```

### Query C: Students Scoring Above Their Department's Average GPA
```sql
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.gpa,
    s.department_id
FROM STUDENTS s
WHERE s.gpa > (
    SELECT AVG(d_avg.gpa)
    FROM STUDENTS d_avg
    WHERE d_avg.department_id = s.department_id
);
```

### Query D: Finding Departments with No Students Enrolled
```sql
SELECT d.department_id, d.department_name
FROM DEPARTMENTS d
WHERE NOT EXISTS (
    SELECT 1 
    FROM STUDENTS s 
    WHERE s.department_id = d.department_id
);
```

---

## 7. Sample Input Tables: `EMPLOYEES`
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | SALARY | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | President & CEO | 125000 | 10 |
| 102 | Alice | Smith | Engineering Director | 95000 | 10 |
| 104 | Michael | Scott | Senior Software Engineer | 82000 | 10 |
| 105 | Elena | Rostova | Software Engineer | 65000 | 10 |
| 103 | David | Clark | IT Manager | 88000 | 20 |
| 106 | Priya | Patel | Database Administrator | 78000 | 20 |
| 107 | James | Wilson | Systems Analyst | 60000 | 20 |
| 108 | Sarah | Connor | Mechanical Dept Lead | 91000 | 30 |
| 109 | Carlos | Mendoza | Mechanical Engineer | 71000 | 30 |
| 110 | Jessica | Taylor | Junior CAD Designer | 48000 | 30 |
| 111 | Arthur | Dent | Principal Scientist | 110000 | 60 |

---

## 8. Expected Outputs

### Output for Query A (2nd Highest Salary)
The highest salary is 125,000 (Robert King). The highest salary strictly less than 125,000 is 110,000 (Arthur Dent).

| SECOND_HIGHEST_SALARY |
| :--- |
| 110000 |

### Output for Query B (Above Department Average)
- Dept 10 Avg: (125k + 95k + 82k + 65k) / 4 = 91,750. Earning > 91,750: Robert (125k), Alice (95k).
- Dept 20 Avg: (88k + 78k + 60k) / 3 = 75,333. Earning > 75,333: David (88k), Priya (78k).
- Dept 30 Avg: (91k + 71k + 48k) / 3 = 70,000. Earning > 70,000: Sarah (91k), Carlos (71k).
- Dept 60 Avg: 110,000. Earning > 110,000: None.

| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | SALARY | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | 125000 | 10 |
| 102 | Alice | Smith | 95000 | 10 |
| 103 | David | Clark | 88000 | 20 |
| 106 | Priya | Patel | 78000 | 20 |
| 108 | Sarah | Connor | 91000 | 30 |
| 109 | Carlos | Mendoza | 71000 | 30 |

---

## 9. Step-by-Step Explanation of How Correlated Execution Works
1. Outer query reads the first candidate row: Employee 101 (`Robert King`, Dept 10, Salary 125,000).
2. The inner subquery executes with `s.department_id = 10`, calculating the average salary for Dept 10 (91,750).
3. The outer query checks: `125,000 > 91,750`? True. Row 101 is kept.
4. Next candidate row: Employee 105 (`Elena Rostova`, Dept 10, Salary 65,000).
5. Subquery calculates Dept 10 average (91,750).
6. Check: `65,000 > 91,750`? False. Row 105 is discarded.
7. This process repeats for every row in the outer table.

---

## 10. Common Mistakes
1. **The `ORA-01427: single-row subquery returns more than one row` Error**: Using a single-row operator like `=` or `>` with a subquery that produces multiple rows. (e.g., `WHERE salary > (SELECT salary FROM EMPLOYEES)`). Fix by using `AVG(salary)` or changing `=` to `IN`.
2. **The `NOT IN` with NULL Pitfall**: If the subquery in `WHERE x NOT IN (SELECT col FROM ...)` returns even a single `NULL`, the entire condition evaluates to `UNKNOWN` and returns zero rows!
   - *Fix*: Always add `WHERE col IS NOT NULL` inside the subquery, or use `NOT EXISTS`.
3. **Placing Multiple Columns in a WHERE Subquery**: Writing `WHERE dept_id = (SELECT dept_id, name FROM DEPARTMENTS)`. A single-row subquery in a comparison must return exactly one column.
4. **Selecting Columns from the Subquery in the Outer Query**: If Table B is only inside a subquery in `WHERE`, you cannot write `SELECT B.col` in the outer query's `SELECT` list. You must use a `JOIN` if you need columns from both tables.

---

## 11. Interview Questions
1. **What is a correlated subquery, and why can it be slow?**
   - *Answer*: A correlated subquery references a column from the outer query. It executes repeatedly for every candidate row processed by the outer query ($O(N \times M)$), whereas an uncorrelated subquery executes only once before the outer query runs.
2. **What is the difference between `IN` and `EXISTS`?**
   - *Answer*: `IN` evaluates the inner query completely, builds a list of matching values, and checks membership. `EXISTS` tests for boolean existence row by row and short-circuits (stops scanning) the moment a match is found. `EXISTS` is safer with `NULL` values.
3. **Why does `NOT IN` fail when the subquery returns a NULL value?**
   - *Answer*: Because `x NOT IN (10, NULL)` translates to `x != 10 AND x != NULL`. Since `x != NULL` evaluates to `UNKNOWN`, the whole expression evaluates to `UNKNOWN`, resulting in zero rows being selected.
4. **How do you find the Nth highest salary in SQL?**
   - *Answer*: Using a correlated subquery: `SELECT salary FROM EMPLOYEES e1 WHERE N = (SELECT COUNT(DISTINCT e2.salary) FROM EMPLOYEES e2 WHERE e2.salary >= e1.salary);` or using subqueries with `DENSE_RANK()`.

---

## 12. Short Summary
- Subqueries allow multi-step problem solving inside SQL queries.
- Single-row subqueries use scalar operators (`=`, `>`), multi-row subqueries use set operators (`IN`, `ANY`, `ALL`).
- Correlated subqueries reference the outer query and run once per candidate row.
- `EXISTS` and `NOT EXISTS` provide safe, high-performance existence tests and handle `NULL`s gracefully.
