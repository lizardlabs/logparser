-- Integer rows from 1 through 10000.
DROP TABLE IF EXISTS temp.tNumber1;

CREATE VIRTUAL TABLE temp.tNumber1
USING ParsingModule('1', '-i:Numbers -From:1 -To:10000');
