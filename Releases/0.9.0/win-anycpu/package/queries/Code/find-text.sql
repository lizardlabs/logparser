-- title: Search source text
-- description: Structured grep over exact C# source lines with stable file and line fields.
-- category: Code
-- command: code-find
-- provider: SourceCode
-- source: .\*
-- table: code_lines
-- input-options: -Recurse:-1 -IncludeSourceLines:ON -IncludedKinds:SourceLine -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:50000
-- default-format: Terminal
-- default-destination: console
-- parameter: text=TODO

SELECT SourcePath,
       StartLine AS Line,
       FullRecord AS Source
FROM code_lines
WHERE coalesce(:text, '') = ''
   OR FullRecord LIKE '%' || :text || '%'
ORDER BY SourcePath COLLATE NOCASE, StartLine
LIMIT 1000;
