-- title: Find code symbols
-- description: Find C# types and members by simple or fully-qualified name.
-- category: Code
-- command: code-symbol
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: name=
-- parameter: kind=

SELECT Kind,
       Name,
       FullName,
       ParentName,
       SourcePath,
       StartLine,
       EndLine,
       Modifiers,
       ReturnType,
       Parameters
FROM code_rows
WHERE (coalesce(:name, '') = ''
       OR Name LIKE '%' || :name || '%'
       OR FullName LIKE '%' || :name || '%')
  AND (coalesce(:kind, '') = '' OR Kind = :kind COLLATE NOCASE)
ORDER BY SourcePath COLLATE NOCASE, StartLine, Kind
LIMIT 500;
