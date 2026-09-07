-- CSV headers become SQLite columns dynamically.
DROP TABLE IF EXISTS [employees];
CREATE VIRTUAL TABLE [employees]
USING ParsingModule('samples\data\employees.csv', '-i:CSV');

SELECT
    CAST([department_id] AS INTEGER) AS [DepartmentId],
    COUNT(*) AS [Employees],
    ROUND(AVG(CAST([salary] AS REAL)), 2) AS [AverageSalary],
    SUM(CASE WHEN lower([active]) = 'true' THEN 1 ELSE 0 END) AS [ActiveEmployees]
FROM [employees]
GROUP BY CAST([department_id] AS INTEGER)
ORDER BY [AverageSalary] DESC;
