-- title: Preview local text files
-- description: Read the first lines available from .txt files in the current directory.
DROP TABLE IF EXISTS temp.text_files_source;

CREATE VIRTUAL TABLE temp.text_files_source
USING ParsingModule('.\*.txt', '-i:TextLine -Recurse:0 -ExtendedFields:ON');

SELECT RecordIndex, Text
FROM text_files_source
WHERE trim(Text) <> ''
LIMIT 100;
