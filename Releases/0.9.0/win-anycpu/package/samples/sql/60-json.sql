-- SQLite JSON functions are useful for agent and API-oriented workflows.
SELECT json_object(
    'department', d.department_name,
    'employees', COUNT(*),
    'payroll', SUM(CAST(e.salary AS INTEGER))
) AS department_summary
FROM sample_employees AS e
JOIN sample_departments AS d
  ON CAST(d.department_id AS INTEGER) = CAST(e.department_id AS INTEGER)
GROUP BY d.department_id, d.department_name
ORDER BY d.department_name;
