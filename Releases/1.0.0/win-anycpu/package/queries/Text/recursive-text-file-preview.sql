-- title: Preview text files recursively
-- description: Show source paths and the first 200 non-empty text lines found below the current directory.
DROP TABLE IF EXISTS temp.recursive_text_source;

CREATE VIRTUAL TABLE temp.recursive_text_source
USING ParsingModule('.\*.txt', '-i:TextLine -Recurse:-1 -ExtendedFields:ON');

SELECT StreamName AS SourceFile,
       StreamLineNumber AS LineNumber,
       RecordIndex,
       Text
FROM recursive_text_source
WHERE trim(Text) <> ''
ORDER BY StreamName COLLATE NOCASE, StreamLineNumber
LIMIT 200;
