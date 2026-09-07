-- title: Read a text line range
-- description: Return an inclusive line range from arbitrary text files with source paths.
-- category: Text
-- command: text-lines
-- provider: TextLine
-- source: .\*.txt
-- table: text_lines
-- input-options: -Recurse:0 -ExtendedFields:ON
-- default-format: Terminal
-- default-destination: console
-- parameter: start_line=1
-- parameter: end_line=80
-- parameter: path=

SELECT StreamName AS SourcePath,
       StreamLineNumber AS Line,
       Text
FROM text_lines
WHERE StreamLineNumber >= max(CAST(coalesce(:start_line, 1) AS INTEGER), 1)
  AND StreamLineNumber <= max(CAST(coalesce(:end_line, 80) AS INTEGER), 1)
  AND (coalesce(:path, '') = '' OR StreamName LIKE '%' || :path || '%')
ORDER BY StreamName COLLATE NOCASE, StreamLineNumber
LIMIT 5000;
