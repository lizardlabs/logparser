-- title: Search structured code metadata
-- description: Search names, signatures, types, calls, and inheritance without scanning comment rows.
-- category: Code
-- command: code-structure
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
       ParentName,
       DataType,
       ReturnType,
       Parameters,
       BaseType,
       Interfaces,
       CalledMethods,
       UsedTypes,
       SourcePath,
       StartLine,
       EndLine
FROM code_rows
WHERE coalesce(:text, '') = ''
   OR Name LIKE '%' || :text || '%'
   OR FullName LIKE '%' || :text || '%'
   OR ParentName LIKE '%' || :text || '%'
   OR DataType LIKE '%' || :text || '%'
   OR ReturnType LIKE '%' || :text || '%'
   OR Parameters LIKE '%' || :text || '%'
   OR BaseType LIKE '%' || :text || '%'
   OR Interfaces LIKE '%' || :text || '%'
   OR CalledMethods LIKE '%' || :text || '%'
   OR UsedTypes LIKE '%' || :text || '%'
ORDER BY SourcePath COLLATE NOCASE, StartLine, Kind
LIMIT 1000;
