# Chapter 11: SQL JOINS

## 1. Topic Title
**Relational Table Joins: INNER, LEFT, RIGHT, FULL OUTER, CROSS, and SELF Joins**

---

## 2. Simple Definition
- **JOIN**: A SQL operation used to combine rows from two or more tables based on a related column between them (usually a Primary Key – Foreign Key relationship).
- **INNER JOIN**: Returns only the rows where there is a matching value in **both** tables.
- **LEFT (OUTER) JOIN**: Returns all rows from the left table, and matching rows from the right table. Non-matching right table columns return `NULL`.
- **RIGHT (OUTER) JOIN**: Returns all rows from the right table, and matching rows from the left table. Non-matching left table columns return `NULL`.
- **FULL (OUTER) JOIN**: Returns all rows when there is a match in either left or right table. Unmatched columns on either side return `NULL`.
- **CROSS JOIN**: Produces the Cartesian product of both tables (every row in Table A combined with every row in Table B).
- **SELF JOIN**: A regular join in which a table is joined with itself (requires two distinct table aliases).

---

## 3. Why It Is Used
- **Normalized Data Architecture**: Relational databases avoid data duplication by splitting information across multiple specialized tables (e.g., `EMPLOYEES`, `DEPARTMENTS`, `SALARIES`).
- **Unified Reporting**: Joins reconstruct those separate entities on demand into a single cohesive report without physically duplicating stored data.
- **Hierarchical Queries**: A self-join allows an organization table to express supervisor-subordinate relationships within a single employee roster.

---

## 4. Visual Diagrams of Join Types
```text
Table A (Left)               Table B (Right)
┌───────┬───────┐            ┌───────┬───────┐
│ ID    │ Name  │            │ Dept  │ DName │
└───────┴───────┘            └───────┴───────┘

1. INNER JOIN (Intersection only):
       [ Table A  ( MATCH )  Table B ]
       Rows that satisfy the ON condition in BOTH tables.

2. LEFT OUTER JOIN (All Left + Matching Right):
       [  TABLE A  ===> ( MATCH )  Table B ]
       Non-matches from Table B filled with NULLs.

3. RIGHT OUTER JOIN (Matching Left + All Right):
       [ Table A ( MATCH ) <===  TABLE B  ]
       Non-matches from Table A filled with NULLs.

4. FULL OUTER JOIN (Union of All Rows from Both):
       [  TABLE A  <===( MATCH )===>  TABLE B  ]
       Preserves all rows from both tables, filling NULLs where unmatched.

5. CROSS JOIN (Cartesian Product):
       Table A (N rows) × Table B (M rows) = N × M Total Rows.
```

---

## 5. Syntax Guide for Every Join Type

### 1. INNER JOIN
```sql
SELECT e.employee_id, e.first_name, d.department_name
FROM EMPLOYEES e
INNER JOIN DEPARTMENTS d ON e.department_id = d.department_id;
```

### 2. LEFT OUTER JOIN
```sql
-- Returns ALL students, even if they have no department assigned (like Maya Lin)
SELECT s.student_id, s.first_name, s.department_id, d.department_name
FROM STUDENTS s
LEFT OUTER JOIN DEPARTMENTS d ON s.department_id = d.department_id;
```

### 3. RIGHT OUTER JOIN
```sql
-- Returns ALL departments, even if no students are enrolled in them (like Dept 50 HR)
SELECT s.student_id, s.first_name, d.department_id, d.department_name
FROM STUDENTS s
RIGHT OUTER JOIN DEPARTMENTS d ON s.department_id = d.department_id;
```

### 4. FULL OUTER JOIN
```sql
-- Returns all students AND all departments, pairing matches and padding NULLs
SELECT s.first_name, s.department_id, d.department_id, d.department_name
FROM STUDENTS s
FULL OUTER JOIN DEPARTMENTS d ON s.department_id = d.department_id;
```

### 5. CROSS JOIN (Cartesian Product)
```sql
SELECT d.department_name, c.course_code
FROM DEPARTMENTS d
CROSS JOIN COURSES c;
```

### 6. SELF JOIN (Employee to Manager)
```sql
SELECT 
    emp.employee_id,
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.job_title,
    mgr.first_name || ' ' || mgr.last_name AS manager_name
FROM EMPLOYEES emp
LEFT JOIN EMPLOYEES mgr ON emp.manager_id = mgr.employee_id;
```

### 7. Multi-Table Join (Joining 3 or More Tables)
```sql
-- Join Students -> Student_Courses -> Courses -> Departments
SELECT 
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_code,
    c.course_name,
    sc.semester,
    sc.grade,
    d.department_name
FROM STUDENTS s
JOIN STUDENT_COURSES sc ON s.student_id = sc.student_id
JOIN COURSES c          ON sc.course_id = c.course_id
LEFT JOIN DEPARTMENTS d ON c.department_id = d.department_id;
```

---

## 6. Comprehensive Example Query: Join Comparison
Let's run a query that demonstrates how `LEFT JOIN` preserves employees who have no department, and how `SALARIES` can be joined simultaneously:

```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    NVL(d.department_name, 'No Dept Assigned') AS department,
    s.base_salary,
    s.bonus,
    (s.base_salary + NVL(s.bonus, 0) - NVL(s.deductions, 0)) AS net_compensation
FROM EMPLOYEES e
LEFT JOIN DEPARTMENTS d ON e.department_id = d.department_id
JOIN SALARIES s         ON e.employee_id = s.employee_id
WHERE e.employee_id IN (101, 102, 103, 112);
```

---

## 7. Sample Input Tables
### `EMPLOYEES` (Selected)
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | President & CEO | 10 |
| 102 | Alice | Smith | Engineering Director | 10 |
| 103 | David | Clark | IT Manager | 20 |
| 112 | Bruce | Wayne | External Strategy Advisor | *null* |

