# Chapter 7: WHERE Clause, Operators, and Filtering

## 1. Topic Title
**Filtering Data with the WHERE Clause: Comparison, Logical, Range, Set, Pattern Matching, and NULL Operators**

---

## 2. Simple Definition
- **`WHERE` Clause**: The filtering clause in SQL that specifies search conditions to restrict the rows returned by a query or modified by DML.
- **Comparison Operators**: Test equality and magnitude (`=`, `!=`, `<>`, `>`, `<`, `>=`, `<=`).
- **Logical Operators**: Combine conditions (`AND`, `OR`, `NOT`).
- **Range Operator (`BETWEEN ... AND ...`)**: Tests whether a value falls within an inclusive numeric, string, or date interval.
- **Set Operators (`IN`, `NOT IN`)**: Tests whether a value matches any item in a specified comma-separated list or subquery.
- **Pattern Matching (`LIKE`)**: Matches character sequences using wildcards:
  - `%`: Represents zero, one, or multiple characters.
  - `_`: Represents exactly one character.
- **Null Checks (`IS NULL`, `IS NOT NULL`)**: Tests for unknown/missing values. (Normal comparison `= NULL` is always unknown/false).

---

## 3. Why It Is Used
- **Targeted Insights**: Databases store millions of rows; business decisions require precise subsets (e.g., "all engineers hired after 2021 earning over $70,000").
- **Performance**: Pushing filter conditions down to the database engine minimizes index scans and avoids full-table reads.
- **Data Protection**: Crucial for scoping `UPDATE` and `DELETE` statements to avoid modifying unintended records.

---

## 4. Syntax and Operator Precedence
```sql
-- Standard syntax
SELECT column_list
FROM table_name
WHERE condition1 [AND | OR] condition2;
```

### Logical Operator Precedence (Highest to Lowest)
1. Arithmetic Operators (`*`, `/`, `+`, `-`)
2. Comparison Operators (`=`, `<>`, `<`, `>`, `<=`, `>=`)
3. `IS [NOT] NULL`, `LIKE`, `[NOT] IN`, `[NOT] BETWEEN`
4. `NOT`
5. `AND`
6. `OR`

> [!IMPORTANT]
> `AND` has higher precedence than `OR`! Always use parentheses `(...)` to make your logical grouping explicit and avoid subtle filtering bugs.

---

## 5. 10 Detailed Filtering Examples with Explanations

### Example 1: Basic Comparison
```sql
-- Find employees with salary greater than 80,000
SELECT employee_id, first_name, last_name, salary
FROM EMPLOYEES
WHERE salary > 80000;
```
*Filters rows where `salary` exceeds 80000. Returns Robert King (125k), Alice Smith (95k), David Clark (88k), Michael Scott (82k), Sarah Connor (91k), and Arthur Dent (110k).*

### Example 2: Multiple Conditions with AND
```sql
-- High earners in Department 10
SELECT first_name, last_name, job_title, salary, department_id
FROM EMPLOYEES
WHERE department_id = 10 AND salary >= 80000;
```
*Both conditions must be true: Must be in Dept 10 AND earn at least 80,000.*

### Example 3: OR Condition with Parentheses
```sql
-- Employees in Dept 20 or 30 earning more than 70,000
SELECT first_name, last_name, department_id, salary
FROM EMPLOYEES
WHERE (department_id = 20 OR department_id = 30)
  AND salary > 70000;
```
*Without parentheses, `department_id = 20 OR department_id = 30 AND salary > 70000` would return ALL employees in Dept 20 regardless of salary because `AND` binds first!*

### Example 4: BETWEEN Operator (Inclusive Range)
```sql
-- Students with GPA between 3.50 and 4.00
SELECT student_id, first_name, last_name, gpa
FROM STUDENTS
WHERE gpa BETWEEN 3.50 AND 4.00;
```
*Equivalent to `gpa >= 3.50 AND gpa <= 4.00`. Both lower and upper bounds are inclusive.*

### Example 5: IN Operator (Set Membership)
```sql
-- Employees working in Departments 10, 30, or 60
SELECT employee_id, first_name, department_id
FROM EMPLOYEES
WHERE department_id IN (10, 30, 60);
```
*Equivalent to `department_id = 10 OR department_id = 30 OR department_id = 60`.*

### Example 6: NOT IN Operator
```sql
-- Students not in departments 10 or 20
SELECT student_id, first_name, department_id
FROM STUDENTS
WHERE department_id NOT IN (10, 20);
```
*Selects students whose department is neither 10 nor 20.*

### Example 7: LIKE with '%' Wildcard (Prefix / Suffix Search)
```sql
-- Find all employees whose last name starts with 'S'
SELECT employee_id, first_name, last_name
FROM EMPLOYEES
WHERE last_name LIKE 'S%';
```
*`'S%'` matches any string beginning with uppercase 'S' followed by zero or more characters (e.g., 'Smith', 'Scott').*

### Example 8: LIKE with '_' Wildcard (Exact Character Length)
```sql
-- Find courses with course code where the third character is '1'
SELECT course_id, course_code, course_name
FROM COURSES
WHERE course_code LIKE '__1%';
```
*`'__1%'` skips exactly two characters, checks that the 3rd is `'1'`, followed by any text (matches 'CS101', 'IT105', 'ME101', 'EE102').*

