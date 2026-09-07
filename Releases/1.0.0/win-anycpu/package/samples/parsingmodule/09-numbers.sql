DROP TABLE IF EXISTS numbers;
CREATE VIRTUAL TABLE numbers
USING ParsingModule('', '-i:Numbers -From:1 -To:100');

SELECT Number, Formatted, IsEven, Hex
FROM numbers
WHERE IsEven = 1
LIMIT 20;
