-- Aggregation, conditional aggregation, HAVING, and calculated values.
SELECT
    d.department_name,
    COUNT(*) AS employee_count,
    SUM(CASE WHEN lower(e.active) = 'true' THEN 1 ELSE 0 END) AS active_count,
    ROUND(AVG(CAST(e.salary AS REAL)), 2) AS average_salary,
    MAX(CAST(e.salary AS INTEGER)) AS maximum_salary
FROM sample_employees AS e
JOIN sample_departments AS d
  ON CAST(d.department_id AS INTEGER) = CAST(e.department_id AS INTEGER)
GROUP BY d.department_id, d.department_name
HAVING COUNT(*) >= 1
ORDER BY average_salary DESC;
