-- title: Find base types and interfaces
-- description: Find declarations with a matching base type or implemented interface.
-- category: Code
-- command: code-inheritance
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: type=

SELECT Language,
       Kind,
       Name,
       FullName,
       BaseType,
       Interfaces,
       SourcePath,
       StartLine,
       EndLine
FROM code_rows
WHERE (coalesce(BaseType, '') <> '' OR coalesce(Interfaces, '') <> '')
  AND (coalesce(:type, '') = ''
       OR BaseType LIKE '%' || :type || '%'
       OR Interfaces LIKE '%' || :type || '%')
ORDER BY SourcePath COLLATE NOCASE, StartLine, Kind
LIMIT 1000;
