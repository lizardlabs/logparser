-- Query multiple Windows channels as one ParsingModule table.
DROP TABLE IF EXISTS [windows_events];
CREATE VIRTUAL TABLE [windows_events]
USING ParsingModule('System,Application', '-i:EVT -Direction:BACKWARD');

SELECT
    [EventTypeName],
    [SourceName],
    COUNT(*) AS [EventCount],
    MAX([TimeCreated]) AS [MostRecent]
FROM [windows_events]
WHERE [EventTypeName] IN ('Error', 'Warning')
GROUP BY [EventTypeName], [SourceName]
HAVING COUNT(*) > 0
ORDER BY [EventCount] DESC, [MostRecent] DESC
LIMIT 100;
