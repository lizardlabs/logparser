-- title: Duplicate file candidates by SHA-256
-- description: Hash at most 500 files from the 50 largest size-collision groups; hashing reads file contents and can be expensive.
DROP TABLE IF EXISTS temp.duplicate_files_source;
DROP TABLE IF EXISTS temp.duplicate_files_materialized;

CREATE VIRTUAL TABLE temp.duplicate_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

CREATE TEMP TABLE duplicate_files_materialized AS
SELECT coalesce(nullif(FullName, ''), Name) AS FullPath,
       LengthInBytes
FROM duplicate_files_source
WHERE coalesce(nullif(FullName, ''), Name) IS NOT NULL
  AND LengthInBytes IS NOT NULL;

WITH collision_sizes AS (
    SELECT LengthInBytes
    FROM duplicate_files_materialized
    GROUP BY LengthInBytes
    HAVING COUNT(*) > 1
    ORDER BY LengthInBytes DESC
    LIMIT 50
),
candidates AS (
    SELECT files.FullPath, files.LengthInBytes
    FROM duplicate_files_materialized files
    JOIN collision_sizes sizes ON sizes.LengthInBytes = files.LengthInBytes
    ORDER BY files.LengthInBytes DESC, files.FullPath COLLATE NOCASE
    LIMIT 500
),
hashed AS (
    SELECT FullPath, LengthInBytes, FILE_HASH_SHA256(FullPath) AS Sha256
    FROM candidates
)
SELECT Sha256,
       COUNT(*) AS DuplicateCount,
       LengthInBytes AS SizeBytes,
       HUMANIZE_BYTES(LengthInBytes, '0.##') AS Size,
       GROUP_CONCAT(FullPath, char(10)) AS Files
FROM hashed
WHERE Sha256 IS NOT NULL
GROUP BY Sha256, LengthInBytes
HAVING COUNT(*) > 1
ORDER BY SizeBytes DESC, DuplicateCount DESC;
