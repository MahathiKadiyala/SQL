# Chapter 9: SQL Functions (Single-Row, Conversion, Aggregate, and CASE)

## 1. Topic Title
**Built-In SQL Functions: String, Numeric, Date, NULL Handling, Type Conversion, Aggregation, and Conditional CASE Expressions**

---

## 2. Simple Definition
- **Function**: A pre-built subprogram that accepts input parameters, performs calculations or transformations, and returns a result.
- **Single-Row (Scalar) Functions**: Operate on individual rows and return exactly one result for every row queried (e.g., `UPPER()`, `ROUND()`, `SYSDATE`).
- **Aggregate (Multi-Row / Group) Functions**: Operate on a collection (set) of rows and summarize them into a single scalar value (e.g., `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`).
- **CASE Expression**: A conditional expression that provides `if-then-else` branching logic directly inside SQL statements.

---

## 3. Why It Is Used
- **Data Cleansing**: Normalizing casing (`UPPER`), stripping stray whitespace (`TRIM`), and replacing bad characters (`REPLACE`).
- **Financial & Numeric Precision**: Rounding currencies to 2 decimal places (`ROUND`), calculating modulo/remainders (`MOD`).
- **Date Math & Aging**: Calculating employee tenure, loan durations, and payment due dates (`MONTHS_BETWEEN`, `ADD_MONTHS`).
- **Data Type Safety**: Converting string dates to true database dates (`TO_DATE`) and formatting numbers into formatted currency text (`TO_CHAR`).
- **Executive Summaries**: Aggregating millions of transactions into departmental totals and averages.

---

## 4. Comprehensive Syntax Guide

### A. String Functions
```sql
SELECT 
    UPPER('hello')              AS u_case,      -- 'HELLO'
    LOWER('WORLD')              AS l_case,      -- 'world'
    INITCAP('john doe')         AS cap_case,    -- 'John Doe'
    LENGTH('Database')          AS str_len,     -- 8
    SUBSTR('OracleSQL', 1, 6)   AS sub_str,     -- 'Oracle' (1-indexed!)
    INSTR('Tech Hall 1', 'Hall') AS find_pos,   -- 6 (position of substring)
    TRIM('  leading/trailing  ') AS trimmed,    -- 'leading/trailing'
    REPLACE('CS-101', '-', '_') AS replaced,   -- 'CS_101'
    CONCAT('Oracle', ' Database') AS joined     -- 'Oracle Database'
FROM DUAL;
```

### B. Numeric Functions
```sql
SELECT 
    ROUND(45.786, 2)  AS r2,    -- 45.79
    ROUND(45.786, 0)  AS r0,    -- 46
    TRUNC(45.786, 2)  AS t2,    -- 45.78 (chops off without rounding)
    MOD(10, 3)        AS rem,   -- 1 (remainder)
    ABS(-150.50)      AS pos,   -- 150.50
    CEIL(12.1)        AS c_val, -- 13 (next highest integer)
    FLOOR(12.9)       AS f_val  -- 12 (previous lowest integer)
FROM DUAL;
```

### C. Date Functions
```sql
SELECT 
    SYSDATE                                       AS curr_server_date,
    CURRENT_DATE                                  AS curr_session_date,
    ADD_MONTHS(SYSDATE, 3)                        AS three_months_later,
    MONTHS_BETWEEN(SYSDATE, TO_DATE('2024-01-01', 'YYYY-MM-DD')) AS m_diff,
    LAST_DAY(SYSDATE)                             AS month_end_date,
    NEXT_DAY(SYSDATE, 'FRIDAY')                   AS upcoming_friday
FROM DUAL;
```

