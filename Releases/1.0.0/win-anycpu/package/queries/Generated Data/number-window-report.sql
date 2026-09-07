-- title: Number ranking and running totals
-- description: Materialize a generated range, then demonstrate SQLite window functions.
DROP TABLE IF EXISTS temp.numbers_source;
DROP TABLE IF EXISTS temp.numbers_materialized;

CREATE VIRTUAL TABLE temp.numbers_source
USING ParsingModule('1', '-i:Numbers -From:1 -To:100');

CREATE TEMP TABLE numbers_materialized AS
SELECT Number, IsEven, Hex, Words
FROM numbers_source;

SELECT Number,
       Words,
       Hex,
       SUM(Number) OVER (ORDER BY Number ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal,
       DENSE_RANK() OVER (PARTITION BY IsEven ORDER BY Number) AS EvenOddRank
FROM numbers_materialized
WHERE Number BETWEEN 1 AND 20
ORDER BY Number;
