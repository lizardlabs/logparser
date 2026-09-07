-- title: Folder and subfolder cumulative sizes
-- description: Roll every file into all ancestor folders to calculate complete recursive subtree sizes.
DROP TABLE IF EXISTS temp.subtree_files_source;
DROP TABLE IF EXISTS temp.subtree_files_materialized;

CREATE VIRTUAL TABLE temp.subtree_files_source
USING ParsingModule('.\*', '-i:FileSystem -Recurse:-1 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');

CREATE TEMP TABLE subtree_files_materialized AS
SELECT coalesce(nullif(FullName, ''), Name) AS FullPath,
       EXTRACT_PATH(coalesce(nullif(FullName, ''), Name)) AS DirectoryPath,
       LengthInBytes
FROM subtree_files_source
WHERE coalesce(nullif(FullName, ''), Name) IS NOT NULL
  AND LengthInBytes IS NOT NULL;

WITH RECURSIVE file_ancestors(FullPath, FolderPath, LengthInBytes, AncestorLevel) AS (
    SELECT FullPath, DirectoryPath, LengthInBytes, 0
    FROM subtree_files_materialized
    WHERE DirectoryPath IS NOT NULL

    UNION ALL

    SELECT FullPath, EXTRACT_PATH(FolderPath), LengthInBytes, AncestorLevel + 1
    FROM file_ancestors
    WHERE AncestorLevel < 63
      AND FolderPath <> TO_ABSOLUTE_PATH('.')
      AND lower(FolderPath) LIKE lower(TO_ABSOLUTE_PATH('.')) || '%'
      AND EXTRACT_PATH(FolderPath) IS NOT NULL
      AND EXTRACT_PATH(FolderPath) <> FolderPath
)
SELECT FolderPath,
       COUNT(*) AS RecursiveFileCount,
       SUM(LengthInBytes) AS RecursiveBytes,
       HUMANIZE_BYTES(SUM(LengthInBytes), '0.##') AS RecursiveSize,
       MAX(AncestorLevel) AS DescendantLevels
FROM file_ancestors
WHERE FolderPath IS NOT NULL
GROUP BY FolderPath
ORDER BY RecursiveBytes DESC, FolderPath COLLATE NOCASE
LIMIT 200;
