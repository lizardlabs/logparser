-- title: Recursive file activity by age
-- description: Bucket files by last-write date and summarize count and storage below the current directory.
DROP TABLE IF EXISTS temp.age_files_source;

CREATE VIRTUAL TABLE temp.age_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

WITH age_rows AS (
    SELECT LengthInBytes,
           CASE
               WHEN date(LastWriteTime) >= date('now', 'localtime') THEN 'Today'
               WHEN date(LastWriteTime) >= date('now', 'localtime', '-6 days') THEN 'Previous 7 days'
               WHEN date(LastWriteTime) >= date('now', 'localtime', 'start of month') THEN 'Earlier this month'
               WHEN date(LastWriteTime) >= date('now', 'localtime', '-1 month') THEN 'Previous month'
               WHEN date(LastWriteTime) >= date('now', 'localtime', '-1 year') THEN 'Previous year'
               ELSE 'Older'
           END AS AgeBucket,
           CASE
               WHEN date(LastWriteTime) >= date('now', 'localtime') THEN 1
               WHEN date(LastWriteTime) >= date('now', 'localtime', '-6 days') THEN 2
               WHEN date(LastWriteTime) >= date('now', 'localtime', 'start of month') THEN 3
               WHEN date(LastWriteTime) >= date('now', 'localtime', '-1 month') THEN 4
               WHEN date(LastWriteTime) >= date('now', 'localtime', '-1 year') THEN 5
               ELSE 6
           END AS BucketOrder
    FROM age_files_source
    WHERE LastWriteTime IS NOT NULL
)
SELECT AgeBucket,
       COUNT(*) AS FileCount,
       SUM(LengthInBytes) AS TotalBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS TotalSize,
       HUMANIZE_BYTES(AVG(LengthInBytes), '0.##') AS AverageSize
FROM age_rows
GROUP BY AgeBucket, BucketOrder
ORDER BY BucketOrder;
