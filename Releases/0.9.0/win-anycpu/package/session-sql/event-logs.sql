-- Optional Windows Event Log tables. Load explicitly with --session-init-file.
DROP TABLE IF EXISTS temp.tEvt1;
DROP TABLE IF EXISTS temp.tEvt2;

CREATE VIRTUAL TABLE temp.tEvt1
USING ParsingModule('System', '-i:EVT');

CREATE VIRTUAL TABLE temp.tEvt2
USING ParsingModule('Application', '-i:EVT');