### `DEPARTMENTS`
| DEPARTMENT_ID | DEPARTMENT_NAME | LOCATION |
| :--- | :--- | :--- |
| 10 | Computer Science | Tech Hall 1 |
| 20 | Information Technology | Tech Hall 2 |
| 50 | Human Resources | Admin Building |

### `SALARIES` (Selected)
| SALARY_ID | EMPLOYEE_ID | BASE_SALARY | BONUS | DEDUCTIONS |
| :--- | :--- | :--- | :--- | :--- |
| 501 | 101 | 125000 | 15000 | 3500 |
| 502 | 102 | 95000 | 10000 | 2800 |
| 503 | 103 | 88000 | 8000 | 2400 |

*(Note: Employee 112 does not exist in SALARIES yet; hence inner join to SALARIES would exclude him unless LEFT JOIN is used. If we want Bruce Wayne included, both joins should be LEFT JOIN).*

Let's use pure `LEFT JOIN` for both to inspect the complete outer join behavior:
```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    NVL(d.department_name, 'Unassigned') AS department,
    NVL(s.base_salary, 0) AS base_salary,
    NVL(s.bonus, 0) AS bonus
FROM EMPLOYEES e
LEFT JOIN DEPARTMENTS d ON e.department_id = d.department_id
LEFT JOIN SALARIES s    ON e.employee_id = s.employee_id
WHERE e.employee_id IN (101, 102, 103, 112);
```

---

## 8. Expected Output
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | DEPARTMENT | BASE_SALARY | BONUS |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | President & CEO | Computer Science | 125000 | 15000 |
| 102 | Alice | Smith | Engineering Director | Computer Science | 95000 | 10000 |
| 103 | David | Clark | IT Manager | Information Technology | 88000 | 8000 |
| 112 | Bruce | Wayne | External Strategy Advisor | Unassigned | 0 | 0 |

---

## 9. Step-by-Step Explanation of How Joins Work
1. **Left Driving Table**: The query starts with `EMPLOYEES` as the base table.
2. **First Left Join (`DEPARTMENTS`)**:
   - For employees 101 and 102, `department_id = 10` finds `'Computer Science'`.
   - For employee 103, `department_id = 20` finds `'Information Technology'`.
   - For employee 112, `department_id` is `NULL`. In an `INNER JOIN`, Bruce Wayne would be discarded. Because this is a `LEFT JOIN`, his row is retained and department columns are populated with `NULL`.
3. **Second Left Join (`SALARIES`)**:
   - Matches employee IDs against `SALARIES`. Employees 101, 102, and 103 find matching salary records. Bruce Wayne (112) has no salary record; his salary values are supplied as `NULL` and replaced by `0` via `NVL()`.
4. **Filtering & Output**: `WHERE` restricts to the chosen 4 IDs and outputs the four rows cleanly.

---

## 10. Common Mistakes
1. **Accidental Cartesian Explosion (Missing `ON` clause)**: Forgetting the `ON` condition or writing `FROM EMPLOYEES, DEPARTMENTS` without a WHERE clause combines every employee with every department (12 x 6 = 72 rows).
2. **Ambiguous Column Name (`ORA-00918`)**: Writing `SELECT department_id FROM EMPLOYEES e JOIN DEPARTMENTS d ON e.department_id = d.department_id;` without prefixing the table alias (`e.` or `d.`).
3. **Breaking a LEFT JOIN with a WHERE Filter**: Writing `FROM EMPLOYEES e LEFT JOIN DEPARTMENTS d ON e.dept_id = d.dept_id WHERE d.location = 'Tech Hall 1'`. This inadvertently converts the `LEFT JOIN` into an `INNER JOIN` because unmatched rows have `d.location = NULL`, which gets eliminated by the `WHERE` clause! Place the condition inside the `ON` clause instead.
4. **Duplicate Rows from 1:N Joins**: Joining an employee to a table with multiple matching rows (like `SALARIES` history) duplicates employee records in the output. Use grouping or distinct where appropriate.

---

## 11. Interview Questions
1. **What is the difference between `INNER JOIN` and `LEFT JOIN`?**
   - *Answer*: `INNER JOIN` returns only rows that have matching keys in both tables. `LEFT JOIN` returns all records from the left table, bringing in matched data from the right table, and filling right-table columns with `NULL` when no match exists.
2. **What is a SELF JOIN, and what is a classic real-world use case?**
   - *Answer*: A self join joins a table to itself using two distinct aliases. A classic use case is resolving an employee-manager hierarchy where both employees and their managers are stored in the same `EMPLOYEES` table.
3. **What is a Cartesian product (CROSS JOIN)?**
   - *Answer*: A query where every row of the first table is paired with every row of the second table. If Table A has 10 rows and Table B has 20 rows, the cross join yields 200 rows.
4. **How does Oracle traditional join syntax differ from ANSI SQL standard join syntax?**
   - *Answer*: ANSI SQL uses explicit keywords (`INNER JOIN ... ON ...`, `LEFT JOIN ... ON ...`). Traditional Oracle syntax used comma-separated tables in `FROM` and placed join conditions in `WHERE`, using `(+)` on the optional side for outer joins (e.g., `WHERE e.dept_id = d.dept_id(+)`). Modern SQL standards universally recommend ANSI join syntax.

---

## 12. Short Summary
- Joins connect relational tables based on matching foreign key conditions.
- `INNER` returns matches only; `LEFT`, `RIGHT`, and `FULL` outer joins retain unmatched rows by padding with `NULL`s.
- `SELF JOIN` resolves hierarchies within a single table.
- Always use table aliases and explicit `ON` conditions to avoid ambiguity and accidental Cartesian products.
