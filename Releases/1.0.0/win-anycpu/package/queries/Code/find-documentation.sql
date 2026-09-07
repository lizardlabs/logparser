-- title: Find documented declarations
-- description: Search declaration documentation while retaining exact source spans.
-- category: Code
-- command: code-docs
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: text=

SELECT Language,
       Kind,
       Name,
       FullName,
       Documentation,
       SourcePath,
       StartLine,
       EndLine
FROM code_rows
WHERE coalesce(Documentation, '') <> ''
  AND (coalesce(:text, '') = '' OR Documentation LIKE '%' || :text || '%')
ORDER BY SourcePath COLLATE NOCASE, StartLine, Kind
LIMIT 1000;
