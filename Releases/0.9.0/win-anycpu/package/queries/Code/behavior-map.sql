-- title: Find behavior and side-effect hints
-- description: Locate parsed members that await, throw, yield, use LINQ, SQL, HTTP, or file access.
-- category: Code
-- command: code-behavior
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: behavior=

SELECT Language,
       Kind,
       Name,
       FullName,
       HasAwait,
       HasThrow,
       HasYield,
       HasLinq,
       HasSqlString,
       HasHttpCall,
       HasFileAccess,
       CalledMethods,
       UsedTypes,
       SourcePath,
       StartLine,
       EndLine
FROM code_rows
WHERE Kind IN ('Method', 'Function', 'Property', 'CodeBlock', 'ScriptBlock')
  AND (HasAwait = 'True'
       OR HasThrow = 'True'
       OR HasYield = 'True'
       OR HasLinq = 'True'
       OR HasSqlString = 'True'
       OR HasHttpCall = 'True'
       OR HasFileAccess = 'True')
  AND (coalesce(:behavior, '') = ''
       OR (lower(:behavior) = 'await' AND HasAwait = 'True')
       OR (lower(:behavior) = 'throw' AND HasThrow = 'True')
       OR (lower(:behavior) = 'yield' AND HasYield = 'True')
       OR (lower(:behavior) = 'linq' AND HasLinq = 'True')
       OR (lower(:behavior) = 'sql' AND HasSqlString = 'True')
       OR (lower(:behavior) = 'http' AND HasHttpCall = 'True')
       OR (lower(:behavior) = 'file' AND HasFileAccess = 'True'))
ORDER BY SourcePath COLLATE NOCASE, StartLine, Kind
LIMIT 1000;
