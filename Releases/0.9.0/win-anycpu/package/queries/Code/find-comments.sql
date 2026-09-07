-- title: Find comments and TODO markers
-- description: Search ordinary comments and XML documentation without matching executable source text.
-- category: Code
-- command: code-comments
-- provider: SourceCode
-- source: .\*
-- table: code_rows
-- input-options: -Recurse:-1 -IncludedKinds:Comment,XmlDocTrivia -IncludeComments:ON -IncludeXmlDocumentationTrivia:ON -IncludeDiagnostics:OFF -MaximumFiles:5000 -MaximumRowsPerFile:20000
-- default-format: Terminal
-- default-destination: console
-- parameter: text=TODO

SELECT Language,
       Kind,
       SourcePath,
       StartLine,
       EndLine,
       FullRecord AS CommentText
FROM code_rows
WHERE coalesce(:text, '') = ''
   OR FullRecord LIKE '%' || :text || '%'
   OR Comments LIKE '%' || :text || '%'
ORDER BY SourcePath COLLATE NOCASE, StartLine, Kind
LIMIT 1000;
