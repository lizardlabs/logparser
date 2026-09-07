-- title: Recursive disk-usage report
-- description: Materialize the current directory once and return overview, largest folders, largest files, and extension statistics.
DROP TABLE IF EXISTS temp.disk_usage_source;
DROP TABLE IF EXISTS temp.disk_usage_files;

CREATE VIRTUAL TABLE temp.disk_usage_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

CREATE TEMP TABLE disk_usage_files AS
SELECT coalesce(nullif(FullName, ''), Name) AS FullPath,
       EXTRACT_FILENAME(coalesce(nullif(FullName, ''), Name)) AS FileName,
       EXTRACT_PATH(coalesce(nullif(FullName, ''), Name)) AS DirectoryPath,
       lower(coalesce(nullif(Extension, ''), nullif(EXTRACT_EXTENSION(coalesce(nullif(FullName, ''), Name)), ''), '(no extension)')) AS Extension,
       LengthInBytes,
       LastWriteTime
FROM disk_usage_source
WHERE coalesce(nullif(FullName, ''), Name) IS NOT NULL
  AND LengthInBytes IS NOT NULL;

SELECT COUNT(*) AS FileCount,
       COUNT(DISTINCT DirectoryPath) AS FolderCount,
       SUM(LengthInBytes) AS TotalBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS TotalSize,
       HUMANIZE_BYTES(AVG(LengthInBytes), '0.##') AS AverageFileSize,
       HUMANIZE_BYTES(MEDIAN(LengthInBytes), '0.##') AS MedianFileSize,
       MAX(LastWriteTime) AS NewestFileTime
FROM disk_usage_files;

SELECT DirectoryPath AS FolderPath,
       COUNT(*) AS DirectFileCount,
       SUM(LengthInBytes) AS DirectBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS DirectSize
FROM disk_usage_files
GROUP BY DirectoryPath
ORDER BY DirectBytes DESC
LIMIT 20;

SELECT FileName, DirectoryPath, LengthInBytes AS SizeBytes,
       HUMANIZE_BYTES(LengthInBytes, '0.##') AS Size, LastWriteTime
FROM disk_usage_files
ORDER BY SizeBytes DESC
LIMIT 20;

SELECT Extension, COUNT(*) AS FileCount,
       SUM(LengthInBytes) AS TotalBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS TotalSize,
       HUMANIZE_BYTES(PERCENTILE_CONT(LengthInBytes, 0.95), '0.##') AS P95FileSize
FROM disk_usage_files
GROUP BY Extension
ORDER BY TotalBytes DESC
LIMIT 20;
