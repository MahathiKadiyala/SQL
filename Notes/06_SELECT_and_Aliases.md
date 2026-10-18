# Chapter 6: SELECT, Aliases, and Expressions

## 1. Topic Title
**Querying Data: Column Projection, Aliases, Arithmetic Expressions, Concatenation, and DISTINCT**

---

## 2. Simple Definition
- **`SELECT`**: The primary SQL statement used to retrieve records from one or more database tables.
- **Column Projection**: Choosing specific columns to return rather than retrieving the entire table.
- **Column Alias**: A temporary name given to a column or calculated expression in the query output.
- **Table Alias**: A temporary shorthand abbreviation given to a table name to make queries cleaner and shorter.
- **Arithmetic Expression**: Calculating new values on the fly using mathematical operators (`+`, `-`, `*`, `/`).
- **Concatenation (`||`)**: Combining two or more text strings or column values into a single text output.
- **`DISTINCT`**: Eliminates duplicate rows from the final result set.

---

## 3. Why It Is Used
- **Network & Memory Efficiency**: Requesting only the columns needed (`SELECT first_name, email`) avoids transferring gigabytes of unneeded data across the network compared to `SELECT *`.
- **Business Reporting**: Generating readable reports (e.g., displaying `first_name || ' ' || last_name AS "Full Name"` or `salary * 12 AS "Annual Salary"`).
- **Unique Value Discovery**: Using `SELECT DISTINCT department_id FROM STUDENTS;` quickly lists all departments that have registered students without repeats.

---

## 4. Syntax
```sql
-- 1. Selecting all columns
SELECT * FROM EMPLOYEES;

-- 2. Selecting specific columns with Aliases
SELECT 
    employee_id AS emp_id,
    first_name AS "First Name",    -- Double quotes preserve spaces and casing
    salary AS monthly_salary
FROM EMPLOYEES;

-- 3. Arithmetic Expressions and String Concatenation
SELECT 
    first_name || ' ' || last_name AS full_name,
    salary,
    salary * 12 AS annual_salary,
    (salary * 12) + 5000 AS projected_total_pay
FROM EMPLOYEES;

-- 4. Eliminating Duplicates with DISTINCT
SELECT DISTINCT department_id FROM EMPLOYEES;
SELECT DISTINCT department_id, job_title FROM EMPLOYEES;

-- 5. Dealing with NULL in calculations using NVL
SELECT 
    first_name,
    salary,
    commission_pct,
    salary + (salary * NVL(commission_pct, 0)) AS total_compensation
FROM EMPLOYEES;
```

---

## 5. Explanation of the Syntax
1. **Double Quotes vs. Single Quotes**:
   - **Single quotes `'...'`** are for string/date literals (e.g., `'Engineering'`, `'2023-01-01'`).
   - **Double quotes `"..."`** are exclusively for column or table identifiers when you need spaces, special characters, or case preservation (e.g., `AS "Annual Income ($)"`).
2. **NULL in Arithmetic**:
   - In SQL, `NULL` represents an unknown or missing value.
   - Any arithmetic operation involving `NULL` yields `NULL`! (e.g., `5000 + NULL = NULL`).
   - Use functions like `NVL(commission_pct, 0)` to substitute a default value before doing math.
3. **`DISTINCT` Scope**:
   - `DISTINCT` applies to **all columns listed in the `SELECT` clause**, not just the first one. `SELECT DISTINCT col1, col2` returns unique *combinations* of `col1` and `col2`.

---

## 6. Example Query
Calculate the annual compensation package for employees, formatting their full name and job title with clear aliases:

```sql
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    job_title,
    salary AS monthly_base,
    salary * 12 AS annual_base,
    salary * NVL(commission_pct, 0) AS monthly_commission,
    (salary * 12) + (salary * NVL(commission_pct, 0) * 12) AS estimated_annual_gross
FROM EMPLOYEES
WHERE department_id = 10;
```

