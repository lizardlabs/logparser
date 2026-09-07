-- Inspect how SQLite plans a representative join.
EXPLAIN QUERY PLAN
SELECT e.employee_name, d.department_name
FROM sample_employees AS e
JOIN sample_departments AS d
  ON CAST(d.department_id AS INTEGER) = CAST(e.department_id AS INTEGER)
WHERE CAST(e.salary AS INTEGER) >= 110000;
