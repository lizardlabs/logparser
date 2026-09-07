DROP TABLE IF EXISTS service_log;
CREATE VIRTUAL TABLE service_log
USING ParsingModule(
    'samples\data\service.log',
    '-i:RegEx -LineRegExConfiguration.RegExPattern:"^(?<Date>\\d{4}-\\d{2}-\\d{2})\\s+(?<Level>\\w+)\\s+(?<Message>.*)$"'
);

SELECT Date, Level, Message
FROM service_log
WHERE Level IN ('WARN', 'ERROR')
LIMIT 100;
