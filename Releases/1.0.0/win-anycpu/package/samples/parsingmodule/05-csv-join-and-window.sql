-- Each ParsingModule table is a forward-only stream. Materialize it into
-- connection-local TEMP tables before a join or another multi-pass plan.
DROP TABLE IF EXISTS [employees_stream];
CREATE VIRTUAL TABLE [employees_stream]
USING ParsingModule('samples\data\employees.csv', '-i:CSV');

DROP TABLE IF EXISTS [departments_stream];
CREATE VIRTUAL TABLE [departments_stream]
USING ParsingModule('samples\data\departments.csv', '-i:CSV');

CREATE TEMP TABLE [employees_data] AS SELECT * FROM [employees_stream];
CREATE TEMP TABLE [departments_data] AS SELECT * FROM [departments_stream];

WITH [ranked] AS
(
    SELECT
        e.[employee_name],
        d.[department_name],
        CAST(e.[salary] AS INTEGER) AS [salary],
        DENSE_RANK() OVER
        (
            PARTITION BY d.[department_name]
            ORDER BY CAST(e.[salary] AS INTEGER) DESC
        ) AS [salary_rank]
    FROM [employees_data] AS e
    JOIN [departments_data] AS d
      ON CAST(e.[department_id] AS INTEGER) = CAST(d.[department_id] AS INTEGER)
)
SELECT * FROM [ranked]
ORDER BY [department_name], [salary_rank], [employee_name];
