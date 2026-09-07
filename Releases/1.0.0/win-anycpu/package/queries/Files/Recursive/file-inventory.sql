-- title: Recursive file inventory
-- description: List files below the current directory with readable sizes and timestamps; limited to 500 rows.
DROP TABLE IF EXISTS temp.recursive_files_source;

CREATE VIRTUAL TABLE temp.recursive_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

SELECT EXTRACT_FILENAME(coalesce(nullif(FullName, ''), Name)) AS FileName,
       lower(coalesce(nullif(Extension, ''), nullif(EXTRACT_EXTENSION(coalesce(nullif(FullName, ''), Name)), ''), '(no extension)')) AS Extension,
       LengthInBytes AS SizeBytes,
       HUMANIZE_BYTES(LengthInBytes, '0.##') AS Size,
       CreationTime,
       LastWriteTime,
       EXTRACT_PATH(coalesce(nullif(FullName, ''), Name)) AS DirectoryPath,
       coalesce(nullif(FullName, ''), Name) AS FullPath
FROM recursive_files_source
WHERE coalesce(nullif(FullName, ''), Name) IS NOT NULL
ORDER BY FullPath COLLATE NOCASE
LIMIT 500;
