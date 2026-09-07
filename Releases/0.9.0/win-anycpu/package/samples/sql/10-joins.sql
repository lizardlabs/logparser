-- Join virtual tables created from employees.csv and departments.csv.
SELECT
    e.employee_name,
    d.department_name,
    CAST(e.salary AS INTEGER) AS salary
FROM sample_employees AS e
JOIN sample_departments AS d
  ON CAST(d.department_id AS INTEGER) = CAST(e.department_id AS INTEGER)
ORDER BY salary DESC, e.employee_name;
