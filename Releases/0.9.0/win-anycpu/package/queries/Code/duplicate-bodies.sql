-- title: Find duplicate declaration bodies
-- description: Group exact declaration-body hashes repeated across source locations.
-- category: Code
-- command: code-duplicates
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: minimum_lines=3

SELECT Kind,
       Hash,
       count(*) AS Copies,
       min(EndLine - StartLine + 1) AS Lines,
       group_concat(SourcePath || ':' || StartLine, char(10)) AS Locations
FROM code_rows
WHERE coalesce(Hash, '') <> ''
  AND coalesce(FullRecord, '') <> ''
  AND EndLine - StartLine + 1 >= max(CAST(coalesce(:minimum_lines, 3) AS INTEGER), 1)
  AND Kind NOT IN ('Namespace', 'Using', 'Import', 'Comment', 'XmlDocTrivia', 'Diagnostic', 'SourceLine')
GROUP BY Kind, Hash
HAVING count(*) > 1
ORDER BY Copies DESC, Lines DESC, Kind COLLATE NOCASE
LIMIT 500;
