-- Recursive CTE combined with correlated counts.
WITH RECURSIVE years(year) AS
(
    VALUES(2016)
    UNION ALL
    SELECT year + 1 FROM years WHERE year < 2026
)
SELECT
    year,
    (
        SELECT COUNT(*)
        FROM sample_employees
        WHERE CAST(substr(hired_on, 1, 4) AS INTEGER) = years.year
    ) AS hires
FROM years
ORDER BY year;
