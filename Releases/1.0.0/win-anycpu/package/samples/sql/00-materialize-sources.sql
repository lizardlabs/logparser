-- ParsingModule tables stream their input. Materialize them before joins,
-- repeated scans, window functions, or other multi-pass query plans.
-- TEMP tables live only for this ULP connection and do not modify a database file.
CREATE TEMP TABLE sample_employees AS
SELECT * FROM employees;

CREATE TEMP TABLE sample_departments AS
SELECT * FROM departments;
