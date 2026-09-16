# SQLite Guide for ULP Users

ULP uses SQLite to query provider records. This chapter teaches the SQLite features most useful for log, event, file, and structured-data analysis. Examples assume that ULP has already exposed the source as a table through a CLI source block or a ParsingModule declaration.

## Contents

- [Introduction](#introduction)
- [SELECT](#select)
- [Columns and Aliases](#columns-and-aliases)
- [WHERE](#where)
- [ORDER BY](#order-by)
- [LIMIT](#limit)
- [DISTINCT](#distinct)
- [GROUP BY](#group-by)
- [HAVING](#having)
- [Aggregate Queries](#aggregate-queries)
- [CASE](#case)
- [CAST and Type Conversion](#cast-and-type-conversion)
- [Working With Text](#working-with-text)
- [Working With Numbers](#working-with-numbers)
- [Dates and Times](#dates-and-times)
- [NULL Handling](#null-handling)
- [Joins](#joins)
- [Subqueries](#subqueries)
- [Common Table Expressions](#common-table-expressions)
- [Window Functions](#window-functions)
- [JSON](#json)
- [Query Patterns for Log Analysis](#query-patterns-for-log-analysis)
- [SQLite Features Not Available in ULP](#sqlite-features-not-available-in-ulp)
- [Related Function Reference](#related-function-reference)

## Introduction

Coming from KQL? Use the [KQL-to-ULP query translation tutorial](kql-vs-ulp-sqlite-tutorial.md). For exact availability and overloads, see the [complete SQL function catalog](reference/generated/sqlite-functions.md); the [function guide](functions.md) adds worked examples.

SQLite is an embedded relational database engine. In ULP it has two roles:

1. it provides the SQL language and query planner;
2. it hosts ordinary tables, views, temporary objects, and ParsingModule virtual tables.

A CLI source block creates a virtual table before the query:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees LIMIT 10"
```

The equivalent explicit SQL is:

```sql
CREATE VIRTUAL TABLE employees
USING ParsingModule('samples\data\employees.csv', '-i:CSV');

SELECT *
FROM employees
LIMIT 10;
```

ParsingModule sources can be forward-only streams. A simple query reads them once. Materialize a source before joins, windows, correlated subqueries, or another plan that may scan it repeatedly:

```sql
CREATE TEMP TABLE employees_data AS
SELECT * FROM employees;
```

Temporary tables live for the SQLite connection. A persistent database can retain ordinary tables between runs, while ParsingModule virtual tables should be recreated for a new process/session.

Inspect the active runtime rather than assuming a system SQLite installation:

```powershell
ulp --sqlite-info
ulp --list-functions
ulp --list-tables
ulp --list-columns employees
```

## SELECT

`SELECT` describes the result columns and rows:

```sql
SELECT employee_name,
       salary
FROM employees;
```

`SELECT *` is useful for first inspection but is less suitable for durable exports because a provider schema can be wide:

```sql
SELECT *
FROM employees
LIMIT 5;
```

Expressions can calculate new values:

```sql
SELECT employee_name,
       CAST(salary AS INTEGER) / 1000.0 AS salary_thousands
FROM employees;
```

Use a semicolon to end a statement. Query files can contain several statements and return several result sets.

## Columns and Aliases

Use `AS` to name a result expression:

```sql
SELECT employee_name AS Name,
       CAST(salary AS INTEGER) AS Salary
FROM employees;
```

ULP avoids quoting ordinary identifiers when it generates SQL. Quote an identifier only when required by spaces, punctuation, a reserved word, or unusual characters:

```sql
SELECT [Event ID],
       [Time Created]
FROM [Windows Events];
```

Do not quote a string value as an identifier. String literals use single quotes:

```sql
WHERE EventTypeName = 'Error'
```

Inspect actual names before composing SQL:

```sql
PRAGMA table_info(employees);
```

## WHERE

`WHERE` filters input rows before grouping and result projection:

```sql
SELECT *
FROM employees
WHERE lower(active) = 'true';
```

### Comparison Operators

| Operator | Meaning |
| --- | --- |
| `=` | equal |
| `<>` or `!=` | not equal |
| `<`, `<=` | less than, less than or equal |
| `>`, `>=` | greater than, greater than or equal |
| `IS`, `IS NOT` | null-safe identity comparisons |

CSV/text fields may require a cast for numeric comparison:

```sql
WHERE CAST(status AS INTEGER) >= 400
```

### LIKE

`LIKE` uses `%` for any sequence and `_` for one character:

```sql
WHERE Message LIKE '%timeout%'
```

Normalize case when required:

```sql
WHERE lower(Message) LIKE '%timeout%'
```

### IN

```sql
WHERE EventTypeName IN ('Warning', 'Error')
```

`NOT IN` can behave unexpectedly if its list/subquery contains null. `NOT EXISTS` is often safer for nullable data.

### BETWEEN

`BETWEEN` includes both ends:

```sql
WHERE CAST(salary AS INTEGER) BETWEEN 100000 AND 125000
```

For timestamps, an exclusive upper bound is usually clearer:

```sql
WHERE TimeCreated >= '2026-08-01'
  AND TimeCreated <  '2026-09-01'
```

### NULL

```sql
WHERE Message IS NULL
WHERE Message IS NOT NULL
```

Do not use `= NULL`.

### AND, OR, and NOT

```sql
WHERE EventTypeName = 'Error'
  AND (SourceName = 'ServiceA' OR SourceName = 'ServiceB')
  AND NOT Message LIKE '%expected test%'
```

Use parentheses when combining `AND` and `OR` so the intended precedence is visible.

## ORDER BY

```sql
SELECT TimeCreated, SourceName, Message
FROM events
ORDER BY TimeCreated DESC
LIMIT 100;
```

Use several expressions for deterministic ties:

```sql
ORDER BY EventCount DESC, SourceName COLLATE NOCASE
```

UI sorting changes only the displayed grid/table. Put `ORDER BY` in SQL when an export or saved query needs stable order.

## LIMIT

```sql
LIMIT 100
```

Skip rows with `OFFSET`:

```sql
LIMIT 100 OFFSET 200
```

`LIMIT` bounds returned rows, but it does not guarantee that an aggregate, sort, join, or window plan reads only that many source rows. Filter early and avoid expensive recursive providers while exploring.

## DISTINCT

```sql
SELECT DISTINCT SourceName
FROM events
ORDER BY SourceName;
```

`DISTINCT` applies to the complete selected row. To count unique values:

```sql
SELECT COUNT(DISTINCT SourceName) AS unique_sources
FROM events;
```

## GROUP BY

```sql
SELECT EventTypeName,
       COUNT(*) AS EventCount
FROM events
GROUP BY EventTypeName
ORDER BY EventCount DESC;
```

Every result expression should either describe the group or use an aggregate. Do not rely on SQLite returning an arbitrary ungrouped value.

Group into calculated buckets:

```sql
SELECT CASE
           WHEN CAST(status AS INTEGER) >= 500 THEN 'server error'
           WHEN CAST(status AS INTEGER) >= 400 THEN 'client error'
           ELSE 'other'
       END AS status_class,
       COUNT(*) AS requests
FROM requests
GROUP BY status_class;
```

## HAVING

`WHERE` filters input rows. `HAVING` filters completed groups:

```sql
SELECT SourceName,
       COUNT(*) AS EventCount
FROM events
WHERE EventTypeName IN ('Warning', 'Error')
GROUP BY SourceName
HAVING COUNT(*) >= 10
ORDER BY EventCount DESC;
```

## Aggregate Queries

Common aggregates include:

```sql
SELECT COUNT(*) AS samples,
       MIN(DurationMs) AS minimum_ms,
       ROUND(AVG(DurationMs), 2) AS average_ms,
       SUM(BytesSent) AS total_bytes,
       MAX(DurationMs) AS maximum_ms
FROM requests;
```

ULP adds aggregates such as median and continuous/discrete percentiles:

```sql
SELECT MEDIAN(DurationMs) AS median_ms,
       PERCENTILE_CONT(DurationMs, 0.95) AS p95_ms,
       PERCENTILE_DISC(DurationMs, 0.99) AS p99_observed_ms
FROM requests;
```

Use percentiles only for ordered numeric measurements, not categorical labels.

`COUNT(*)` counts rows. `COUNT(column)` counts non-null values in that column.

## CASE

Use `CASE` for classification and conditional aggregates:

```sql
SELECT SUM(
           CASE WHEN CAST(status AS INTEGER) >= 400
                THEN 1 ELSE 0 END
       ) AS failed_requests
FROM requests;
```

```sql
SELECT CASE EventTypeName
           WHEN 'Error' THEN 3
           WHEN 'Warning' THEN 2
           ELSE 1
       END AS SeverityRank,
       COUNT(*) AS events
FROM events
GROUP BY SeverityRank;
```

## CAST and Type Conversion

SQLite uses dynamic typing. Provider values can arrive as text, integer, real, blob, or null.

```sql
CAST(value AS INTEGER)
CAST(value AS REAL)
CAST(value AS TEXT)
```

ULP also supplies conversions such as `TO_INT`, `TO_REAL`, `TO_STRING`, and timestamp helpers. Use the form that makes the intended type and null behavior clear.

Test malformed data instead of assuming every value converts cleanly. A cast of unsuitable text can yield a value such as zero under SQLite coercion rules; validate source shape when zero is meaningful.

## Working With Text

Common SQLite functions:

```sql
SELECT lower(Name),
       upper(Level),
       trim(Message),
       length(Message),
       substr(Message, 1, 80),
       replace(Message, 'secret', '[redacted]')
FROM records;
```

Concatenate with `||`:

```sql
SELECT SourceName || ': ' || Message AS summary
FROM events;
```

Use `COALESCE` when a null would nullify concatenation:

```sql
SELECT coalesce(SourceName, '(unknown)') || ': ' || coalesce(Message, '')
FROM events;
```

ULP adds casing helpers (Pascal, camel, snake, kebab, title, sentence and related variants), extraction, hexadecimal, URL, and Humanizer-based display helpers. See the function catalog for exact names and arguments.

## Working With Numbers

```sql
SELECT ROUND(AVG(DurationMs), 2) AS average_ms,
       ABS(MIN(Delta)) AS absolute_minimum,
       CAST(Bytes AS REAL) / 1024 / 1024 AS megabytes
FROM records;
```

Avoid integer division when a fractional result is required. Multiplying by `1.0` or casting one operand to `REAL` makes the intent explicit:

```sql
100.0 * failed / NULLIF(total, 0)
```

ULP includes mathematical, bitwise, quantization, and percentile functions. Inspect actual availability with `ulp --list-functions`.

## Dates and Times

SQLite date/time functions operate well with ISO-8601 text:

```sql
SELECT date(TimeCreated) AS event_date,
       strftime('%H', TimeCreated) AS event_hour,
       COUNT(*) AS events
FROM events
GROUP BY event_date, event_hour;
```

Relative UTC time:

```sql
WHERE datetime(TimeCreated) >= datetime('now', '-24 hours')
```

ULP helpers convert Unix seconds/milliseconds, UTC, installed timezones, weekday names, weekend flags, and ISO week numbers. Invalid timestamps, unknown zones, and wall times inside daylight-saving gaps can return null.

Keep timezone assumptions visible in a saved query. Do not mix local and UTC timestamps without conversion.

## NULL Handling

`NULL` means missing or unknown, not an empty string and not zero.

```sql
COALESCE(Message, '(missing)')
NULLIF(total, 0)
```

Find empty and missing text:

```sql
WHERE Message IS NULL
   OR trim(Message) = ''
```

Most scalar expressions involving null produce null. Aggregates generally ignore null input values except that `COUNT(*)` counts the row.

## Joins

Join ordinary/materialized tables:

```sql
SELECT e.employee_name,
       d.department_name,
       CAST(e.salary AS INTEGER) AS salary
FROM employees_data AS e
JOIN departments_data AS d
  ON CAST(e.department_id AS INTEGER) = CAST(d.department_id AS INTEGER)
ORDER BY d.department_name, salary DESC;
```

Use `LEFT JOIN` when every left-side row must remain even without a match:

```sql
SELECT e.employee_name,
       coalesce(d.department_name, '(unknown)') AS department_name
FROM employees_data AS e
LEFT JOIN departments_data AS d
  ON e.department_id = d.department_id;
```

Materialize streaming provider tables first. The checked-in `samples/parsingmodule/05-csv-join-and-window.sql` is an executable example.

## Subqueries

Compare with a scalar aggregate:

```sql
SELECT employee_name,
       CAST(salary AS INTEGER) AS salary
FROM employees_data
WHERE CAST(salary AS INTEGER) > (
    SELECT AVG(CAST(salary AS REAL))
    FROM employees_data
);
```

Use `EXISTS` for membership tests:

```sql
SELECT d.department_name
FROM departments_data AS d
WHERE EXISTS (
    SELECT 1
    FROM employees_data AS e
    WHERE e.department_id = d.department_id
);
```

Do not repeatedly scan an unmaterialized forward-only source inside a correlated subquery.

## Common Table Expressions

A CTE names part of a query:

```sql
WITH error_events AS
(
    SELECT *
    FROM events_snapshot
    WHERE EventTypeName = 'Error'
)
SELECT SourceName,
       COUNT(*) AS errors
FROM error_events
GROUP BY SourceName
ORDER BY errors DESC;
```

Recursive CTEs can generate ranges or traverse hierarchy:

```sql
WITH RECURSIVE numbers(value) AS
(
    SELECT 1
    UNION ALL
    SELECT value + 1
    FROM numbers
    WHERE value < 10
)
SELECT value FROM numbers;
```

Use a safe termination condition.

## Window Functions

Window functions calculate across related rows without collapsing them:

```sql
SELECT employee_name,
       department_name,
       salary,
       DENSE_RANK() OVER
       (
           PARTITION BY department_name
           ORDER BY salary DESC
       ) AS salary_rank
FROM employee_departments;
```

Running totals:

```sql
SELECT TimeCreated,
       Bytes,
       SUM(Bytes) OVER
       (
           ORDER BY TimeCreated
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_bytes
FROM requests;
```

Window plans commonly rescan/sort input, so materialize provider streams first.

## JSON

Use the JSON input provider to turn a JSON document into rows. Use SQLite JSON functions when a column contains JSON:

```sql
SELECT json_extract(Payload, '$.request.id') AS request_id,
       json_extract(Payload, '$.duration_ms') AS duration_ms
FROM events
WHERE json_valid(Payload);
```

Expand arrays:

```sql
SELECT e.Id,
       item.value AS tag
FROM events AS e,
     json_each(e.Payload, '$.tags') AS item
WHERE json_valid(e.Payload);
```

Check the active SQLite build with `ulp --list-functions`; optional JSON behavior depends on the shipped runtime, not a separately installed `sqlite3.exe`.

## Query Patterns for Log Analysis

### Errors over time

```sql
SELECT strftime('%Y-%m-%d %H:00', TimeCreated) AS hour,
       COUNT(*) AS errors
FROM events_snapshot
WHERE EventTypeName = 'Error'
GROUP BY hour
ORDER BY hour;
```

### Top sources

```sql
SELECT SourceName,
       COUNT(*) AS events,
       MAX(TimeCreated) AS most_recent
FROM events_snapshot
GROUP BY SourceName
ORDER BY events DESC, most_recent DESC
LIMIT 20;
```

### Error percentage

```sql
SELECT COUNT(*) AS total,
       SUM(CASE WHEN CAST(status AS INTEGER) >= 400 THEN 1 ELSE 0 END) AS failed,
       ROUND(
           100.0 * SUM(CASE WHEN CAST(status AS INTEGER) >= 400 THEN 1 ELSE 0 END)
           / NULLIF(COUNT(*), 0),
           2
       ) AS failure_percent
FROM requests;
```

### Inter-event intervals

```sql
WITH ordered AS
(
    SELECT TimeCreated,
           LAG(TimeCreated) OVER (ORDER BY TimeCreated) AS previous_time
    FROM events_snapshot
)
SELECT AVG(
           unixepoch(TimeCreated) - unixepoch(previous_time)
       ) AS average_seconds
FROM ordered
WHERE previous_time IS NOT NULL;
```

The installed Query library includes event, file, text, generated-data, system, and source-code patterns that can be inspected before execution.

## SQLite Features Not Available in ULP

ULP is not the standalone SQLite command-line program. Keep these distinctions in mind:

- `sqlite3` dot commands are not automatically ULP shell commands. Use the commands listed by `.help` in the ULP SQL/Web Shell.
- ParsingModule virtual tables represent provider streams and are generally read-only; do not expect `UPDATE`/`DELETE` to modify a source file, event channel, archive, or remote provider.
- A streaming virtual table may not support arbitrary rescans; materialize it for multi-pass plans.
- Optional SQLite modules/functions depend on the library shipped with ULP. Check `--sqlite-info` and `--list-functions` instead of assuming a feature from another SQLite installation.
- Dynamic extension loading should not be assumed or used as a deployment mechanism. ULP registers its supported extensions deliberately.
- Browser, query-runner, and MCP permission modes can restrict ad-hoc SQL or data-changing operations even when SQLite itself understands the syntax.
- ULP parameter bindings represent values, not table names, column names, keywords, or raw SQL fragments.

For a persistent SQLite database, use `--database`/`--db` or `ingest`. Back up important databases and understand SQLite locking/journal behavior before concurrent automation.

## Related Function Reference

- Run `ulp --list-functions` for the current runtime inventory and compatibility status.
- Use `ulp --help sqlite` for terminal-rendered SQLite/ParsingModule help.
- Use the complete [SQL Function Reference](functions.md) for categorized runtime functions and examples.
- See [How-To Guide](how-to.md) for task recipes.
- See [ULP Tutorials](tutorials.md) for progressive examples.
- See [Input providers and writers](inputs-and-outputs.md) for generated schemas and properties.
