# SQLite basics in ULP

ULP exposes log and file providers as SQLite tables through `ParsingModule`. Most queries use standard SQLite SQL. Always inspect a provider's real schema because columns differ by provider and configuration:

```sql
CREATE VIRTUAL TABLE System USING ParsingModule('System', '-i:EVT');
PRAGMA table_info(System);
```

## Selecting and limiting rows

```sql
SELECT *
FROM System
LIMIT 20;

SELECT TimeCreated, EventId, ProviderName, Message
FROM System
LIMIT 20;
```

The EVT provider currently exposes fields such as `TimeCreated`, `EventId`, `EventTypeName`, `ProviderName`, and `Message`. Other providers have different fields.

## Filtering and sorting

```sql
SELECT TimeCreated, EventId, ProviderName, Message
FROM System
WHERE EventId = 4625
  AND Message LIKE '%logon%'
ORDER BY TimeCreated DESC;

-- Other useful predicates:
-- EventId >= 4000
-- EventId BETWEEN 4000 AND 5000
-- Message LIKE '%failed%'
```

## Aggregates

```sql
SELECT EventId, COUNT(*) AS EventCount
FROM System
GROUP BY EventId
ORDER BY EventCount DESC;

SELECT ProviderName, COUNT(*) AS ErrorCount
FROM System
WHERE EventTypeName = 'Error'
GROUP BY ProviderName
ORDER BY ErrorCount DESC;

SELECT strftime('%Y-%m-%d %H:00', TimeCreated) AS Hour, COUNT(*) AS Errors
FROM System
WHERE EventTypeName = 'Error'
GROUP BY Hour
ORDER BY Hour;
```

Timestamp conversion depends on the value returned by the provider. Inspect sample values before relying on `strftime`.

### Percentiles and median

ULP adds aggregate statistics that are useful for latency, file-size, and error-duration distributions:

| Function | Purpose |
| --- | --- |
| `PERCENTILE_CONT(value, percentile)` | Continuous percentile with linear interpolation |
| `PERCENTILE(value, percentile)` | Short alias for `PERCENTILE_CONT` |
| `PERCENTILE_DISC(value, percentile)` | Discrete nearest-rank percentile; always returns an observed value |
| `MEDIAN(value)` | Continuous 50th percentile |

The percentile may be a fraction from `0` through `1` (for example `0.95`) or a percentage greater than `1` through `100` (for example `95`). SQL `NULL` and non-numeric values are ignored. Invalid or inconsistent percentile arguments return SQL `NULL`.

```sql
SELECT ProviderName,
       COUNT(*) AS Samples,
       PERCENTILE_CONT(DurationMs, 0.50) AS P50,
       PERCENTILE_CONT(DurationMs, 0.95) AS P95,
       PERCENTILE_CONT(DurationMs, 0.99) AS P99
FROM RequestLogs
WHERE Level IN ('Error', 'Warning')
GROUP BY ProviderName;
```

Percentile aggregates retain the numeric values for each group while calculating the result. For very large datasets, filter or group the input before computing percentiles.

## Common functions

- `COUNT` counts rows; `SUM` and `AVG` calculate numeric totals and averages.
- `MIN` and `MAX` return the smallest/largest value.
- `LOWER` and `UPPER` change text case; `LENGTH` counts characters.
- `SUBSTR` extracts part of a string; `COALESCE` selects the first non-null value.
- `strftime` formats compatible date/time values.

ULP also registers Humanizer helpers:

| Function | Purpose | Example result |
| --- | --- | --- |
| `HUMANIZE_BYTES(value [, format])` | Format a byte count | `HUMANIZE_BYTES(1536)` → `1.5 KB` |
| `HUMANIZE_NUMBER(value [, culture])` | Convert an integer to words | `HUMANIZE_NUMBER(42, 'en-US')` → `forty-two` |
| `HUMANIZE_ORDINAL(value [, culture])` | Convert an integer to ordinal words | `forty-second` |
| `ORDINALIZE(value [, culture])` | Add an ordinal suffix | `42nd` |
| `HUMANIZE_TIMESPAN(seconds [, culture])` | Format a duration | `1 minute, 30 seconds` |
| `HUMANIZE_TEXT(value)` / `DEHUMANIZE_TEXT(value)` | Convert identifier and display text | `Pascal case input` / `PascalCaseInput` |
| `PLURALIZE(value)` / `SINGULARIZE(value)` | English inflection | `cats` / `cat` |
| `TO_PASCAL_CASE(value)` / `FROM_PASCAL_CASE(value)` | Convert to or humanize PascalCase | `ErrorLogEntry` / `Error log entry` |
| `TO_CAMEL_CASE(value)` / `FROM_CAMEL_CASE(value)` | Convert to or humanize camelCase | `errorLogEntry` / `Error log entry` |
| `TO_SNAKE_CASE(value)` | Convert identifiers to snake_case | `error_log_entry` |
| `TO_KEBAB_CASE(value)` | Convert identifiers to kebab-case | `error-log-entry` |
| `TO_TITLE_CASE(value)` | Convert identifiers to title text | `Error Log Entry` |
| `TO_UPPER_CASE(value [, culture])` / `TO_LOWER_CASE(value [, culture])` | Culture-aware case conversion | `LOG ENTRY` / `log entry` |