### D. NULL Handling Functions
```sql
-- 1. NVL(expr1, replace_with_if_null)
SELECT NVL(commission_pct, 0) FROM EMPLOYEES;

-- 2. NVL2(expr1, value_if_not_null, value_if_null)
SELECT NVL2(commission_pct, 'Commissioned', 'Salaried Only') FROM EMPLOYEES;

-- 3. COALESCE(expr1, expr2, ... exprN) - returns first non-null argument
SELECT COALESCE(phone_number, email, 'No Contact Found') FROM EMPLOYEES;

-- 4. NULLIF(expr1, expr2) - returns NULL if expr1 == expr2, else expr1
SELECT NULLIF(salary, 60000) FROM EMPLOYEES;
```

### E. Conversion Functions
```sql
-- 1. Number / Date to String Formatting: TO_CHAR
SELECT TO_CHAR(salary, '$999,999.00') AS formatted_salary,
       TO_CHAR(hire_date, 'FMDD Month, YYYY') AS readable_hire_date
FROM EMPLOYEES;

-- 2. String to Date: TO_DATE
SELECT TO_DATE('2023-11-20 18:30:00', 'YYYY-MM-DD HH24:MI:SS') FROM DUAL;

-- 3. String to Number: TO_NUMBER
SELECT TO_NUMBER('$45,000.50', '$999,999.00') FROM DUAL;
```

### F. Aggregate Functions
```sql
SELECT 
    COUNT(*)               AS total_rows,
    COUNT(commission_pct)  AS non_null_commissions,
    SUM(salary)            AS total_payroll,
    AVG(salary)            AS avg_salary,
    MIN(salary)            AS lowest_salary,
    MAX(salary)            AS highest_salary
FROM EMPLOYEES;
```

### G. Conditional CASE Expressions
```sql
-- Searched CASE
SELECT 
    first_name,
    salary,
    CASE 
        WHEN salary >= 100000 THEN 'Executive Tier'
        WHEN salary >= 75000  THEN 'Senior Tier'
        WHEN salary >= 50000  THEN 'Mid Tier'
        ELSE 'Junior Tier'
    END AS compensation_tier
FROM EMPLOYEES;
```

---

## 5. Single-Row vs. Aggregate Functions Comparison
| Feature | Single-Row Functions (`UPPER`, `ROUND`) | Aggregate Functions (`COUNT`, `AVG`, `SUM`) |
| :--- | :--- | :--- |
| **Input** | One row at a time | A set / group of rows |
| **Output** | One result per input row | One summarized result per group/table |
| **Placement** | `SELECT`, `WHERE`, `ORDER BY`, `HAVING` | `SELECT`, `HAVING`, `ORDER BY` (Never in `WHERE`!) |
| **NULL Handling** | Evaluates on the input parameter | Automatically ignores `NULL`s (except `COUNT(*)`) |

---

## 6. Comprehensive Example Query
Generate a detailed compensation report formatting names, dates, calculating tenure in years, rounding averages, and evaluating bonus tiers:

```sql
SELECT 
    employee_id,
    INITCAP(first_name) || ' ' || UPPER(last_name) AS employee_name,
    TO_CHAR(hire_date, 'YYYY-MM-DD') AS hire_date,
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date) / 12, 1) AS tenure_years,
    TO_CHAR(salary, '$999,999.00') AS monthly_salary,
    NVL2(commission_pct, TO_CHAR(commission_pct * 100) || '%', 'None') AS commission,
    CASE 
        WHEN salary > 90000 THEN 'Top Earner'
        WHEN salary BETWEEN 70000 AND 90000 THEN 'High Earner'
        ELSE 'Standard Earner'
    END AS earner_category
FROM EMPLOYEES
WHERE department_id = 10
ORDER BY salary DESC;
```

---

## 7. Sample Input Table: `EMPLOYEES` (Dept 10)
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | HIRE_DATE | SALARY | COMMISSION_PCT |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | 2018-01-15 | 125000.00 | *null* |
| 102 | Alice | Smith | 2019-03-20 | 95000.00 | 0.15 |
| 104 | Michael | Scott | 2020-02-01 | 82000.00 | *null* |
| 105 | Elena | Rostova | 2021-08-15 | 65000.00 | *null* |