---

## 7. Sample Input Table: `EMPLOYEES` (Dept 10)
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | SALARY | COMMISSION_PCT | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | President & CEO | 125000.00 | *null* | 10 |
| 102 | Alice | Smith | Engineering Director | 95000.00 | 0.15 | 10 |
| 104 | Michael | Scott | Senior Software Engineer | 82000.00 | *null* | 10 |
| 105 | Elena | Rostova | Software Engineer | 65000.00 | *null* | 10 |

---

## 8. Expected Output
| EMPLOYEE_ID | FULL_NAME | JOB_TITLE | MONTHLY_BASE | ANNUAL_BASE | MONTHLY_COMMISSION | ESTIMATED_ANNUAL_GROSS |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert King | President & CEO | 125000 | 1500000 | 0 | 1500000 |
| 102 | Alice Smith | Engineering Director | 95000 | 1140000 | 14250 | 1311000 |
| 104 | Michael Scott | Senior Software Engineer | 82000 | 984000 | 0 | 984000 |
| 105 | Elena Rostova | Software Engineer | 65000 | 780000 | 0 | 780000 |

---

## 9. Step-by-Step Explanation of How the Query Works
1. **`FROM EMPLOYEES`**: Loads the employee records into memory.
2. **`WHERE department_id = 10`**: Restricts the dataset to the 4 employees in Department 10.
3. **`NVL(commission_pct, 0)`**: For Robert King, `commission_pct` is `NULL`. `NVL` replaces it with `0`. For Alice Smith, it stays `0.15`.
4. **Arithmetic & Concatenation**:
   - `first_name || ' ' || last_name` binds the strings into `'Robert King'`.
   - `salary * 12` computes the annual base.
   - For Alice: `95,000 * 0.15 = 14,250` monthly commission, and `1,140,000 + (14,250 * 12) = 1,311,000` gross.
5. **Aliases**: Renames calculated headers into clean business titles for presentation.

---

## 10. Common Mistakes
1. **Using Double Quotes for String Literals**: Writing `WHERE job_title = "IT Manager"`. In SQL, string values must always use single quotes `'IT Manager'`. Double quotes are reserved for column/table identifiers.
2. **Relying on `SELECT *` in Production Code**: If someone adds a 100MB blob column to the table later, all application queries using `SELECT *` will suffer massive performance degradation.
3. **Forgetting NULL Propagation in Math**: Calculating `salary + commission_pct` without `NVL`. If `commission_pct` is NULL, the total turns into NULL!
4. **Writing DISTINCT inside parentheses like a function**: `SELECT DISTINCT(department_id, job_title)` is invalid. `DISTINCT` is a keyword that modifies the entire select projection, not a function.

---

## 11. Interview Questions
1. **What is the difference between single quotes and double quotes in SQL?**
   - *Answer*: Single quotes enclose string literals and date constants (`'John'`). Double quotes enclose column or table identifiers to preserve case sensitivity or embed special characters/spaces (`"First Name"`).
2. **What does `SELECT DISTINCT a, b FROM table;` do?**
   - *Answer*: It returns unique pairs of `(a, b)`. A row is kept as long as the combination of `a` and `b` is distinct across all rows.
3. **What is the result of `100 + NULL` in SQL?**
   - *Answer*: `NULL`. Any standard arithmetic operation performed with a `NULL` operand evaluates to `NULL`.
4. **How do you concatenate strings in Oracle SQL?**
   - *Answer*: Using the pipe concatenation operator `||` (e.g., `first_name || ' ' || last_name`) or the `CONCAT()` function.

---

## 12. Short Summary
- `SELECT` projects columns and calculates dynamic expressions.
- Aliases (`AS name`) provide clean headers for calculated fields.
- Math involving `NULL` produces `NULL`; use `NVL()` to provide fallbacks.
- Use `||` for string concatenation and `DISTINCT` to eliminate duplicate output rows.
