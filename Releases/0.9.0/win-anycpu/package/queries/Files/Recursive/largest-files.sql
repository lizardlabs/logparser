-- title: Largest files recursively
-- description: Show the 100 largest files below the current directory with raw and Humanizer byte sizes.
DROP TABLE IF EXISTS temp.largest_files_source;

CREATE VIRTUAL TABLE temp.largest_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

SELECT EXTRACT_FILENAME(coalesce(nullif(FullName, ''), Name)) AS FileName,
       EXTRACT_PATH(coalesce(nullif(FullName, ''), Name)) AS DirectoryPath,
       LengthInBytes AS SizeBytes,
       HUMANIZE_BYTES(LengthInBytes, '0.##') AS Size,
       LastWriteTime,
       coalesce(nullif(FullName, ''), Name) AS FullPath
FROM largest_files_source
WHERE LengthInBytes IS NOT NULL
ORDER BY SizeBytes DESC, FullPath COLLATE NOCASE
LIMIT 100;