Invalid values or culture names return SQL `NULL` instead of terminating a query. Culture arguments are optional and default to the current process culture.

SQLite's built-in `UPPER` and `LOWER` remain the simplest choice for ordinary ASCII text. The ULP variants are useful when culture-aware .NET casing is required.

### Microsoft Log Parser arithmetic compatibility

ULP accepts the Microsoft Log Parser 2.2 arithmetic names directly, including the otherwise-reserved `ADD(...)` spelling:

| Functions | Purpose |
| --- | --- |
| `ADD`, `SUB`, `MUL`, `DIV`, `MOD` | Typed arithmetic; integer division truncates toward zero and 64-bit integer overflow wraps like Log Parser 2.2 |
| `BIT_AND`, `BIT_NOT`, `BIT_OR`, `BIT_XOR` | Signed 64-bit bitwise operations |
| `BIT_SHL`, `BIT_SHR` | Signed 64-bit shifts; invalid shift counts return `0` |
| `EXP`, `EXP10`, `LOG`, `LOG10` | Exponential and logarithmic operations |
| `SQR`, `SQRROOT` | Square and square-root operations |
| `QNTFLOOR_TO_DIGIT`, `QNTROUND_TO_DIGIT` | Floor or round an integer to a number of significant digits |
| `QUANTIZE` | Floor numbers or timestamps to a requested interval; timestamp intervals are seconds |

`ADD` concatenates strings, while `SUB` preserves its first string argument for Log Parser compatibility. Invalid domains and division by zero return SQL `NULL`. ISO timestamp text is accepted for timestamp arithmetic because SQLite has no dedicated timestamp storage class.

```sql
SELECT ADD(20, 22) AS Answer,
       BIT_AND(12, 10) AS CommonBits,
       QNTROUND_TO_DIGIT(12555, 2) AS Rounded,
       QUANTIZE('2026-08-27 14:37:59', 60) AS MinuteBucket;
```

### Microsoft Log Parser string and encoding compatibility

ULP also accepts the familiar Log Parser 2.2 string and hexadecimal function names:

| Functions | Purpose |
| --- | --- |
| `EXTRACT_VALUE` | Read a named value from delimiter-separated `key=value` text; the default separator is `&` |
| `INDEX_OF`, `LAST_INDEX_OF` | Find a zero-based text position; a missing value returns SQL `NULL` |
| `REPLACE_CHR`, `REPLACE_STR`, `REPLACE_IF_NOT_NULL` | Replace selected characters, text, or a non-null value |
| `STRCAT`, `STRCNT`, `STRLEN`, `STRREPEAT`, `STRREV`, `SUBSTR` | Concatenate, count, measure, repeat, reverse, or extract text |
| `ROT13`, `TO_LOWERCASE`, `TO_UPPERCASE` | Apply common text transformations |
| `HEX_TO_ASC`, `HEX_TO_PRINT`, `HEX_TO_INT` | Decode hexadecimal text |
| `HEX_TO_HEX8`, `HEX_TO_HEX16`, `HEX_TO_HEX32`, `TO_HEX` | Format byte groups or convert values to hexadecimal text |
| `URLESCAPE`, `URLUNESCAPE` | Escape or decode URL text, with an optional Windows code-page number |

String positions use the Log Parser zero-based convention. `EXTRACT_VALUE` is case-sensitive and returns the first matching key. The hexadecimal grouping functions accept an optional nonzero `bigEndian` argument where supported.

```sql
SELECT EXTRACT_VALUE('level=error&code=500', 'code') AS Code,
       INDEX_OF('request failed', 'failed') AS Position,
       HEX_TO_ASC('4552524F52') AS Word,
       TO_HEX('ULP') AS Encoded;
```

### Microsoft Log Parser conversions and system helpers

