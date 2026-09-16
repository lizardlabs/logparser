# From KQL to ULP SQLite

<!-- standalone-reason: A language-migration tutorial for KQL analysts, distinct from the progressive general tutorials. -->

Use this tutorial when translating a Sentinel, Defender, Azure Monitor, or Azure Data Explorer investigation into a local ULP query. ULP executes SQLite SQL, not KQL. A similar-looking query is not proof that two products expose the same data.

## Contents

- [Start with a known local sample](#start-with-a-known-local-sample)
- [Filter and select fields](#filter-and-select-fields)
- [Aggregate and filter groups](#aggregate-and-filter-groups)
- [Dates and time buckets](#dates-and-time-buckets)
- [Text and missing values](#text-and-missing-values)
- [Joins and reusable expressions](#joins-and-reusable-expressions)
- [Use Windows events carefully](#use-windows-events-carefully)
- [Translation checklist](#translation-checklist)
- [Quick reference](#quick-reference)

## Start with a known local sample

Save this SQL as `hunt.sql`. It uses ordinary in-memory SQLite tables so you can check the translation without Security-log access or a cloud account.

```sql
CREATE TABLE events(TimeCreated TEXT, EventId INTEGER, Account TEXT, MachineName TEXT);
INSERT INTO events VALUES
  ('2026-01-01 10:00:00',4625,'alice','pc1'),
  ('2026-01-01 10:05:00',4625,'alice','pc2'),
  ('2026-01-01 11:00:00',4624,'bob','pc1'),
  ('2026-01-01 11:10:00',4625,'bob','pc1');

SELECT Account, COUNT(*) AS Failures,
       COUNT(DISTINCT MachineName) AS Computers
FROM events
WHERE EventId = 4625
GROUP BY Account
HAVING COUNT(*) >= 2
ORDER BY Failures DESC, Account;
```

Run it:

```powershell
ulp --memory --no-config --query-file hunt.sql --format TextTable
```

Result:

| Account | Failures | Computers |
| --- | ---: | ---: |
| alice | 2 | 2 |

To try the following examples, replace the final `SELECT` in that file. Each invocation creates a fresh in-memory database. Save output by adding `--output file --format CSV --output-file failures.csv`; choose a new filename if you want to retain an earlier report.

## Filter and select fields

KQL reads as a sequence of operators:

```kusto
SecurityEvent
| where EventID == 4625
| project TimeGenerated, Account, Computer
| sort by TimeGenerated desc
| take 10
```

With the local sample's schema, the SQL is:

```sql
SELECT TimeCreated, Account, MachineName
FROM events
WHERE EventId = 4625
ORDER BY TimeCreated DESC
LIMIT 10;
```

Translate operators and column names separately. `TimeGenerated` is the example KQL column; `TimeCreated` is the local sample column. `LIMIT` without `ORDER BY` selects a sample, not necessarily the newest records.

## Aggregate and filter groups

```kusto
SecurityEvent
| where EventID == 4625
| summarize Failures=count(), Computers=dcount(Computer) by Account
| where Failures >= 2
| sort by Failures desc
```

The opening SQL query is the corresponding sample analysis. `WHERE` filters input rows, `GROUP BY` forms groups, and `HAVING` filters the aggregate result. Do not put `COUNT(*) >= 2` in `WHERE`.

KQL `dcount` is approximate, while SQLite `COUNT(DISTINCT ...)` is exact. They can legitimately return different counts at scale. Missing-value behavior and case comparison can also change grouping, so normalize deliberately.

## Dates and time buckets

For a rolling window, replace KQL `ago(24h)` with an explicit SQLite date expression:

```sql
SELECT * FROM events
WHERE datetime(TimeCreated) >= datetime('now', '-24 hours');
```

The fixed January sample will normally return no rows in this rolling window. Use a fixed boundary when reproducing an investigation:

```sql
SELECT strftime('%Y-%m-%d %H:00:00', TimeCreated) AS Hour,
       COUNT(*) AS Failures
FROM events
WHERE EventId = 4625
  AND datetime(TimeCreated) >= datetime('2026-01-01 00:00:00')
GROUP BY Hour
ORDER BY Hour;
```

This returns two failures in the 10:00 bucket and one in the 11:00 bucket. KQL's corresponding grouping often uses `bin(TimeGenerated, 1h)`. Keep UTC/local-time interpretation consistent before comparing results; formatting an ambiguous local timestamp does not resolve its time zone.

## Text and missing values

| KQL intent | SQLite expression | Caution |
| --- | --- | --- |
| `contains "admin"` | `Account LIKE '%admin%'` | `%` and `_` are SQL wildcards, not literal characters |
| `startswith "svc"` | `Account LIKE 'svc%'` | Check case/culture behavior |
| `endswith "svc"` | `Account LIKE '%svc'` | Leading wildcards can be expensive |
| `isnotempty(Account)` | `Account IS NOT NULL AND Account <> ''` | Whitespace is not empty |
| `isempty(Account)` | `Account IS NULL OR Account = ''` | Do not write `Account = NULL` |
| `tostring(x)` | `CAST(x AS TEXT)` | NULL and conversion rules differ |
| `toint(x)` | `CAST(x AS INTEGER)` | Invalid numeric text can become zero, not NULL |
| `strcat(a,b)` | `a \|\| b` | NULL concatenation needs explicit handling |

KQL term-based `has` is not simply SQL `LIKE`: whole-term matching has different semantics. Use a reviewed RegEx or a materialized full-text index when that distinction matters. ULP's [pattern and FTS examples](functions.md#pattern-matching) show alternatives; do not assume all pattern languages are interchangeable.

## Joins and reusable expressions

KQL `let` can define values or tabular expressions. In SQLite, use native query parameters for values and a common table expression for a named intermediate result:

```sql
WITH failures AS (
  SELECT Account, COUNT(*) AS Total
  FROM events WHERE EventId = 4625
  GROUP BY Account
)
SELECT * FROM failures WHERE Total >= @minimum ORDER BY Total DESC;
```

Pass the value with `--p.minimum 2`. ULP binds the value; it is not SQL text replacement.

A KQL `join kind=inner (...) on Key` usually becomes `INNER JOIN ... ON ...`. KQL's default join flavor is not the same as a SQL inner join, and repeated keys can multiply rows. State the intended join kind and check counts before/after.

For real CSV inputs:

```sql
CREATE VIRTUAL TABLE logins USING ParsingModule('logins.csv', '-i:CSV');
CREATE VIRTUAL TABLE identities USING ParsingModule('identities.csv', '-i:CSV');
SELECT l.Account, i.Department, COUNT(*) AS Events
FROM logins AS l
JOIN identities AS i ON i.Account = l.Account
GROUP BY l.Account, i.Department;
```

This assumes those CSV headers exist and the identity table has the cardinality you intend. Inspect the schemas first; these files are placeholders for your own exports.

## Use Windows events carefully

Open the local Security log on a Windows account authorized to read it:

```sql
CREATE VIRTUAL TABLE evt USING ParsingModule('Security', '-i:EVT');
SELECT TimeCreated, EventId, MachineName, UserAccountName, Message, Strings
FROM evt
WHERE EventId = 4625
ORDER BY TimeCreated DESC
LIMIT 20;
```

The [EVT fields reference](reference/generated/provider-EVT.md) describes the exposed schema. `UserAccountName` is associated with the event record's user identity; do **not** assume it is the failed-logon target account. For a target-account investigation, inspect the event-specific payload and extract the appropriate field. `Message` is localized and can be absent; `Strings` is event-specific rather than a universal column mapping.

Likewise, Sentinel's `IpAddress` and `LogonType`, or Defender's process telemetry, are not guaranteed columns of a raw Windows event. ULP's Processes snapshot is current local state, not a historical Defender process-events table. Export the relevant telemetry or use the appropriate event payload before translating the query.

## Translation checklist

1. Identify the original table and its collection/normalization rules.
2. Locate the equivalent local data, permissions, time range, and retention.
3. Inspect ULP's actual schema and a small sample.
4. Map fields by meaning, not just spelling.
5. Translate filtering, projections, aggregates, and joins.
6. Check NULLs, time zones, string comparison, and duplicate keys.
7. Compare a known sample and preserve the SQL with the result.

## Quick reference

| KQL | ULP SQLite |
| --- | --- |
| `where` before aggregation | `WHERE` |
| `project` | `SELECT` column list |
| `extend X = expression` | `expression AS X` in `SELECT` |
| `summarize count() by X` | `COUNT(*) ... GROUP BY X` |
| `where` after aggregation | `HAVING`, or an outer query |
| `sort by X desc` | `ORDER BY X DESC` |
| `take 10` | `LIMIT 10` |
| `top 10 by X desc` | `ORDER BY X DESC LIMIT 10` |
| `distinct X` | `SELECT DISTINCT X` |
| `join kind=inner` | `INNER JOIN ... ON ...` |

Next: [SQLite guide](sqlite-guide.md), [complete function catalog](reference/generated/sqlite-functions.md), [worked function examples](functions.md), and [task-oriented tutorials](tutorials.md).
