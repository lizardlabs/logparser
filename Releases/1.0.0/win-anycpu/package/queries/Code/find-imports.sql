-- title: Find imports and using directives
-- description: List imported namespaces, modules, and packages across supported source languages.
-- category: Code
-- command: code-imports
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeUsingDirectives:ON -IncludedKinds:Using,Import -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:20000
-- default-format: Terminal
-- default-destination: console
-- parameter: name=

SELECT Language,
       Kind,
       Name,
       FullName,
       SourcePath,
       StartLine
FROM code_rows
WHERE coalesce(:name, '') = ''
   OR Name LIKE '%' || :name || '%'
   OR FullName LIKE '%' || :name || '%'
ORDER BY Name COLLATE NOCASE, SourcePath COLLATE NOCASE, StartLine
LIMIT 1000;