| Functions | Purpose |
| --- | --- |
| `TO_INT`, `TO_REAL`, `TO_STRING` | Convert numbers, timestamp values, and supported text representations |
| `TO_DATE`, `TO_TIME` | Extract the date or time portion of a timestamp |
| `TO_TIMESTAMP` | Build a timestamp from seconds, parse formatted text, or combine date and time values |
| `TO_LOCALTIME`, `TO_UTCTIME` | Convert between UTC and the computer's local timezone |
| `SYSTEM_DATE`, `SYSTEM_TIME`, `SYSTEM_TIMESTAMP`, `SYSTEM_UTCOFFSET` | Read the current local clock and UTC offset |
| `COMPUTER_NAME` | Return the current computer name |
| `IPV4_TO_INT`, `INT_TO_IPV4` | Convert IPv4 addresses and their unsigned 32-bit numeric form |
| `HASHMD5_FILE` | Calculate the uppercase MD5 digest of a file for compatibility with existing queries |
| `RESOLVE_SID` | Resolve a Windows security identifier; unresolved values are preserved |
| `REVERSEDNS` | Perform a reverse DNS lookup; failed lookups preserve the supplied address |
| `WIN32_ERROR_DESCRIPTION` | Return the Windows description for a numeric error code |

Reverse DNS and SID resolution wait for at most two seconds per uncached value and cache a bounded set of results. They can still depend on local DNS, domain connectivity, and permissions. SID resolution and Windows error messages are platform-limited. `HASHMD5_FILE` is included for compatibility; prefer `FILE_HASH(path, 'SHA256')` for new integrity checks.

```sql
SELECT TO_TIMESTAMP('2026-08-28 14:30:00', 'yyyy-MM-dd hh:mm:ss') AS Parsed,
       IPV4_TO_INT('127.0.0.1') AS Loopback,
       COMPUTER_NAME() AS Computer;
```

### SQLite-native equivalents

Some Log Parser expressions already have a direct SQLite form and need no ULP-specific alias:

| Log Parser concept | SQLite form |
| --- | --- |
| Conditional result | `CASE WHEN condition THEN value ELSE other END` |
| First non-null value | `COALESCE(value1, value2, ...)` |
| Round down / round | `FLOOR(value)` / `ROUND(value [, digits])` |
| Trim left / right / both | `LTRIM(value)` / `RTRIM(value)` / `TRIM(value)` |

SQLite's dynamic typing can coerce values differently from Microsoft Log Parser. Use the `TO_INT`, `TO_REAL`, and `TO_STRING` compatibility functions when matching an existing Log Parser query depends on its conversion rules.

### Date and time helpers

| Function | Purpose |
| --- | --- |
| `DT_FROM_UNIX_SECONDS(value)` / `DT_TO_UNIX_SECONDS(value)` | Convert between Unix seconds and an ISO-8601 timestamp |
| `DT_FROM_UNIX_MILLISECONDS(value)` / `DT_TO_UNIX_MILLISECONDS(value)` | Convert between Unix milliseconds and an ISO-8601 timestamp |
| `DT_TO_UTC(value [, source_timezone])` | Normalize an instant or a source-zone wall time to UTC |
| `DT_FROM_UTC(value, destination_timezone)` | Convert a UTC instant to another timezone |
| `DT_CONVERT_TIMEZONE(value, source_timezone, destination_timezone)` | Convert a wall time between timezones |
| `DT_DAY_OF_WEEK(value [, culture])` | Return the localized weekday name |
| `DT_IS_WEEKEND(value)` | Return `1` for Saturday/Sunday, otherwise `0` |
| `DT_ISO_WEEK(value)` | Return the ISO-8601 week number |

Timezone arguments accept `UTC`, `Z`, fixed offsets such as `+02:00` or `UTC-05:00`, and timezone IDs installed on the operating system. Returned converted timestamps include their UTC offset. Invalid timestamps, timezone IDs, and wall times in daylight-saving gaps return SQL `NULL`.

```sql
SELECT DT_TO_UTC('2026-08-25 10:30:00', '+02:00'),
       DT_FROM_UNIX_MILLISECONDS(1770000000000),
       DT_DAY_OF_WEEK('2026-08-25', 'en-US');
```

### File and path helpers

