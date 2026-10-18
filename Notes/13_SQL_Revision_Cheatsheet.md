# Chapter 13: SQL Revision Cheatsheet & Rapid Interview Review

## 1. Topic Title
**Comprehensive SQL Revision Cheatsheet: Syntax Templates, Command Comparisons, Best Practices, and High-Yield Interview Q&A**

---

## 2. Simple Definition
- This chapter is a rapid reference guide consolidating all essential SQL fundamentals, syntax patterns, comparison matrices, operator rules, and top interview questions covered across Chapters 1 through 12.

---

## 3. Why It Is Used
- **Exam & Interview Prep**: Fast review of core concepts before technical interviews or exams.
- **Quick Reference Guide**: Instant access to correct SQL syntax without having to search multiple chapters.
- **Bug Prevention**: A checklist of classic SQL gotchas (operator precedence, NULL traps, GROUP BY rules) to review before writing production queries.

---

## 4. Master Syntax Reference
```sql
-- DDL
CREATE TABLE table_name (
    id NUMBER(5) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    dept_id NUMBER(5) REFERENCES parent_table(id)
);
ALTER TABLE table_name ADD (col_name datatype);
ALTER TABLE table_name MODIFY (col_name datatype);
ALTER TABLE table_name DROP COLUMN col_name;
TRUNCATE TABLE table_name;
DROP TABLE table_name CASCADE CONSTRAINTS;

-- DML
INSERT INTO table_name (c1, c2) VALUES (v1, v2);
UPDATE table_name SET c1 = v1 WHERE condition;
DELETE FROM table_name WHERE condition;

-- TCL
COMMIT;
ROLLBACK;
SAVEPOINT sp_name;
ROLLBACK TO sp_name;

-- DQL (Complete Query Template)
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_staff,
    ROUND(AVG(e.salary), 2) AS avg_sal
FROM DEPARTMENTS d
LEFT JOIN EMPLOYEES e ON d.department_id = e.department_id
WHERE e.salary > 40000 OR e.salary IS NULL
GROUP BY d.department_name
HAVING COUNT(e.employee_id) >= 1
ORDER BY avg_sal DESC NULLS LAST;
```

---

## 5. Critical Command Comparison Matrices

### Matrix 1: DELETE vs. TRUNCATE vs. DROP
| Attribute | `DELETE` | `TRUNCATE` | `DROP` |
| :--- | :--- | :--- | :--- |
| **Category** | DML | DDL | DDL |
| **WHERE Filter** | Supported | Not supported | Not supported |
| **Rollback Possible?**| **Yes** | **No** (in Oracle) | **No** |
| **Speed** | Slower (logs row deletes) | Instantaneous | Instantaneous |
| **Structure Stays?** | Yes | Yes | **No (Destroyed)** |

### Matrix 2: WHERE vs. HAVING
| Attribute | `WHERE` | `HAVING` |
| :--- | :--- | :--- |
| **Execution Phase** | Before grouping (`FROM -> WHERE -> GROUP BY`) | After grouping (`GROUP BY -> HAVING`) |
| **Filtering Level** | Raw individual rows | Grouped aggregate summaries |
| **Aggregate Functions**| **Illegal** (`WHERE AVG(sal) > 5000` ❌) | **Legal** (`HAVING AVG(sal) > 5000` ✅) |

### Matrix 3: IN vs. EXISTS
| Attribute | `IN` | `EXISTS` |
| :--- | :--- | :--- |
| **Inner Query Evaluation**| Retrieves the complete result set into memory | Short-circuits on first matching boolean row |
| **Best suited for** | Small, static lists of literal values | Correlated subqueries against large child tables |
| **NULL Safety** | **Danger**: Breaks with `NOT IN` if any inner value is `NULL` | **Safe**: Handles `NULL`s reliably |

---

## 6. Complete JOIN Comparison Matrix
| Join Type | Returns | When Unmatched on the other side |
| :--- | :--- | :--- |
| **`INNER JOIN`** | Only matching rows from both tables | Discarded completely |
| **`LEFT OUTER JOIN`** | All rows from Left table + matching from Right | Right columns filled with `NULL` |
| **`RIGHT OUTER JOIN`**| All rows from Right table + matching from Left | Left columns filled with `NULL` |
| **`FULL OUTER JOIN`** | All rows from both tables | Unmatched columns on either side filled with `NULL`|
| **`CROSS JOIN`** | Cartesian product ($N \times M$ combinations) | No match condition used |
| **`SELF JOIN`** | Table joined to itself using two distinct aliases | Resolves hierarchical relationships |

---

