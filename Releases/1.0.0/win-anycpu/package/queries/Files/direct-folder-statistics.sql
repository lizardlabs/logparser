-- title: Direct file size by folder
-- description: Summarize only the files directly contained in each discovered folder.
DROP TABLE IF EXISTS temp.direct_folder_files_source;

CREATE VIRTUAL TABLE temp.direct_folder_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

SELECT EXTRACT_PATH(coalesce(nullif(FullName, ''), Name)) AS FolderPath,
       COUNT(*) AS DirectFileCount,
       SUM(LengthInBytes) AS DirectBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS DirectSize,
       AVG(LengthInBytes) AS AverageBytes,
       HUMANIZE_BYTES(AVG(LengthInBytes), '0.##') AS AverageSize,
       MIN(LastWriteTime) AS OldestFileTime,
       MAX(LastWriteTime) AS NewestFileTime
FROM direct_folder_files_source
WHERE coalesce(nullif(FullName, ''), Name) IS NOT NULL
GROUP BY FolderPath
ORDER BY DirectBytes DESC, FolderPath COLLATE NOCASE
LIMIT 200;
