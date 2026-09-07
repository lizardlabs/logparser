-- title: Review the public API surface
-- description: List public and protected declarations with signatures, documentation, and source spans.
-- category: Code
-- command: code-public-api
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: name=

SELECT Language,
       Kind,
       Name,
       FullName,
       Accessibility,
       Modifiers,
       DataType,
       ReturnType,
       Parameters,
       IsObsolete,
       Documentation,
       SourcePath,
       StartLine,
       EndLine
FROM code_rows
WHERE Accessibility IN ('Public', 'Protected', 'Protected Internal')
  AND Kind NOT IN ('Namespace', 'Using', 'Import', 'Comment', 'XmlDocTrivia', 'Diagnostic', 'SourceLine')
  AND (coalesce(:name, '') = ''
       OR Name LIKE '%' || :name || '%'
       OR FullName LIKE '%' || :name || '%')
ORDER BY FullName COLLATE NOCASE, SourcePath COLLATE NOCASE, StartLine
LIMIT 2000;
