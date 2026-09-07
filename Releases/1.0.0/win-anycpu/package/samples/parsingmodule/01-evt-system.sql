-- Windows System events through the Universal Log Parser SQLite module.
DROP TABLE IF EXISTS [logs];
CREATE VIRTUAL TABLE [logs]
USING ParsingModule('System', '-i:EVT');

-- TABLE: Windows System Events
SELECT *
FROM [logs]
ORDER BY [TimeCreated] DESC
LIMIT 1000;
