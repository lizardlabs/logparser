# Migrating a Log Parser workflow to ULP

This focused migration note is for users who already have Microsoft Log Parser queries. ULP is an independent product; it is not affiliated with or endorsed by Microsoft and is not a command-for-command replacement.

The goal is practical continuity: keep the approachable “input → query → output” workflow while using SQLite, adding modern data formats, reusable query recipes, several user interfaces, automation controls, and integrations that were not part of the original tool.

## What remains familiar

The core mental model is intentionally recognizable:

1. select an input format and a source;
2. expose records as a table;
3. filter, group, sort, join, and aggregate with SQL;
4. display the result or write it in another format.

For example, a Microsoft Log Parser user might recognize the purpose of an event-log query such as “count recent errors by source.” In ULP, the equivalent uses a ParsingModule virtual table and SQLite SQL:

```sql
CREATE VIRTUAL TABLE events
USING ParsingModule('System', '-i:EVT');

SELECT SourceName,
       COUNT(*) AS ErrorCount
FROM events
WHERE EventTypeName = 'Error'
GROUP BY SourceName
ORDER BY ErrorCount DESC
LIMIT 20;
```

Save repeatable queries in the Query library, or place connection-local setup in an explicit session SQL file:

```powershell
ulp --session-init-file session-sql\event-logs.sql `
    --query "SELECT SourceName, COUNT(*) AS Errors FROM tEvt1 WHERE EventTypeName='Error' GROUP BY SourceName ORDER BY Errors DESC LIMIT 20" `
    --output console --format Terminal
```

## Important differences

ULP uses SQLite rather than the Microsoft Log Parser SQL dialect. That brings SQLite joins, common table expressions, window functions, JSON features, named parameters, and a large function catalog, but it also means syntax and type behavior are not identical.

Other important differences include:

- input providers are exposed through `ParsingModule` virtual tables;
- streaming inputs may need materialization before a plan rescans them;
- output destination and output format are separate choices;
- named parameters are bound by SQLite rather than replaced as strings;
- multiple output pipelines can receive the same result;
- saved queries, session lifecycle SQL, checkpoints, TUI, web, and MCP workflows extend the original model;
- compatibility functions cover useful Microsoft Log Parser names, but unsupported functions must use documented SQLite or ULP alternatives.

Always test an existing Log Parser query instead of assuming it can be pasted unchanged. Start with a small `LIMIT`, inspect the actual schema, and compare representative results before automating a migration.

## A gradual migration approach

For each existing workflow:

1. identify the original input format, source, fields, filters, grouping, and output;
2. select the closest ULP provider with `ulp --list-providers` and inspect it with `ulp --help-provider NAME`;
3. run a bounded sample and confirm field names and types;
4. translate the query to SQLite syntax;
5. check compatible and extended functions with `ulp --list-functions`;
6. choose a destination and writer explicitly;
7. compare output against a known input fixture;
8. save the reviewed result as a Query library recipe or automation configuration.

Materialize a stream when a join, subquery, window, or repeated scan needs stable rows:

```sql
CREATE TEMP TABLE event_snapshot AS
SELECT * FROM tEvt1;

SELECT SourceName,
       EventTypeName,
       COUNT(*) AS Events
FROM event_snapshot
GROUP BY SourceName, EventTypeName
ORDER BY Events DESC;
```

## Where compatibility intentionally stops

ULP should not preserve behavior that is unsafe, ambiguous, or tightly coupled to an obsolete runtime merely for superficial compatibility. Unsupported syntax should fail with an actionable message. A compatibility name should not be documented as implemented until the runtime reports and tests it.

The project also avoids silently creating expensive event, filesystem, or generated-data tables. Optional examples now live under `session-sql` and run only when selected with `--session-init-file`.

## Validate the migrated workflow

Run the old and new query against the same small, non-sensitive fixture. Compare row counts, null handling, timestamps, numeric conversions, grouping, sorting, and output encoding. Only replace an automated job after its expected result is recorded and the ULP command returns the expected exit status.
