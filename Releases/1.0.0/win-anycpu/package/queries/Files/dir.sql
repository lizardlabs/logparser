-- title: Directory listing
-- description: List files like dir, with optional extension filtering and readable sizes.
-- category: Files
-- command: dir
-- provider: FileSystem
-- source: .\*
-- table: dir_files
-- input-options: -Recurse:0 -IncludeAllFiles:ON -IncludeMediaProperties:OFF
-- default-format: Terminal
-- default-destination: console
-- parameter: extension=

SELECT EXTRACT_FILENAME(coalesce(FullName, Name)) AS Name,
       lower(EXTRACT_EXTENSION(coalesce(FullName, Name))) AS Extension,
       HUMANIZE_BYTES(LengthInBytes, '0.##') AS Size,
       LengthInBytes AS SizeBytes,
       LastWriteTime,
       coalesce(FullName, Name) AS FullName
FROM dir_files
WHERE coalesce(:extension, '') = ''
   OR lower(ltrim(EXTRACT_EXTENSION(coalesce(FullName, Name)), '.')) = lower(ltrim(:extension, '.'))
ORDER BY Extension, Name COLLATE NOCASE
LIMIT 200;
