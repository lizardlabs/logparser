-- title: Code complexity and behavior hotspots
-- description: Rank C# members by branch complexity, size, and observable side effects.
-- category: Code
-- command: code-hotspots
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludedKinds:Method -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console
-- parameter: minimum_complexity=2

SELECT Name,
       FullName,
       CyclomaticHint,
       StatementCount,
       EndLine - StartLine + 1 AS Lines,
       HasThrow,
       HasAwait,
       HasFileAccess,
       HasHttpCall,
       HasSqlString,
       SourcePath,
       StartLine
FROM code_rows
WHERE CyclomaticHint >= CAST(coalesce(:minimum_complexity, 2) AS INTEGER)
ORDER BY CyclomaticHint DESC, StatementCount DESC, Lines DESC
LIMIT 250;