| Function | Purpose |
| --- | --- |
| `FILE_EXISTS(path)` / `DIRECTORY_EXISTS(path)` | Test filesystem existence and return `1` or `0` |
| `FILE_SIZE(path)` | Return a file size in bytes |
| `FILE_HASH(path [, algorithm])` | Hash a file; defaults to SHA-256 and supports MD5, SHA-1, SHA-256, SHA-384, and SHA-512 |
| `FILE_HASH_SHA256(path)` | Explicit SHA-256 convenience function |
| `TO_ABSOLUTE_PATH(path)` | Resolve a relative path |
| `EXTRACT_PATH`, `EXTRACT_FILENAME`, `EXTRACT_EXTENSION` | Split a path into common parts |
| `PATH_COMBINE`, `PATH_CHANGE_EXTENSION`, `PATH_IS_ROOTED` | Build or inspect paths |
| `READ_TEXT_LINES(path [, count [, skip [, max_bytes]]])` | Read a bounded portion of a text file |

Filesystem helpers operate with the permissions of the ULP process. Missing or unreadable files return SQL `NULL` where a value cannot be produced.
Use SHA-256 or stronger when integrity matters; MD5 and SHA-1 are provided only for compatibility with existing checksums.

Run `ulp --list-functions` or use the connection diagnostics to see the function name, arity, type, and compatibility status. Status values distinguish direct Log Parser compatibility, platform-limited compatibility, SQLite equivalents, ULP extensions, and planned stateful functions. Availability can differ by build.

### Moving a Log Parser query to ULP

Most compatible scalar expressions can be kept unchanged. Replace the Log Parser input clause with a ULP virtual table, then query that table with SQLite syntax:

```sql
CREATE VIRTUAL TABLE Events USING ParsingModule('System', '-i:EVT');

SELECT TO_UPPERCASE(ProviderName) AS Provider,
       COUNT(*) AS EventCount
FROM Events
WHERE INDEX_OF(Message, 'failed') IS NOT NULL
GROUP BY TO_UPPERCASE(ProviderName)
ORDER BY EventCount DESC;
```

Use `LIMIT` instead of `TOP`, SQLite `CASE WHEN ... END` for conditional expressions, and `||` or `STRCAT` for text concatenation. Check `ulp --list-functions` before moving a query that depends on platform-limited or planned functions.

## Query error locations

ULP reports a SQLite error with a one-based SQL line and column plus the source line and a caret when the provider supplies an error offset. The bundled modified `System.Data.SQLite` 1.0.113 exception API does not expose SQLite's native error-offset value. For native messages that identify a token (for example, `near "SELECT"`), ULP locates that token in the submitted SQL and explicitly labels the location **approximate**. If SQLite reports neither an offset nor a token, ULP preserves the original message rather than inventing a position.

## Views and materialized tables

A view stores a query definition without copying its rows:

```sql
CREATE VIEW RecentErrors AS
SELECT * FROM System
WHERE EventTypeName = 'Error';
```

For a stable copy—especially when a ParsingModule source is forward-only—materialize it:

```sql
CREATE TEMP TABLE SystemSnapshot AS SELECT * FROM System;
```

## Parsing an ISO-style text log

For records such as:

```text
2026-08-18T14:22:10Z ERROR Authentication failed
2026-08-18T14:22:14Z INFO User logged in
```

use ULP's `RegEx` provider and its real `RegularExpression` property. Named regular-expression groups become fields:

```powershell
ulp --input RegEx --table Logs --from 'C:\Logs\*.log' `
  --i.RegEx.RegularExpression '^(?<Timestamp>\S+)\s+(?<Level>\w+)\s+(?<Message>.*)$' `
  --query 'SELECT Level, COUNT(*) AS Entries FROM Logs GROUP BY Level' --output console --format Terminal
```

For simple searching without parsing fields, `TextLine` supports file patterns:

```powershell
ulp --input TextLine --table Logs --from 'C:\Logs\*.log' `
  --query 'SELECT FileName, Text FROM Logs WHERE Text LIKE ''%timeout%'' LIMIT 100' --output console --format Terminal
```

Enable the provider's extended fields if `FileName` is not present in the selected TextLine configuration. Check the generated provider reference or `PRAGMA table_info(Logs)` rather than assuming a field exists.

## Inspection and further learning

Shell shortcuts include `.t`/`.tables`, `.s`/`.schema`, and `.i`/`.info`. Foreign keys are optional; inspect declared relationships with `PRAGMA foreign_key_list(table_name)`. Use `EXPLAIN QUERY PLAN <select>` to inspect a plan.

ULP follows SQLite semantics for most SQL. See the [official SQLite language documentation](https://sqlite.org/lang.html) and [built-in function reference](https://sqlite.org/lang_corefunc.html).
