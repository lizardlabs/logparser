-- title: Code symbol inventory
-- description: Summarize C# declarations and members by kind, namespace, and file.
-- category: Code
-- command: code-inventory
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludeComments:OFF -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:10000
-- default-format: Terminal
-- default-destination: console

SELECT Kind,
       count(*) AS Symbols,
       count(DISTINCT SourcePath) AS Files,
       count(DISTINCT nullif(Namespace, '')) AS Namespaces,
       sum(CASE WHEN Accessibility = 'Public' THEN 1 ELSE 0 END) AS PublicSymbols
FROM code_rows
WHERE Kind NOT IN ('Using', 'Comment', 'XmlDocTrivia', 'Diagnostic', 'SourceLine')
GROUP BY Kind
ORDER BY Symbols DESC, Kind COLLATE NOCASE;
