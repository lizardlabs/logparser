-- Parse the fictional sample log one line at a time.
DROP TABLE IF EXISTS [application_log];
CREATE VIRTUAL TABLE [application_log]
USING ParsingModule(
    'samples\data\application.log',
    '-i:TextLine -ExtendedFields:ON -IncludeFullRecord:ON'
);

SELECT
    [Text],
    [FullRecord]
FROM [application_log]
WHERE [Text] LIKE '%ERROR%'
ORDER BY [Text]
LIMIT 100;
