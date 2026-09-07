-- title: Current directory size by extension
-- description: Materialize file metadata and summarize counts and storage by extension.
DROP TABLE IF EXISTS temp.current_files_source;
DROP TABLE IF EXISTS temp.current_files_materialized;

CREATE VIRTUAL TABLE temp.current_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:0 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

CREATE TEMP TABLE current_files_materialized AS
SELECT EXTRACT_FILENAME(coalesce(FullName, Name)) AS Name,
       coalesce(FullName, Name) AS FullName,
       lower(coalesce(nullif(EXTRACT_EXTENSION(coalesce(FullName, Name)), ''), '(no extension)')) AS Extension,
       LengthInBytes
FROM current_files_source;

SELECT Extension,
       COUNT(*) AS FileCount,
       SUM(LengthInBytes) AS TotalBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS TotalSize,
       HUMANIZE_BYTES(AVG(LengthInBytes), '0.##') AS AverageSize
FROM current_files_materialized
GROUP BY Extension
ORDER BY TotalBytes DESC, Extension COLLATE NOCASE;
