DROP TABLE IF EXISTS requests;
CREATE VIRTUAL TABLE requests
USING ParsingModule('samples\data\requests.tsv', '-i:TSV');

SELECT timestamp, method, status, path
FROM requests
WHERE CAST(status AS INTEGER) >= 400
ORDER BY timestamp
LIMIT 100;