## 7. Subquery Operator Cheat Sheet
| Operator | Meaning | Example |
| :--- | :--- | :--- |
| **`=` / `<>` / `>`** | Single-row scalar comparison | `salary > (SELECT AVG(salary) FROM ...)` |
| **`IN`** | Equal to ANY member of the set | `dept_id IN (SELECT dept_id FROM ...)` |
| **`NOT IN`** | Unequal to EVERY member of the set | `dept_id NOT IN (10, 20)` *(Ensure no NULLs!)* |
| **`> ANY`** | Greater than the *minimum* value of subquery | `salary > ANY (50k, 70k, 90k)` -> salary > 50k |
| **`> ALL`** | Greater than the *maximum* value of subquery | `salary > ALL (50k, 70k, 90k)` -> salary > 90k |
| **`EXISTS`** | TRUE if subquery returns $\ge 1$ row | `WHERE EXISTS (SELECT 1 FROM ...)` |
| **`NOT EXISTS`** | TRUE if subquery returns 0 rows | `WHERE NOT EXISTS (SELECT 1 FROM ...)` |

---

## 8. Query Processing Order (Logical Execution vs Written Order)
Understanding the database engine's internal order of execution prevents syntax mistakes:

```text
Written Order:                     Logical Execution Order:
1. SELECT                          1. FROM (and JOINs)
2. FROM                            2. WHERE
3. WHERE                           3. GROUP BY
4. GROUP BY                        4. HAVING
5. HAVING                          5. SELECT (evaluates aliases & expressions)
6. ORDER BY                        6. DISTINCT
                                   7. ORDER BY
```

---

## 9. Top 10 Common SQL Beginner Mistakes to Avoid
1. **The `ORA-00979` GROUP BY Violation**: Selecting columns not in the `GROUP BY` clause.
2. **Missing WHERE in UPDATE/DELETE**: Accidentally overwriting or deleting all table rows.
3. **Using `= NULL`**: Always use `IS NULL` or `IS NOT NULL`.
4. **`NOT IN` with Subquery returning NULL**: Subquery returning NULL breaks `NOT IN`. Use `NOT EXISTS` instead.
5. **Operator Precedence Bug**: Mixing `AND` and `OR` without parentheses.
6. **String vs Identifier Quotes**: Using double quotes `"..."` for string literals instead of single quotes `'...'`.
7. **Forgetting COMMIT in Oracle**: Closing sessions without committing DML transactions.
8. **Placing Aggregate in WHERE**: Filtering `WHERE SUM(...) > 1000` instead of using `HAVING`.
9. **Cartesian Product**: Forgetting the `ON` condition when performing table joins.
10. **NULL propagation in Math**: Forgetting that `100 + NULL = NULL`. Wrap optional columns in `NVL()`.

---

## 10. Frequently Asked SQL Interview Questions
1. **How do you find the second highest salary without using analytical functions?**
   - *Query*:
     ```sql
     SELECT MAX(salary) FROM EMPLOYEES WHERE salary < (SELECT MAX(salary) FROM EMPLOYEES);
     ```
2. **How do you delete duplicate records from a table while keeping one?**
   - *Query (using Oracle ROWID)*:
     ```sql
     DELETE FROM STUDENTS
     WHERE ROWID NOT IN (
         SELECT MIN(ROWID) FROM STUDENTS GROUP BY email
     );
     ```
3. **What is the difference between Primary Key and Unique Key?**
   - *Answer*: Primary Key does not allow NULLs and can only exist once per table. Unique Key allows NULLs and multiple unique keys can exist on a single table.
4. **What does NVL vs NVL2 do in Oracle?**
   - *Answer*: `NVL(x, y)` returns `y` if `x` is null; `NVL2(x, a, b)` returns `a` if `x` is NOT null, and `b` if `x` is null.
5. **How does Oracle sort NULL values by default in ORDER BY?**
   - *Answer*: Oracle treats NULL as the highest value. In `ASC`, NULLs are last; in `DESC`, NULLs are first. Override with `NULLS FIRST` or `NULLS LAST`.

---

## 11. Student Revision Checklist
Before advancing to intermediate or advanced SQL topics, confirm you can comfortably:
- [ ] Create and alter tables with PK, FK, UNIQUE, NOT NULL, and CHECK constraints.
- [ ] Perform INSERT, UPDATE, DELETE with safe transaction management (COMMIT / ROLLBACK).
- [ ] Write complex WHERE filters combining comparisons, ranges, sets, and wildcards.
- [ ] Group rows using GROUP BY and filter group metrics using HAVING.
- [ ] Explain the differences between INNER, LEFT, RIGHT, FULL, and SELF joins.
- [ ] Write single-row and correlated subqueries, including finding Nth highest values and `NOT EXISTS`.
- [ ] Handle `NULL` values correctly in expressions and set comparisons.

---

## 12. Short Summary
- Relational databases rely on declarative SQL to define, manipulate, and query structured data.
- Master the logical execution pipeline (`FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY`).
- Always guard against NULL pitfalls, enforce constraint naming, and verify join conditions.
