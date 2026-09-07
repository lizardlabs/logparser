-- TEMP objects are connection-local and do not modify a database file.
CREATE TEMP VIEW IF NOT EXISTS active_employee_directory AS
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    CAST(e.salary AS INTEGER) AS salary
FROM sample_employees AS e
JOIN sample_departments AS d
  ON CAST(d.department_id AS INTEGER) = CAST(e.department_id AS INTEGER)
WHERE lower(e.active) = 'true';

SELECT *
FROM active_employee_directory
WHERE salary >= 100000
ORDER BY department_name, employee_name;
