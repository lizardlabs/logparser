-- title: Recursive file-size statistics by extension
-- description: Summarize file counts, totals, median, and P90/P95/P99 sizes below the current directory.
DROP TABLE IF EXISTS temp.recursive_files_source;
DROP TABLE IF EXISTS temp.recursive_files_materialized;

CREATE VIRTUAL TABLE temp.recursive_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

CREATE TEMP TABLE recursive_files_materialized AS
SELECT coalesce(nullif(FullName, ''), Name) AS FullPath,
       lower(coalesce(nullif(Extension, ''), nullif(EXTRACT_EXTENSION(coalesce(nullif(FullName, ''), Name)), ''), '(no extension)')) AS Extension,
       LengthInBytes
FROM recursive_files_source
WHERE coalesce(nullif(FullName, ''), Name) IS NOT NULL
  AND LengthInBytes IS NOT NULL;

SELECT Extension,
       COUNT(*) AS FileCount,
       SUM(LengthInBytes) AS TotalBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS TotalSize,
       AVG(LengthInBytes) AS AverageBytes,
       HUMANIZE_BYTES(AVG(LengthInBytes), '0.##') AS AverageSize,
       MIN(LengthInBytes) AS MinimumBytes,
       HUMANIZE_BYTES(MIN(LengthInBytes), '0.##') AS MinimumSize,
       MAX(LengthInBytes) AS MaximumBytes,
       HUMANIZE_BYTES(MAX(LengthInBytes), '0.##') AS MaximumSize,
       MEDIAN(LengthInBytes) AS MedianBytes,
       HUMANIZE_BYTES(MEDIAN(LengthInBytes), '0.##') AS MedianSize,
       PERCENTILE_CONT(LengthInBytes, 0.90) AS P90Bytes,
       HUMANIZE_BYTES(PERCENTILE_CONT(LengthInBytes, 0.90), '0.##') AS P90Size,
       PERCENTILE_CONT(LengthInBytes, 0.95) AS P95Bytes,
       HUMANIZE_BYTES(PERCENTILE_CONT(LengthInBytes, 0.95), '0.##') AS P95Size,
       PERCENTILE_CONT(LengthInBytes, 0.99) AS P99Bytes,
       HUMANIZE_BYTES(PERCENTILE_CONT(LengthInBytes, 0.99), '0.##') AS P99Size
FROM recursive_files_materialized
GROUP BY Extension
ORDER BY TotalBytes DESC, Extension COLLATE NOCASE;
