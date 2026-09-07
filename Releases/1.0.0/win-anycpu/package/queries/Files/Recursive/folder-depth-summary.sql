-- title: Recursive file statistics by folder depth
-- description: Show directory, file-count, and storage growth at each depth below the current directory.
DROP TABLE IF EXISTS temp.depth_files_source;
DROP TABLE IF EXISTS temp.depth_files_materialized;

CREATE VIRTUAL TABLE temp.depth_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

CREATE TEMP TABLE depth_files_materialized AS
SELECT EXTRACT_PATH(coalesce(nullif(FullName, ''), Name)) AS DirectoryPath,
       LengthInBytes
FROM depth_files_source
WHERE coalesce(nullif(FullName, ''), Name) IS NOT NULL
  AND LengthInBytes IS NOT NULL;

WITH depth_rows AS (
    SELECT DirectoryPath,
           max(0,
               (length(DirectoryPath) - length(replace(DirectoryPath, '\', ''))) -
               (length(TO_ABSOLUTE_PATH('.')) - length(replace(TO_ABSOLUTE_PATH('.'), '\', '')))
           ) AS FolderDepth,
           LengthInBytes
    FROM depth_files_materialized
    WHERE DirectoryPath IS NOT NULL
)
SELECT FolderDepth,
       COUNT(DISTINCT DirectoryPath) AS FolderCount,
       COUNT(*) AS FileCount,
       SUM(LengthInBytes) AS TotalBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS TotalSize,
       HUMANIZE_BYTES(AVG(LengthInBytes), '0.##') AS AverageFileSize
FROM depth_rows
GROUP BY FolderDepth
ORDER BY FolderDepth;
