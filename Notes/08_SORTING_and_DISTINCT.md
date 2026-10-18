# Chapter 8: Sorting with ORDER BY and DISTINCT

## 1. Topic Title
**Result Set Ordering (ORDER BY), Directional Sorting, Multi-Column Tie-Breaking, NULL Sorting Behavior, and DISTINCT**

---

## 2. Simple Definition
- **`ORDER BY`**: The clause used to sort rows returned by a `SELECT` query in ascending or descending sequence.
- **`ASC` (Ascending)**: The default sorting direction (smallest to largest: numbers 0–9, strings A–Z, dates oldest to newest).
- **`DESC` (Descending)**: Reverses the sequence (largest to smallest: numbers 9–0, strings Z–A, dates newest to oldest).
- **Multi-Column Sorting**: Primary sort on column 1; ties are resolved using column 2, then column 3, etc.
- **`NULLS FIRST` / `NULLS LAST`**: Explicit clauses controlling where `NULL` values appear in the sorted sequence.
- **`DISTINCT`**: Suppresses duplicate rows from the final result set.

---

## 3. Why It Is Used
- **Human Readability**: Relational databases store rows as an unordered mathematical set. Without `ORDER BY`, the return order is non-deterministic (random).
- **Top/Bottom Analysis**: Finding the top 5 highest earners, earliest hired employees, or lowest scoring students.
- **Tie-Breaking**: When multiple employees share the same department or title, secondary sorting provides predictable, orderly presentations.

---

## 4. Syntax
```sql
-- 1. Basic Ascending (default) and Descending sort
SELECT employee_id, first_name, salary
FROM EMPLOYEES
ORDER BY salary DESC;

-- 2. Multi-column sorting
SELECT department_id, job_title, salary, last_name
FROM EMPLOYEES
ORDER BY department_id ASC, salary DESC;

-- 3. Sorting by column alias or expression
SELECT first_name, salary, salary * 12 AS annual_salary
FROM EMPLOYEES
ORDER BY annual_salary DESC;

-- 4. Controlling NULL placement in Oracle
SELECT employee_id, first_name, commission_pct
FROM EMPLOYEES
ORDER BY commission_pct DESC NULLS LAST;

-- 5. Using DISTINCT with ORDER BY
SELECT DISTINCT department_id
FROM EMPLOYEES
ORDER BY department_id ASC;
```

---

## 5. Explanation of the Syntax
1. **Logical Execution Order**:
   - `FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> DISTINCT -> ORDER BY`
   - Because `ORDER BY` executes **after** `SELECT`, you can safely use column aliases in the `ORDER BY` clause!
2. **Oracle's Default NULL Handling**:
   - In Oracle SQL, `NULL` values are treated as the **highest possible value**.
   - Therefore, in ascending order (`ASC`), `NULL` values appear at the **end** by default (`NULLS LAST`).
   - In descending order (`DESC`), `NULL` values appear at the **beginning** by default (`NULLS FIRST`).
   - You can override this default behavior explicitly using `ORDER BY column DESC NULLS LAST`.
3. **Sorting by Column Position Numbers**:
   - `ORDER BY 1, 2` sorts by the 1st and 2nd columns in your `SELECT` list.
   - *Best Practice*: Avoid positional sorting in production SQL, as modifying the column order in `SELECT` unintentionally breaks your sort logic.

---

## 6. Example Query
Display all employees sorted primarily by department in ascending order, and secondarily by salary in descending order, placing any employees with NULL departments at the bottom:

```sql
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    department_id,
    job_title,
    salary
FROM EMPLOYEES
ORDER BY department_id ASC NULLS LAST, salary DESC;
```

---

## 7. Sample Input Table: `EMPLOYEES`
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | DEPARTMENT_ID | JOB_TITLE | SALARY |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | 10 | President & CEO | 125000 |
| 102 | Alice | Smith | 10 | Engineering Director | 95000 |
| 104 | Michael | Scott | 10 | Senior Software Engineer | 82000 |
| 105 | Elena | Rostova | 10 | Software Engineer | 65000 |
| 103 | David | Clark | 20 | IT Manager | 88000 |
| 106 | Priya | Patel | 20 | Database Administrator | 78000 |
| 107 | James | Wilson | 20 | Systems Analyst | 60000 |
| 112 | Bruce | Wayne | *null* | External Strategy Advisor | 85000 |