---

## 8. Expected Output
*(Assuming current year is 2026)*

| EMPLOYEE_ID | EMPLOYEE_NAME | HIRE_DATE | TENURE_YEARS | MONTHLY_SALARY | COMMISSION | EARNER_CATEGORY |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert KING | 2018-01-15 | 8.8 | $125,000.00 | None | Top Earner |
| 102 | Alice SMITH | 2019-03-20 | 7.6 | $95,000.00 | 15% | Top Earner |
| 104 | Michael SCOTT | 2020-02-01 | 6.7 | $82,000.00 | None | High Earner |
| 105 | Elena ROSTOVA | 2021-08-15 | 5.2 | $65,000.00 | None | Standard Earner |

---

## 9. Step-by-Step Explanation of How the Query Works
1. `INITCAP(first_name) || ' ' || UPPER(last_name)` formats the first name into proper case and converts the surname to full uppercase.
2. `MONTHS_BETWEEN(SYSDATE, hire_date) / 12` calculates elapsed months, divides by 12, and `ROUND(..., 1)` truncates to one decimal place.
3. `NVL2(commission_pct, ...)` checks if commission is present. If yes, it formats `0.15 * 100` with a percent sign; if null, it prints `'None'`.
4. `CASE` evaluates top-to-bottom: Robert (125k) and Alice (95k) match `> 90000` ('Top Earner'); Michael (82k) matches `BETWEEN 70000 AND 90000` ('High Earner'); Elena (65k) falls into `ELSE` ('Standard Earner').

---

## 10. Common Mistakes
1. **Using Aggregate Functions in the WHERE Clause**: Writing `WHERE salary > AVG(salary)`. This causes `ORA-00934: group function is not allowed here`. Use a subquery or `HAVING` instead!
2. **Confusing ROUND and TRUNC on Dates or Decimals**: `ROUND(45.5)` yields `46`, whereas `TRUNC(45.5)` cuts off to `45`.
3. **SUBSTR 0-based vs 1-based indexing**: Unlike C++/Java/Python, SQL string indexing starts at **1**. `SUBSTR('Hello', 1, 2)` returns `'He'`.
4. **Expecting `COUNT(column)` to count NULLs**: `COUNT(column)` ignores NULL values! Only `COUNT(*)` counts all physical rows regardless of nulls.
5. **Forgetting `END` on CASE**: Omitting the closing `END` keyword produces a syntax error.

---

## 11. Interview Questions
1. **What is the difference between `COUNT(*)`, `COUNT(1)`, and `COUNT(column)`?**
   - *Answer*: `COUNT(*)` and `COUNT(1)` count all rows in the table, including rows where some or all columns are NULL. `COUNT(column)` counts only rows where the specified column is NOT NULL.
2. **What is the difference between `NVL` and `COALESCE`?**
   - *Answer*: `NVL` is Oracle-specific and takes exactly two arguments, always evaluating both. `COALESCE` is ANSI-standard, accepts multiple arguments, returns the first non-null value, and uses short-circuit evaluation.
3. **What is the difference between `ROUND` and `TRUNC`?**
   - *Answer*: `ROUND` rounds up or down to the nearest digit based on the subsequent digit (>= 5 rounds up). `TRUNC` chops off remaining digits without any rounding.
4. **Can aggregate functions be placed in a `WHERE` clause?**
   - *Answer*: No. The `WHERE` clause filters individual rows before aggregation occurs. Filtering based on aggregate values must be done in the `HAVING` clause or via a subquery.

---

## 12. Short Summary
- Single-row functions transform data row by row (strings, numbers, dates, null-handling).
- Aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) summarize sets of rows and ignore `NULL`s.
- `NVL`, `NVL2`, and `COALESCE` handle missing values gracefully.
- The `CASE` expression provides powerful `IF-THEN-ELSE` conditional logic in queries.
