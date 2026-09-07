-- title: Recent Windows errors and warnings
-- description: Materialize System and Application event problems, then show the newest 20.
DROP TABLE IF EXISTS temp.recent_event_problems;
DROP TABLE IF EXISTS temp.system_events_source;
DROP TABLE IF EXISTS temp.application_events_source;

CREATE VIRTUAL TABLE temp.system_events_source
USING ParsingModule('System', '-i:EVT -IncludeMessage:OnlyErrorsAndWarnings');

CREATE VIRTUAL TABLE temp.application_events_source
USING ParsingModule('Application', '-i:EVT -IncludeMessage:OnlyErrorsAndWarnings');

CREATE TEMP TABLE recent_event_problems AS
SELECT 'System' AS LogName, TimeCreated, EventId, EventTypeName, ProviderName, Message
FROM system_events_source
WHERE EventTypeName IN ('Error', 'Warning')
LIMIT 1000;

INSERT INTO recent_event_problems
SELECT 'Application', TimeCreated, EventId, EventTypeName, ProviderName, Message
FROM application_events_source
WHERE EventTypeName IN ('Error', 'Warning')
LIMIT 1000;

SELECT LogName, TimeCreated, EventId, EventTypeName, ProviderName, Message
FROM recent_event_problems
ORDER BY TimeCreated DESC
LIMIT 20;
