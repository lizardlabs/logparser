-- Ranking and a running total within each department.
WITH staff AS
(
    SELECT
        e.employee_name,
        d.department_name,
        CAST(e.salary AS INTEGER) AS salary
    FROM sample_employees AS e
    JOIN sample_departments AS d
      ON CAST(d.department_id AS INTEGER) = CAST(e.department_id AS INTEGER)
)
SELECT
    employee_name,
    department_name,
    salary,
    DENSE_RANK() OVER
      (PARTITION BY department_name ORDER BY salary DESC) AS salary_rank,
    SUM(salary) OVER
      (PARTITION BY department_name ORDER BY salary DESC
       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_payroll
FROM staff
ORDER BY department_name, salary_rank, employee_name;
