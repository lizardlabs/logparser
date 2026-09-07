-- title: Find source syntax diagnostics
-- description: List recoverable parser diagnostics with exact source locations and evidence.
-- category: Code
-- command: code-diagnostics
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludedKinds:Diagnostic -IncludeComments:OFF -IncludeDiagnostics:ON -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: text=

SELECT Language,
       Name AS Diagnostic,
       Documentation AS Message,
       SourcePath,
       StartLine,
       EndLine,
       Column,
       FullRecord AS Evidence
FROM code_rows
WHERE coalesce(:text, '') = ''
   OR Name LIKE '%' || :text || '%'
   OR Documentation LIKE '%' || :text || '%'
ORDER BY SourcePath COLLATE NOCASE, StartLine, Column, Diagnostic
LIMIT 1000;
