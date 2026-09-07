-- Files and directories immediately below the current working directory.
DROP TABLE IF EXISTS temp.tFile1;

CREATE VIRTUAL TABLE temp.tFile1
USING ParsingModule('.\*', '-i:FileSystem -Recurse:0 -IncludeAllFiles:ON -IncludeMediaProperties:OFF');
