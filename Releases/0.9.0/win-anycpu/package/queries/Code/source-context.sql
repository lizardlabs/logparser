-- title: Show exact source context
-- description: Return an inclusive line range from one or more source files.
-- category: Code
-- command: code-context
-- provider: SourceCode
-- source: .\*
-- table: code_lines
-- input-options: -Recurse:-1 -IncludeSourceLines:ON -IncludedKinds:SourceLine -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:50000
-- default-format: Terminal
-- default-destination: console
-- parameter: start_line=1
-- parameter: end_line=80
-- parameter: path=

SELECT SourcePath,
       StartLine AS Line,
       FullRecord AS Source
FROM code_lines
WHERE StartLine >= max(CAST(coalesce(:start_line, 1) AS INTEGER), 1)
  AND StartLine <= max(CAST(coalesce(:end_line, 80) AS INTEGER), 1)
  AND (coalesce(:path, '') = '' OR SourcePath LIKE '%' || :path || '%')
ORDER BY SourcePath COLLATE NOCASE, StartLine
LIMIT 5000;
