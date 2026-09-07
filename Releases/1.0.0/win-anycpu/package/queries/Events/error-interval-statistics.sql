-- title: Event error and warning interval statistics
-- description: Group recent System/Application problems by provider and calculate median/P95/P99 seconds between events.
DROP TABLE IF EXISTS temp.interval_system_source;
DROP TABLE IF EXISTS temp.interval_application_source;
DROP TABLE IF EXISTS temp.interval_event_problems;

CREATE VIRTUAL TABLE temp.interval_system_source
USING ParsingModule('System', '-i:EVT -IncludeMessage:Never -IncludeEventXml:OFF -IncludeStrings:OFF -ResolveUserSIDs:OFF');

CREATE VIRTUAL TABLE temp.interval_application_source
USING ParsingModule('Application', '-i:EVT -IncludeMessage:Never -IncludeEventXml:OFF -IncludeStrings:OFF -ResolveUserSIDs:OFF');

CREATE TEMP TABLE interval_event_problems AS
SELECT 'System' AS LogName, TimeCreated, EventId, EventTypeName, ProviderName
FROM interval_system_source
WHERE EventTypeName IN ('Error', 'Warning')
LIMIT 2000;

INSERT INTO interval_event_problems
SELECT 'Application', TimeCreated, EventId, EventTypeName, ProviderName
FROM interval_application_source
WHERE EventTypeName IN ('Error', 'Warning')
LIMIT 2000;

WITH ordered AS (
    SELECT LogName, ProviderName, EventId, TimeCreated,
           (julianday(TimeCreated) - julianday(LAG(TimeCreated) OVER (
               PARTITION BY LogName, ProviderName ORDER BY TimeCreated
           ))) * 86400.0 AS SecondsSincePrevious
    FROM interval_event_problems
    WHERE datetime(TimeCreated) >= datetime('now', '-30 days')
),
provider_intervals AS (
    SELECT LogName, ProviderName, EventId, TimeCreated, SecondsSincePrevious
    FROM ordered
    WHERE SecondsSincePrevious IS NULL OR SecondsSincePrevious >= 0
)
SELECT LogName,
       coalesce(ProviderName, '(unknown provider)') AS ProviderName,
       COUNT(*) AS ProblemCount,
       COUNT(DISTINCT EventId) AS DistinctEventIds,
       MIN(TimeCreated) AS FirstSeen,
       MAX(TimeCreated) AS LastSeen,
       MEDIAN(SecondsSincePrevious) AS MedianIntervalSeconds,
       PERCENTILE_CONT(SecondsSincePrevious, 0.95) AS P95IntervalSeconds,
       PERCENTILE_CONT(SecondsSincePrevious, 0.99) AS P99IntervalSeconds
FROM provider_intervals
GROUP BY LogName, ProviderName
ORDER BY ProblemCount DESC, LogName, ProviderName COLLATE NOCASE
LIMIT 100;