---

## 8. Expected Output
| EMPLOYEE_ID | FULL_NAME | DEPARTMENT_ID | JOB_TITLE | SALARY |
| :--- | :--- | :--- | :--- | :--- |
| 101 | Robert King | 10 | President & CEO | 125000 |
| 102 | Alice Smith | 10 | Engineering Director | 95000 |
| 104 | Michael Scott | 10 | Senior Software Engineer | 82000 |
| 105 | Elena Rostova | 10 | Software Engineer | 65000 |
| 103 | David Clark | 20 | IT Manager | 88000 |
| 106 | Priya Patel | 20 | Database Administrator | 78000 |
| 107 | James Wilson | 20 | Systems Analyst | 60000 |
| 112 | Bruce Wayne | *null* | External Strategy Advisor | 85000 |

---

## 9. Step-by-Step Explanation of How the Query Works
1. **Primary Sort (`department_id ASC`)**: Groups all rows for Department 10 first, followed by Department 20.
2. **Tie-Break Sort (`salary DESC`)**: Within Department 10, Robert (125k) is first, followed by Alice (95k), Michael (82k), and Elena (65k). Within Department 20, David (88k) comes before Priya (78k) and James (60k).
3. **`NULLS LAST`**: Employee 112 (Bruce Wayne) has `department_id = NULL`. Instead of showing at an arbitrary place, he is placed at the end of the entire list.

---

## 10. Common Mistakes
1. **Assuming Tables Have an Inherent Order**: Expecting rows to always return in the order they were inserted. Relational tables are unordered sets; without `ORDER BY`, order is never guaranteed.
2. **Surprise NULLs at the Top of DESC Queries**: Forgetting that in Oracle, `ORDER BY salary DESC` puts `NULL` salaries at the very top by default! Use `NULLS LAST` to push missing values to the bottom.
3. **Using DISTINCT with ORDER BY on an unselected column**: Writing `SELECT DISTINCT department_id FROM EMPLOYEES ORDER BY salary;` will fail with `ORA-01791: not a SELECTed expression`. When `DISTINCT` is used, you can only order by columns present in the `SELECT` list.
4. **Incorrect Multiple DESC syntax**: Writing `ORDER BY dept_id, salary DESC` only applies descending order to `salary`. If you want both descending, you must write `ORDER BY dept_id DESC, salary DESC`.

---

## 11. Interview Questions
1. **In Oracle, where do NULL values appear by default in an `ORDER BY col DESC` query?**
   - *Answer*: At the very top (`NULLS FIRST`), because Oracle treats `NULL` as greater than any known value.
2. **Can you sort by a column alias in SQL? Why or why not?**
   - *Answer*: Yes. In the SQL logical processing pipeline, `ORDER BY` is executed after the `SELECT` clause, so column aliases defined in `SELECT` are available for sorting.
3. **Why does `SELECT DISTINCT a FROM table ORDER BY b;` fail in SQL?**
   - *Answer*: Because `DISTINCT` collapses multiple rows with the same `a` into a single row. If those collapsed rows had different values for `b`, the database cannot determine which `b` value to sort by.
4. **What is the difference between `ORDER BY 1` and `ORDER BY col_name`?**
   - *Answer*: `ORDER BY 1` sorts by the first column in the `SELECT` projection. While valid, sorting by column name is strongly preferred for clarity and robustness.

---

## 12. Short Summary
- `ORDER BY` provides deterministic sorting for query results using `ASC` (default) or `DESC`.
- Tie-breaking is achieved by providing comma-separated secondary and tertiary sort keys.
- Oracle considers `NULL` to be the highest value; use `NULLS FIRST` or `NULLS LAST` to control placement.
- `ORDER BY` runs after `SELECT`, allowing the use of column aliases.
