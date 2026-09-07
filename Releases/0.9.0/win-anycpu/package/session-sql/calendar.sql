-- Calendar rows from 2000-01-01 through 2100-12-31.
DROP TABLE IF EXISTS temp.tDate1;

CREATE VIRTUAL TABLE temp.tDate1
USING ParsingModule('2000-01-01,2100-12-31', '-i:Dates');
