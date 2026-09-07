-- ULP automatically loads config\defaults.input.EVT.config.
-- Generate it with: ulp --generate-input-config EVT
DROP TABLE IF EXISTS [configured_events];
CREATE VIRTUAL TABLE [configured_events]
USING ParsingModule('System', '-i:EVT');

SELECT * FROM [configured_events] LIMIT 100;