### Example 9: IS NULL and IS NOT NULL
```sql
-- Employees who receive a sales commission
SELECT employee_id, first_name, last_name, commission_pct
FROM EMPLOYEES
WHERE commission_pct IS NOT NULL;
```
*Matches employees with a defined commission. Writing `= NULL` would return 0 rows.*

### Example 10: Date Filtering with Explicit Conversion
```sql
-- Employees hired on or after January 1, 2021
SELECT employee_id, first_name, last_name, hire_date
FROM EMPLOYEES
WHERE hire_date >= TO_DATE('2021-01-01', 'YYYY-MM-DD');
```
*Safely compares dates using Oracle's `TO_DATE` function, independent of client date settings.*

---

## 6. Detailed Example Query with Table Output
Let's run a multi-condition query finding engineering personnel who earn over $70,000 or hold a director title:

```sql
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    job_title,
    salary,
    department_id
FROM EMPLOYEES
WHERE (job_title LIKE '%Engineer%' OR job_title LIKE '%Director%')
  AND salary >= 70000;
```

---

## 7. Sample Input Table: `EMPLOYEES`
| EMPLOYEE_ID | FIRST_NAME | LAST_NAME | JOB_TITLE | SALARY | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | Robert | King | President & CEO | 125000 | 10 |
| 102 | Alice | Smith | Engineering Director | 95000 | 10 |
| 104 | Michael | Scott | Senior Software Engineer | 82000 | 10 |
| 105 | Elena | Rostova | Software Engineer | 65000 | 10 |
| 108 | Sarah | Connor | Mechanical Dept Lead | 91000 | 30 |
| 109 | Carlos | Mendoza | Mechanical Engineer | 71000 | 30 |
| 110 | Jessica | Taylor | Junior CAD Designer | 48000 | 30 |

---

## 8. Expected Output
| EMPLOYEE_ID | EMPLOYEE_NAME | JOB_TITLE | SALARY | DEPARTMENT_ID |
| :--- | :--- | :--- | :--- | :--- |
| 102 | Alice Smith | Engineering Director | 95000 | 10 |
| 104 | Michael Scott | Senior Software Engineer | 82000 | 10 |
| 109 | Carlos Mendoza | Mechanical Engineer | 71000 | 30 |

---

## 9. Step-by-Step Explanation of How the Query Works
1. Row 101 (Robert King): Job title is 'President & CEO' (neither Engineer nor Director). Excluded.
2. Row 102 (Alice Smith): Job title contains 'Director' (True), salary is 95,000 >= 70,000 (True). Included.
3. Row 104 (Michael Scott): Job title contains 'Engineer' (True), salary is 82,000 >= 70,000 (True). Included.
4. Row 105 (Elena Rostova): Job title contains 'Engineer' (True), but salary is 65,000 (False). Excluded.
5. Row 108 (Sarah Connor): Job title does not match 'Engineer' or 'Director'. Excluded.
6. Row 109 (Carlos Mendoza): Job title contains 'Engineer' (True), salary is 71,000 >= 70,000 (True). Included.
7. Row 110 (Jessica Taylor): Neither title matches and salary < 70,000. Excluded.

---

## 10. Common Mistakes
1. **Using `= NULL` or `!= NULL`**: In SQL, `salary = NULL` evaluates to `UNKNOWN`, which evaluates to false in a `WHERE` clause. Always use `IS NULL` or `IS NOT NULL`.
2. **Forgetting AND over OR Precedence**: Writing `WHERE dept = 10 OR dept = 20 AND salary > 50000` evaluates as `WHERE dept = 10 OR (dept = 20 AND salary > 50000)`. Always wrap OR conditions in parentheses!
3. **NOT IN with a list containing NULL**: If any item in a `NOT IN` list is `NULL` (e.g., `WHERE dept_id NOT IN (10, NULL)`), the entire condition evaluates to `UNKNOWN` and returns zero rows!
4. **Case Sensitivity in LIKE**: In Oracle, `'Smith'` does not match `'smith'`. To perform a case-insensitive search, wrap with `UPPER`: `WHERE UPPER(last_name) LIKE 'SMITH%'`.

---

## 11. Interview Questions
1. **Why does `column = NULL` not work in SQL?**
   - *Answer*: Because `NULL` signifies an unknown or missing value. Under SQL's three-valued logic (TRUE, FALSE, UNKNOWN), comparing anything to an unknown is itself UNKNOWN. Only `IS NULL` evaluates whether the state is missing.
2. **What is the trap with `NOT IN` when the subquery or list contains a `NULL`?**
   - *Answer*: `x NOT IN (1, NULL)` expands to `x != 1 AND x != NULL`. Because `x != NULL` evaluates to `UNKNOWN`, the whole `AND` expression evaluates to `UNKNOWN`, returning zero rows.
3. **How do you search for an actual percent sign (`%`) using `LIKE`?**
   - *Answer*: Use the `ESCAPE` clause. For example: `WHERE discount LIKE '%\%%' ESCAPE '\';`.
4. **Explain the difference between `AND` and `OR` operator precedence.**
   - *Answer*: `AND` has higher precedence than `OR`. The database evaluates all `AND` operations before `OR` unless parentheses are used to alter evaluation order.

---

## 12. Short Summary
- The `WHERE` clause filters individual records based on conditional logic.
- Comparison (`=`, `<>`), Range (`BETWEEN`), Set (`IN`), and Pattern (`LIKE`) operators provide rich filtering capabilities.
- Always check for missing values using `IS NULL` / `IS NOT NULL`.
- Always use parentheses around `OR` conditions when mixed with `AND`.
