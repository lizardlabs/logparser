-- title: Find method call sites
-- description: Find parsed members that invoke a named method.
-- category: Code
-- command: code-calls
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludedKinds:Method -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: method=

SELECT Name,
       FullName,
       CalledMethods,
       SourcePath,
       StartLine,
       EndLine
FROM code_rows
WHERE coalesce(:method, '') = ''
   OR ',' || replace(CalledMethods, ', ', ',') || ',' LIKE '%,' || :method || ',%'
   OR CalledMethods LIKE '%' || :method || '%'
ORDER BY SourcePath COLLATE NOCASE, StartLine
LIMIT 500;
