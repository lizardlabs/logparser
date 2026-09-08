# SQL function reference

Use this page to choose a function by task. Examples use SQLite expressions: prepend `SELECT` and append `;` unless the example is already a complete query. For example, run `ulp --query "SELECT HUMANIZE_BYTES(1536) AS size" --format TextTable`.

## Contents

- [About this reference](#about-this-reference)
- [Function quick index](#function-quick-index)
- [Core and scalar functions](#core-and-scalar-functions)
- [Text functions](#text-functions)
- [Numeric and math functions](#numeric-and-math-functions)
- [Date and time functions](#date-and-time-functions)
- [Aggregate functions](#aggregate-functions)
- [Window functions](#window-functions)
- [JSON functions](#json-functions)
- [NULL and conditional functions](#null-and-conditional-functions)
- [Pattern matching](#pattern-matching)
- [Blob and binary functions](#blob-and-binary-functions)
- [File and system functions](#file-and-system-functions)
- [Query counters and compatibility names](#query-counters-and-compatibility-names)
- [Extension functions and runtime discovery](#extension-functions-and-runtime-discovery)
  - [Exact decimal arithmetic](#exact-decimal-arithmetic)
  - [Inspect floating-point values](#inspect-floating-point-values)
  - [Normalize and store UUIDs](#normalize-and-store-uuids)
  - [Search a materialized full-text index](#search-a-materialized-full-text-index)
  - [Find similar words](#find-similar-words)
  - [Generate bounded series](#generate-bounded-series)
- [Detailed examples](#detailed-examples)

## About this reference

The executable is authoritative. Find its version with `ulp --version`, its SQLite version with `SELECT sqlite_version()`, and its installed function names and arities with `ulp --list-functions`. The [generated inventory](reference/generated/sqlite-functions.json) records the SQLite version and generation method for the accompanying package. It is derived from the running ULP catalog and `PRAGMA function_list`, not from a newer SQLite website.

This readable chapter explains frequently used functions and ULP additions. The inventory additionally lists specialized extension and diagnostic functions; it is not a promise that every listed function is appropriate for ordinary queries. An arity of `-1` means a variable number of arguments. Names are case-insensitive. The tables group closely related functions to avoid repeating the same explanation for each overload.

Examples containing `value`, `text`, or `path` as unquoted identifiers refer to your own columns. Literal examples can run without an input table. Optional arguments are shown in square brackets in signatures only; do not type those brackets in SQL. Most scalar functions propagate NULL, but conversion/error behavior differs between function families: test malformed values before processing a whole dataset.

**Safety:** not all SELECT expressions are read-only. File, network, process, extension-loading, and dynamic-SQL functions can have effects outside the result table. Execute only trusted SQL with an account limited to the intended files. MCP sessions are not security sandboxes. Masking output is not a substitute for excluding sensitive data from a query or an AI request.

## Function quick index

| Task | Start with |
| --- | --- |
| Search within a value | `instr`, `LIKE`, `RX_IS_MATCH` |
| Clean and normalize text | `trim`, `replace`, `TO_SNAKE_CASE` |
| Display sizes and durations | `HUMANIZE_BYTES`, `HUMANIZE_TIMESPAN` |
| Count, sum, average | `count`, `sum`, `avg` |
| Investigate tail latency | `MEDIAN`, `PERCENTILE_CONT`, `PERCENTILE_DISC` |
| Rank within a group | `row_number`, `rank`, `dense_rank` with `OVER` |
| Convert timestamps | `datetime`, `strftime`, `DT_TO_UTC`, `DT_FROM_UNIX_SECONDS` |
| Extract JSON properties | `json_extract`, `json_type`, `json_valid` |
| Handle absent values | `coalesce`, `ifnull`, `nullif`, `CASE` |
| Check files | `FILE_EXISTS`, `FILE_SIZE`, `FILE_HASH_SHA256` |
| Discover installed functionality | `pragma_function_list`, `pragma_module_list` |

## Core and scalar functions

| Function and arguments | Returns | Description | Example |
| --- | --- | --- | --- |
| `length(value)` | Integer | Characters in text, bytes in a BLOB; NULL for NULL. | `length('error')` → `5` |
| `typeof(value)` | Text | SQLite storage class: null, integer, real, text, or blob. | `typeof(42)` → `integer` |
| `quote(value)` | Text | SQL literal representation of a value; useful for inspection, not a replacement for binding parameters. | `quote('O''Brien')` |
| `hex(value)` | Text | Hexadecimal representation of the value's bytes. | `hex('AB')` → `4142` |
| `unicode(text)` | Integer | Code point of the first character. | `unicode('A')` → `65` |
| `char(n, ...)` | Text | Build text from Unicode code points. | `char(65,66)` → `AB` |
| `sqlite_version()` | Text | Version of the SQLite runtime actually loaded. | `sqlite_version()` |
| `sqlite_source_id()` | Text | SQLite source/build identifier. | `sqlite_source_id()` |
| `changes()` | Integer | Rows changed by the most recent applicable data-changing statement. | `changes()` |
| `total_changes()` | Integer | Accumulated changes on this connection. | `total_changes()` |
| `last_insert_rowid()` | Integer | Most recent successful rowid insertion on this connection. | `last_insert_rowid()` |

`CAST(value AS type)` and `CASE` are SQL syntax, not registered functions. A cast does not validate the entire input: `CAST('invalid' AS INTEGER)` returns zero in SQLite. See the [SQLite guide](sqlite-guide.md).

## Text functions

| Function and arguments | Returns | Description | Example |
| --- | --- | --- | --- |
| `lower(text)`, `upper(text)` | Text | SQLite's ordinary ASCII case conversion. Use ULP culture-aware functions when needed. | `upper('error')` → `ERROR` |
| `trim(text[, chars])` | Text | Remove edge characters; default is spaces. `chars` is a set, not a substring. | `trim('..warn..', '.')` → `warn` |
| `ltrim`, `rtrim` | Text | Trim only the left or right edge. | `ltrim('  ok')` → `ok` |
| `replace(text, find, replacement)` | Text | Replace matching substrings. | `replace('a/b', '/', '-')` → `a-b` |
| `instr(text, find)` | Integer | One-based position of the first occurrence, or zero. | `instr('worker', 'k')` → `4` |
| `printf(format, ...)` | Text | Format values using SQLite format specifiers. | `printf('%.2f', 3.14159)` → `3.14` |
| `substr(text, start[, length])` | Text | Slice text. ULP retains compatibility overloads; prefer testing boundary/index behavior when porting queries. | `substr('abcdef', 2, 3)` |
| `TO_PASCAL_CASE(text)` | Text | Convert a separated identifier to PascalCase. | `TO_PASCAL_CASE('error_count')` |
| `TO_CAMEL_CASE(text)` | Text | Convert to camelCase. | `TO_CAMEL_CASE('error_count')` |
| `TO_SNAKE_CASE(text)` | Text | Convert to underscore-separated words. | `TO_SNAKE_CASE('ErrorCount')` → `error_count` |
| `TO_KEBAB_CASE(text)` | Text | Convert to hyphen-separated words. | `TO_KEBAB_CASE('ErrorCount')` → `error-count` |
| `TO_TITLE_CASE(text)` | Text | Title-case readable words. | `TO_TITLE_CASE('error count')` |
| `TO_UPPER_CASE(text[, culture])` | Text | Culture-aware uppercase conversion. | `TO_UPPER_CASE('error', 'en-US')` |
| `TO_LOWER_CASE(text[, culture])` | Text | Culture-aware lowercase conversion. | `TO_LOWER_CASE('ERROR', 'en-US')` |
| `FROM_PASCAL_CASE`, `FROM_CAMEL_CASE` | Text | Turn identifiers into readable words, not an exact reversible encoding. | `FROM_PASCAL_CASE('ErrorCount')` |
| `HUMANIZE_TEXT(text)` | Text | Make identifier-like text readable. | `HUMANIZE_TEXT('RetryScheduled')` |
| `DEHUMANIZE_TEXT(text)` | Text | Convert readable words toward an identifier. | `DEHUMANIZE_TEXT('retry scheduled')` |
| `PLURALIZE(text)`, `SINGULARIZE(text)` | Text | English word inflection; not arbitrary language translation. | `PLURALIZE('file')` → `files` |
| `HUMANIZE_NUMBER(n[, culture])` | Text | Spell an integer in words. | `HUMANIZE_NUMBER(42, 'en-US')` |
| `HUMANIZE_ORDINAL(n[, culture])` | Text | Spell an ordinal in words. | `HUMANIZE_ORDINAL(42, 'en-US')` |
| `ORDINALIZE(n[, culture])` | Text | Format a numbered ordinal. | `ORDINALIZE(42, 'en-US')` → `42nd` |

For portable reports, pass culture explicitly when available. Humanized output belongs at the display step; keep numeric and timestamp columns for sorting, comparisons, and export to programs.

## Numeric and math functions

| Function and arguments | Returns | Description | Example |
| --- | --- | --- | --- |
| `abs(n)` | Number | Absolute value; the most-negative 64-bit integer cannot be represented positively. | `abs(-12)` → `12` |
| `round(n[, digits])` | Real | Round to a decimal precision. | `round(12.345, 2)` → `12.35` |
| `floor(n)`, `ceil(n)`, `ceiling(n)` | Number | Round toward negative or positive infinity. | `floor(-1.2)` → `-2` |
| `sqrt(n)` | Real | Square root. | `sqrt(81)` → `9` |
| `pow(n, exponent)`, `power(n, exponent)` | Real | Raise a value to a power. | `power(2, 10)` → `1024` |
| `exp(n)` | Real | Exponential, e raised to n. | `exp(0)` → `1` |
| `log10(n)` | Real | Base-ten logarithm. | `log10(100)` → `2` |
| `sin`, `cos`, `tan` | Real | Trigonometric functions taking radians. | `sin(0)` → `0` |
| `asin`, `acos`, `atan`, `atan2` | Real | Inverse trigonometric functions. | `atan(0)` → `0` |
| `degrees(n)`, `radians(n)` | Real | Convert between radians and degrees. | `radians(180)` |
| `pi()` | Real | Mathematical constant π. | `pi()` |
| `random()` | Integer | Pseudorandom signed integer; not a key-generation facility. | `random()` |
| `HUMANIZE_BYTES(bytes[, format])` | Text | Format byte quantities using readable units. | `HUMANIZE_BYTES(1536)` |

Use `100.0 * errors / NULLIF(total, 0)` for a percentage. Integer-only division can truncate; guarding zero keeps a missing denominator distinct from zero percent. Mathematical domain/error behavior is not identical across native and compatibility functions.

## Date and time functions

| Function and arguments | Returns | Description | Example |
| --- | --- | --- | --- |
| `date(value[, modifiers...])` | Text | Calendar date, normally `YYYY-MM-DD`. | `date('2026-08-17T08:00:01Z')` |
| `time(value[, modifiers...])` | Text | Time of day. | `time('2026-08-17T08:00:01Z')` |
| `datetime(value[, modifiers...])` | Text | SQLite timestamp, normally `YYYY-MM-DD HH:MM:SS`. | `datetime(0, 'unixepoch')` |
| `julianday(value[, modifiers...])` | Real | Julian-day number, useful for elapsed-time arithmetic. | `julianday('2026-08-18')-julianday('2026-08-17')` → `1` |
| `strftime(format, value[, modifiers...])` | Text | Format or extract calendar parts. | `strftime('%Y-%m', '2026-08-17')` → `2026-08` |
| `current_date`, `current_time`, `current_timestamp` | Text | Current UTC date/time keywords; no parentheses. | `SELECT current_timestamp;` |
| `DT_FROM_UNIX_SECONDS(n)` | Timestamp text | UTC timestamp from seconds since the Unix epoch. | `DT_FROM_UNIX_SECONDS(0)` |
| `DT_TO_UNIX_SECONDS(timestamp)` | Integer | Unix seconds from a timestamp. | `DT_TO_UNIX_SECONDS('1970-01-01T00:00:01Z')` → `1` |
| `DT_FROM_UNIX_MILLISECONDS(n)` | Timestamp text | UTC timestamp from Unix milliseconds. | `DT_FROM_UNIX_MILLISECONDS(1234)` |
| `DT_TO_UNIX_MILLISECONDS(timestamp)` | Integer | Milliseconds since the Unix epoch. | `DT_TO_UNIX_MILLISECONDS('1970-01-01T00:00:01.234Z')` → `1234` |
| `DT_TO_UTC(timestamp, zone)` | Timestamp text | Interpret local time in the supplied zone and convert to UTC. | `DT_TO_UTC('2024-01-15 12:00:00', '+02:00')` |
| `DT_FROM_UTC(timestamp, zone)` | Timestamp text | Convert UTC time to the supplied zone. | `DT_FROM_UTC('2024-01-15T12:00:00Z', '+02:00')` |
| `DT_CONVERT_TIMEZONE(timestamp, from, to)` | Timestamp text | Convert between explicit source and target zones. | `DT_CONVERT_TIMEZONE('2024-01-15 12:00:00', 'UTC', '+02:00')` |
| `DT_DAY_OF_WEEK(timestamp[, culture])` | Text | Localized weekday name. | `DT_DAY_OF_WEEK('2024-01-01', 'en-US')` → `Monday` |
| `DT_IS_WEEKEND(timestamp)` | Integer | Saturday or Sunday flag. | `DT_IS_WEEKEND('2024-01-06')` → `1` |
| `DT_ISO_WEEK(timestamp)` | Integer | ISO week number. Near New Year, the ISO week-year can differ from the calendar year. | `DT_ISO_WEEK('2024-01-01')` → `1` |
| `DT_PARSEEXACT(text, format[, culture])` | Timestamp/NULL | Parse using a .NET date format; malformed values return NULL. | `DT_PARSEEXACT('17/08/2026', 'dd/MM/yyyy', 'en-GB')` |
| `DT_TOSTRING(timestamp[, format[, culture]])` | Text | Format a timestamp with .NET date formatting. | `DT_TOSTRING('2026-08-17', 'yyyy-MM')` |
| `HUMANIZE_TIMESPAN(seconds[, culture])` | Text | Format an elapsed duration, not a point in time. | `HUMANIZE_TIMESPAN(90, 'en-US')` |

SQLite `strftime` formats and .NET date formats are different. Fixed offsets such as `+02:00` do not include daylight-saving rules. Named zones depend on the operating system's installed timezone data. Prefer explicit UTC/offset inputs; inspect NULLs around ambiguous, invalid, and out-of-range timestamps instead of silently dropping them.

## Aggregate functions

These functions combine rows. Use `GROUP BY` for one result per category. Except `count(*)`, NULL values generally do not contribute to ordinary numeric aggregates.

| Function and arguments | Returns | Description | Example |
| --- | --- | --- | --- |
| `count(*)`, `count(value)` | Integer | Count all rows, or only non-NULL values. | `SELECT count(*) FROM logs;` |
| `sum(value)` | Number/NULL | Sum non-NULL values; no values produces NULL. | `SELECT sum(bytes) FROM files;` |
| `total(value)` | Real | Sum as floating-point; no values produces `0.0`. | `SELECT total(bytes) FROM files;` |
| `avg(value)` | Real/NULL | Arithmetic mean of non-NULL values. | `SELECT avg(duration_ms) FROM requests;` |
| `min(value)`, `max(value)` | Value | Smallest/largest non-NULL value under SQLite comparison rules. | `SELECT max(duration_ms) FROM requests;` |
| `group_concat(value[, separator])` | Text | Join values across rows. Supply an ordered subquery if order matters. | `SELECT group_concat(name, ', ') FROM people;` |
| `MEDIAN(value)` | Real/NULL | Middle numeric value, interpolating the two middle values when needed. | `SELECT MEDIAN(duration_ms) FROM requests;` |
| `PERCENTILE_CONT(value, fraction)` | Real/NULL | Continuous percentile with fraction from 0 to 1. | `SELECT PERCENTILE_CONT(duration_ms, 0.95) FROM requests;` |
| `PERCENTILE_DISC(value, fraction)` | Number/NULL | Discrete percentile selecting an observed value. | `SELECT PERCENTILE_DISC(duration_ms, 0.95) FROM requests;` |
| `PERCENTILE(value, percent)` | Real/NULL | Continuous percentile using 0 to 100 instead of 0 to 1. | `SELECT PERCENTILE(duration_ms, 95) FROM requests;` |

Use the same percentile argument throughout each group. Invalid percentile arguments produce NULL in ULP's percentile helpers. Exact percentiles retain values for ordering; expect more memory use than a simple count or sum on very large groups.

## Window functions

Window functions preserve input rows. Materialize streaming inputs before queries that must sort or rescan. Specify ordering and a frame deliberately.

| Function | Description | Example |
| --- | --- | --- |
| `row_number()` | Unique sequential number in each partition. | `row_number() OVER (PARTITION BY service ORDER BY timestamp)` |
| `rank()` | Rank with gaps after ties. | `rank() OVER (ORDER BY duration_ms DESC)` |
| `dense_rank()` | Rank without gaps after ties. | `dense_rank() OVER (ORDER BY duration_ms DESC)` |
| `percent_rank()` | Relative rank from 0 to 1. | `percent_rank() OVER (ORDER BY duration_ms)` |
| `cume_dist()` | Fraction of partition at or below the current peer group. | `cume_dist() OVER (ORDER BY duration_ms)` |
| `ntile(n)` | Divide ordered rows into n buckets. | `ntile(4) OVER (ORDER BY duration_ms)` |
| `lag(value[, offset[, default]])` | Value from a previous row. | `lag(timestamp) OVER (ORDER BY timestamp)` |
| `lead(value[, offset[, default]])` | Value from a following row. | `lead(timestamp) OVER (ORDER BY timestamp)` |
| `first_value(value)` | First value in the window frame. | `first_value(timestamp) OVER (ORDER BY timestamp)` |
| `last_value(value)` | Last value in the frame, not necessarily the partition. | `last_value(timestamp) OVER (ORDER BY timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)` |
| `nth_value(value, n)` | Nth value in the frame, or NULL. | `nth_value(duration_ms, 2) OVER (ORDER BY duration_ms ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)` |

Ordinary aggregates such as `sum` and `avg` can also use `OVER`. ULP-specific aggregates are not automatically window-capable simply because SQLite's built-in aggregates are.

## JSON functions

| Function | Returns | Description | Example |
| --- | --- | --- | --- |
| `json_valid(text)` | Integer | Test whether text is valid JSON. | `json_valid('{"ok":true}')` → `1` |
| `json(text)` | JSON text | Validate and normalize JSON text. | `json(' { "a": 1 } ')` |
| `json_extract(json, path...)` | Value/JSON | Extract a property or array item. | `json_extract('{"status":500}', '$.status')` → `500` |
| `json_type(json[, path])` | Text/NULL | JSON type at the root or path; missing paths differ from JSON null. | `json_type('{"a":null}', '$.a')` → `null` text |
| `json_array(value...)` | JSON text | Build a JSON array. | `json_array(1, 'error', NULL)` |
| `json_object(key, value...)` | JSON text | Build a JSON object. | `json_object('status', 500)` |
| `json_array_length(json[, path])` | Integer/NULL | Count array elements. | `json_array_length('[1,2,3]')` → `3` |
| `json_set(json, path, value...)` | JSON text | Insert or replace values at paths. | `json_set('{}', '$.status', 200)` |
| `json_insert`, `json_replace` | JSON text | Insert only missing paths, or replace only existing paths. | `json_insert('{}', '$.status', 200)` |
| `json_remove(json, path...)` | JSON text | Remove properties or array elements. | `json_remove('{"token":"secret","ok":1}', '$.token')` |
| `json_patch(target, patch)` | JSON text | Apply JSON Merge Patch; arrays are replaced as values. | `json_patch('{"a":1}', '{"b":2}')` |
| `json_quote(value)` | JSON text | Encode a SQL value as JSON. | `json_quote('line')` |
| `json_group_array(value)` | JSON text | Aggregate values into an array. | `SELECT json_group_array(name) FROM people;` |
| `json_group_object(key, value)` | JSON text | Aggregate key/value pairs into an object. | `SELECT json_group_object(name, total) FROM counts;` |

`json_each` and `json_tree` produce tables and are used in `FROM`, not as scalar expressions:

```sql
SELECT key, value, type FROM json_each('["error","warning"]');
```

Do not assume JSONB, newer JSON operators, or newer overloads exist in the packaged SQLite runtime. Check installed capabilities first.

## NULL and conditional functions

| Function or expression | Description | Example |
| --- | --- | --- |
| `coalesce(a, b, ...)` | First non-NULL value. Empty text is not NULL. | `coalesce(NULL, 'unknown')` → `unknown` |
| `ifnull(a, b)` | Two-argument fallback. | `ifnull(NULL, 0)` → `0` |
| `nullif(a, b)` | NULL when the values compare equal, otherwise a. | `nullif('', '')` → NULL |
| `iif(condition, yes, no)` | Choose a value from a condition. | `iif(500 >= 400, 'error', 'ok')` |
| `CASE WHEN ... THEN ... ELSE ... END` | Multiple conditional branches. | `CASE WHEN status >= 500 THEN 'server' ELSE 'other' END` |
| `IS_NULL_OR_WHITESPACE(text)` | ULP test for absent, empty, or whitespace-only text. | `IS_NULL_OR_WHITESPACE('  ')` |

Test missing values with `IS NULL`, never `= NULL`. To treat blank fields as absent, combine `NULLIF(trim(value), '')` with `COALESCE`.

## Pattern matching

| Function or operator | Description | Example |
| --- | --- | --- |
| `LIKE` | SQL pattern: `%` any sequence, `_` one character. Case behavior differs from regular expressions. | `'worker error' LIKE '%error%'` |
| `GLOB` | SQLite case-sensitive glob pattern; not a filesystem traversal operation. | `'error.log' GLOB '*.log'` |
| `RX_IS_MATCH(text, pattern)` | Test a regular expression against text; returns a true/false value. | `RX_IS_MATCH('status=500', '[0-9]+')` |
| `RX_GET_GROUP_VALUE(text, pattern, group)` | Extract the first match's named capture as text. | `RX_GET_GROUP_VALUE('status=500', 'status=(?<code>[0-9]+)', 'code')` |
| `RX_REPLACE(text, pattern, replacement)` | Replace regular-expression matches. | `RX_REPLACE('item123', '[0-9]+', '#')` |
| `RX_MATCHES_COUNT(text, pattern)` | Count regular-expression matches. | `RX_MATCHES_COUNT('a1 b2', '[0-9]+')` |

The RegEx/Grok **input formats** create columns from named captures. They are often a better starting point for repeatedly parsing structured logs than scattering expression calls throughout a query. Use [input format help](inputs-and-outputs.md) and the installed function inventory for additional regular-expression overloads.

## Blob and binary functions

| Function | Description | Example |
| --- | --- | --- |
| `zeroblob(n)` | Allocate a zero-filled BLOB of n bytes. | `length(zeroblob(8))` → `8` |
| `randomblob(n)` | Generate n pseudorandom bytes. | `hex(randomblob(4))` |
| `base64_encode(value)` | Encode bytes as Base64 text. | `base64_encode(X'4142')` |
| `base64_decode(text)` | Decode Base64; examine type/output before treating bytes as text. | `hex(base64_decode('QUI='))` |

Hash and encoding helpers are not interchangeable. Encoding is reversible; a cryptographic hash is a digest, and older hashes are not suitable for new security designs. For file duplicate checks use a modern hash such as SHA-256.

## File and system functions

These functions access the host. Run only against paths the user has placed in scope. File hashes read file contents and can be expensive across a large tree.

| Function | Returns | Description | Example |
| --- | --- | --- | --- |
| `FILE_EXISTS(path)` | Integer | Check for an existing file. | `FILE_EXISTS('samples/data/application.log')` |
| `DIRECTORY_EXISTS(path)` | Integer | Check for an existing directory. | `DIRECTORY_EXISTS('samples/data')` |
| `FILE_SIZE(path)` | Integer/NULL | File length in bytes, not formatted text. | `FILE_SIZE('samples/data/application.log')` |
| `FILE_HASH_SHA256(path)` | Text/NULL | SHA-256 digest of file contents. | `FILE_HASH_SHA256('samples/data/application.log')` |
| `EXTRACT_FILENAME(path)` | Text | File portion of a path. | `EXTRACT_FILENAME('C:/Logs/service.log')` |
| `EXTRACT_EXTENSION(path)` | Text | Extension portion using the compatibility extraction rules. | `EXTRACT_EXTENSION('service.log')` |
| `EXTRACT_PATH(path)` | Text | Directory portion of a path. | `EXTRACT_PATH('C:/Logs/service.log')` |
| `COMPUTER_NAME()` | Text | Current host name. | `COMPUTER_NAME()` |
| `IPV4_TO_INT(text)` | Integer | Convert an IPv4 address to its numeric representation. | `IPV4_TO_INT('127.0.0.1')` |
| `INT_TO_IPV4(n)` | Text | Convert a numeric IPv4 value to dotted text. | `INT_TO_IPV4(IPV4_TO_INT('127.0.0.1'))` |
| `WIN32_ERROR_DESCRIPTION(code)` | Text | Windows error message; platform-dependent. | `WIN32_ERROR_DESCRIPTION(2)` |
| `REVERSEDNS(address)` | Text | Reverse DNS lookup; can perform network activity. | `REVERSEDNS('127.0.0.1')` |
| `RESOLVE_SID(sid)` | Text | Resolve a Windows security identifier when permitted. | `RESOLVE_SID('S-1-5-18')` |

## Query counters and compatibility names

ULP supports selected familiar function names for existing query workflows. Similar names do not imply identical SQLite indexing, timestamp formatting, or coercion behavior. In particular, do not translate `INDEX_OF` to `instr` without adjusting its zero-based indexing.

| Function family | Purpose | Example |
| --- | --- | --- |
| `ADD`, `SUB`, `MUL`, `DIV`, `MOD` | Arithmetic compatibility functions. | `SUB(10, 3)` |
| `BIT_AND`, `BIT_OR`, `BIT_XOR`, `BIT_NOT`, `BIT_SHL`, `BIT_SHR` | Bit operations. | `BIT_AND(7, 3)` |
| `STRLEN`, `STRCAT`, `STRREPEAT`, `STRREV` | Length, concatenate, repeat, reverse. | `STRREV('abc')` |
| `INDEX_OF`, `LAST_INDEX_OF` | Find a substring with compatibility indexing. | `INDEX_OF('abc', 'b')` |
| `EXTRACT_TOKEN`, `EXTRACT_PREFIX`, `EXTRACT_SUFFIX`, `EXTRACT_VALUE` | Split or extract delimited data. | `EXTRACT_TOKEN('a,b,c', 1, ',')` |
| `TO_INT`, `TO_REAL`, `TO_STRING` | Convert or format values. | `TO_INT('42')` |
| `TO_DATE`, `TO_TIME`, `TO_TIMESTAMP` | Compatibility date/time conversions. | `TO_TIMESTAMP('2026-08-17', 'yyyy-MM-dd')` |
| `TO_LOCALTIME`, `TO_UTCTIME` | Convert through the host's local timezone. | `TO_UTCTIME(SYSTEM_TIMESTAMP())` |
| `SYSTEM_DATE`, `SYSTEM_TIME`, `SYSTEM_TIMESTAMP`, `SYSTEM_UTCOFFSET` | Host clock and offset values. | `SYSTEM_DATE()` |
| `URLESCAPE`, `URLUNESCAPE` | Encode/decode URL text. | `URLESCAPE('a b')` |
| `IN_ROW_NUMBER()` | Input-phase row numbering for supported ULP query shapes. | `SELECT IN_ROW_NUMBER(), Text FROM logs;` |
| `OUT_ROW_NUMBER()` | Output-phase row numbering. | `SELECT OUT_ROW_NUMBER(), Text FROM logs LIMIT 5;` |
| `SEQUENCE([start])` | Per-query sequence with optional starting value. | `SELECT SEQUENCE(10) FROM (VALUES(1),(2));` |
| `HASHSEQ(value)` | Query-state sequence for distinct values. | `SELECT HASHSEQ(service), service FROM logs;` |

Query-state counters reset per query and are not persistent IDs. For portable SQL ranking prefer `row_number() OVER (...)`. Unsupported counter placement should be corrected, not worked around by calling internal inventory entries. Names beginning with `__ulp_` are internal and are not a user query API.

## Extension functions and runtime discovery

Discover the exact installed names and signatures:

```powershell
ulp --list-functions --format TextTable
ulp --query "SELECT name, narg, type FROM pragma_function_list WHERE name LIKE 'dt_%' ORDER BY name, narg" --format TextTable
ulp --query "PRAGMA module_list" --format TextTable
```

The [full generated inventory](reference/generated/sqlite-functions.json) includes optional extension families beyond this practical reference:

| Family | Purpose and cautions |
| --- | --- |
| `decimal`, `decimal_add`, `decimal_sub`, `decimal_mul`, `decimal_cmp`, `decimal_sum` | Decimal-text arithmetic for exact decimal workflows; keep values as decimal text instead of first converting to floating-point. |
| `ieee754` and related helpers | Inspect floating-point representation; primarily useful for numeric diagnostics. |
| FTS functions such as `bm25`, `highlight`, `snippet`, `matchinfo` | Full-text-search support; require an appropriate FTS table/context, not arbitrary input columns. |
| `editdist3` and spelling helpers | Specialized approximate-match and spellfix workflows; availability and setup depend on loaded extensions. |
| `uuid` and UUID helpers | Generate or convert UUID values; inspect installed arities before use. |
| File/archive/XML helpers | Access external content or specialized formats; confirm permissions and do not enable them for untrusted SQL. |
| `eval`, `exec`, `load_extension` | Dynamic execution or extension loading. These are privileged operations, not ordinary report-formatting functions. |

There is no need to memorize this inventory. Start with the task tables above and inspect the executable when you need an advanced function. Newly released SQLite functions are not automatically present in the bundled runtime.

The following recipes are exercised against ULP itself. Save a complete SQL block to a file and run `ulp --query-file example.sql --format JSON`. Each block is self-contained and runs in a fresh in-memory database. Named temporary tables in the FTS example must be renamed or removed if you repeat it in the same interactive session.

### Exact decimal arithmetic

Use decimal **text** when decimal digits must survive calculations exactly. Do not convert source strings to `REAL` first: that introduces binary rounding before the decimal calculation begins. SQLite's `DECIMAL` column declaration alone does not enforce decimal-text arithmetic. The [upstream numeric guide](https://www.sqlite.org/floatingpoint.html#the_decimal_c_extension) explains the distinction; the examples below were checked against ULP's bundled implementation.

| Function | Returns | What to use it for | Example |
| --- | --- | --- | --- |
| `decimal(value)` | Text/NULL | Convert a value to decimal text; not an input validator. | `decimal('001.2300')` → `1.2300` |
| `decimal_add(a,b)` | Text | Add decimal strings. | `decimal_add('0.1','0.2')` → `0.3` |
| `decimal_sub(a,b)` | Text | Subtract decimal strings. | `decimal_sub('1.00','0.10')` → `0.90` |
| `decimal_mul(a,b)` | Text | Multiply decimal strings. | `decimal_mul('12.50','3')` → `37.5` |
| `decimal_cmp(a,b)` | Integer | Negative, zero, or positive for less than, equal, or greater than. | `decimal_cmp('2','10')` → `-1` |
| `decimal_sum(value)` | Text | Aggregate decimal strings without first using binary floating-point. | Aggregate example below. |

<!-- example: decimal-arithmetic -->
```sql
SELECT decimal('001.2300') AS normalized,
       decimal_add('0.1','0.2') AS sum_text,
       decimal_sub('1.00','0.10') AS difference,
       decimal_mul('12.50','3') AS product,
       decimal_cmp('2','10') AS comparison,
       decimal(NULL) AS null_value,
       decimal('nonsense') AS malformed;
```

Result: `normalized="1.2300"`, `sum_text="0.3"`, `difference="0.90"`, `product="37.5"`, `comparison=-1`, `null_value=NULL`, **`malformed="0"`**. That last result is important: this bundled decimal parser is permissive. Validate incoming text separately; do not silently treat an invalid amount as zero. Decimal output is not fixed-width formatting—trailing zeros can differ between operations.

<!-- example: decimal-aggregate -->
```sql
WITH amounts(value) AS (VALUES ('0.1'), ('0.2'), (NULL))
SELECT decimal_sum(value) AS total FROM amounts;
```

Result: `total="0.3"`; NULL does not contribute. Use `decimal_cmp` for decimal comparisons instead of ordinary lexical text order. The installed catalog has no `decimal_div`, `decimal_exp`, or `decimal_pow2`; do not copy those names from newer extension examples. Native `/` does not become exact decimal division merely because its operands are decimal strings.

### Inspect floating-point values

These helpers diagnose numeric representation; they do not make approximate calculations exact. The two-argument `ieee754(m,e)` reconstructs `m × 2^e`. Blob conversions use eight-byte big-endian IEEE-754 representation. See the [upstream floating-point guide](https://www.sqlite.org/floatingpoint.html#the_ieee754_c_extension).

| Function | Returns | Purpose | Example |
| --- | --- | --- | --- |
| `ieee754(value)` | Text | Display the mantissa/exponent pair. | `ieee754(1.5)` → `ieee754(3,-1)` |
| `ieee754(m,e)` | Real | Reconstruct from integer mantissa and binary exponent. | `ieee754(3,-1)` → `1.5` |
| `ieee754_mantissa(value)` | Integer | Extract the mantissa. | `ieee754_mantissa(1.5)` → `3` |
| `ieee754_exponent(value)` | Integer | Extract the binary exponent. | `ieee754_exponent(1.5)` → `-1` |
| `ieee754_to_blob(value)` | Blob | Inspect or transport the eight bytes; use `hex` for readable output. | `hex(ieee754_to_blob(1.5))` → `3FF8000000000000` |
| `ieee754_from_blob(blob)` | Real/NULL | Decode eight bytes; wrong-size blobs return NULL. | `ieee754_from_blob(x'3FF8000000000000')` → `1.5` |

<!-- example: ieee-roundtrip -->
```sql
SELECT ieee754(1.5) AS representation,
       ieee754_mantissa(1.5) AS mantissa,
       ieee754_exponent(1.5) AS exponent,
       ieee754(3,-1) AS reconstructed,
       hex(ieee754_to_blob(1.5)) AS bits,
       ieee754_from_blob(x'3FF8000000000000') AS decoded,
       ieee754_from_blob(x'00') AS bad_blob;
```

Result: `representation="ieee754(3,-1)"`, `mantissa=3`, `exponent=-1`, `reconstructed=1.5`, `bits="3FF8000000000000"`, `decoded=1.5`, `bad_blob=NULL`. For normal reports, round for display instead; reserve these helpers for explaining unexpected precision or checking a binary round-trip.

### Normalize and store UUIDs

The installed UUID extension accepts UUID text and 16-byte blobs. `uuid_str` produces canonical lowercase hyphenated text; `uuid_blob` produces the 16 bytes in network order. Invalid input returns NULL. `uuid()` generates a random version-4 UUID; call it only when you want a new identifier, not to recreate a stable ID for existing source rows. The [upstream UUID extension](https://github.com/sqlite/sqlite/blob/master/ext/misc/uuid.c) defines these conversions.

| Function | Returns | Purpose | Example |
| --- | --- | --- | --- |
| `uuid()` | Text | Generate a fresh UUID; the value changes. | `length(uuid())` → `36` |
| `uuid_str(value)` | Text/NULL | Normalize text or convert a binary UUID. | `uuid_str('bad')` → `NULL` |
| `uuid_blob(value)` | Blob/NULL | Store a UUID in 16 bytes; CSV needs a text representation. | `length(uuid_blob('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'))` → `16` |

<!-- example: uuid-roundtrip -->
```sql
SELECT uuid_str('A0EEBC999C0B4EF8BB6D6BB9BD380A11') AS canonical,
       hex(uuid_blob('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11')) AS bytes,
       uuid_str(uuid_blob('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11')) AS roundtrip,
       uuid_str('bad') AS invalid,
       uuid_str(NULL) AS absent,
       length(uuid()) AS generated_length;
```

Result: `canonical` and `roundtrip` are `a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`, `bytes="A0EEBC999C0B4EF8BB6D6BB9BD380A11"`, both invalid/absent fields are NULL, and `generated_length=36`. These conversions are not a guarantee of uniqueness or a substitute for a unique constraint. UUID byte order may differ from another application's GUID byte-array convention; compare canonical text when integrating systems.

### Search a materialized full-text index

FTS5 is useful for repeated word searches over copied log or code text. It is **not** automatically attached to a ParsingModule table. Build an index explicitly, keep source locations beside the text, and refresh the copy when sources change. For a one-off substring search, `LIKE` or `ulp search` may avoid unnecessary indexing.

| Function / operation | Meaning | Usage |
| --- | --- | --- |
| `table MATCH expression` | Search tokenized terms; this is FTS syntax, not arbitrary substring matching. | Use the table name and a bound search value. |
| `bm25(table[, weights...])` | Relevance score; smaller values rank better. | Order ascending; scores depend on the indexed corpus. |
| `highlight(table, column, before, after)` | Full column text with matching terms marked; column numbers start at zero. | Use plain markers for terminal output. |
| `snippet(table, column, before, after, ellipsis, tokens)` | Short matching excerpt; a negative column index chooses automatically. | Keep the token budget between 1 and 64. |

The [FTS5 manual](https://www.sqlite.org/fts5.html#auxiliary_functions) describes these table-context functions. `matchinfo` belongs to FTS3/FTS4, not this FTS5 example. Registered `fts5_*` diagnostic helpers are not general-purpose replacements for these functions.

<!-- example: fts-search -->
```sql
CREATE VIRTUAL TABLE temp.search_notes USING fts5(path UNINDEXED, body);
INSERT INTO search_notes VALUES
  ('app.log', 'connection timeout retry scheduled'),
  ('worker.log', 'worker started'),
  ('db.log', 'database timeout connection lost');
SELECT path,
       highlight(search_notes, 1, '[', ']') AS matched,
       snippet(search_notes, 1, '[', ']', '...', 5) AS excerpt,
       bm25(search_notes) < 0 AS has_negative_score
FROM search_notes
WHERE search_notes MATCH 'timeout'
ORDER BY path;
```

| path | matched | excerpt | has_negative_score |
| --- | --- | --- | ---: |
| app.log | connection [timeout] retry scheduled | connection [timeout] retry scheduled | 1 |
| db.log | database [timeout] connection lost | database [timeout] connection lost | 1 |

The example orders by path for repeatable output; use `ORDER BY bm25(search_notes), path` to rank a real search. `UNINDEXED` keeps the path as evidence without including it in word matching. In a ULP workflow, populate the index with `INSERT INTO ... SELECT ...` from a previously inspected input table, projecting source path and line numbers as separate unindexed columns when available.

Binding a parameter protects SQL syntax but does not escape FTS search syntax. For a literal phrase, surround it with double quotes in the **parameter value**, doubling embedded double quotes; operators are otherwise interpreted by FTS. Malformed MATCH expressions produce query errors. Do not render `highlight`/`snippet` output as trusted HTML: the original data remains untrusted even if you use HTML-looking markers. A persistent index consumes storage and retains copied text after the original file is removed.

### Find similar words

Use approximate matching to suggest candidates, not to prove that two records refer to the same entity. Reduce candidates first—applying edit distance to every pair in a large table can be expensive.

| Function | Returns | Meaning | Example |
| --- | --- | --- | --- |
| `editdist3(pattern, word[, language])` | Integer | Weighted edit cost; zero means an exact match, not a percentage score. | `editdist3('timeout','timout')` → `100` with default costs |
| `spellfix1_editdist(pattern, word)` | Integer | Alternative fixed-cost distance; do not assume the same scale as `editdist3`. | `spellfix1_editdist('timeout','timeout')` → `0` |
| `spellfix1_translit(text)` | Text | Approximate ASCII transliteration; accents and distinctions can be lost. | `spellfix1_translit('café')` → `cafe` |
| `spellfix1_scriptcode(text)` | Integer | Dominant writing-script code, not language detection. | `spellfix1_scriptcode('hello')` → `215` (Latin) |
| `spellfix1_phonehash(text)` | Text | Phonetic hash of ASCII text; candidate grouping, not unique identity. | `spellfix1_phonehash('hello')` |

<!-- example: spelling -->
```sql
SELECT editdist3('timeout','timout') AS distance,
       editdist3('timeout','timeout') AS exact,
       spellfix1_translit('café') AS transliterated,
       spellfix1_scriptcode('hello') AS latin_code;
```

Result: `distance=100`, `exact=0`, `transliterated="cafe"`, `latin_code=215`. The one-argument overload `editdist3(table_name)` **loads custom costs**; it does not compare a word. Keep configuration changes separate from read-only reports. The [spellfix documentation](https://www.sqlite.org/spellfix1.html#auxiliary_functions) explains custom language costs and the vocabulary-table workflow. The examples here use fresh connections with default costs.

### Generate bounded series

`generate_series(start, stop, step)` is a table-valued function, so use it in `FROM`. Give explicit finite bounds and a positive step. The installed version does not imply support for every enhancement on the [current upstream series page](https://www.sqlite.org/series.html).

<!-- example: bounded-series -->
```sql
SELECT value FROM generate_series(2, 8, 3) ORDER BY value;
```

Result: `2`, `5`, `8`. The upper bound is included when reached by the step. Use the values as offsets to create a small complete time axis, then left join aggregate results to show missing buckets:

<!-- example: missing-days -->
```sql
WITH daily(day, errors) AS (
  VALUES ('2026-08-17', 2), ('2026-08-19', 1)
), days AS (
  SELECT date('2026-08-17', '+' || value || ' days') AS day
  FROM generate_series(0, 2, 1)
)
SELECT days.day, coalesce(daily.errors, 0) AS errors
FROM days LEFT JOIN daily ON daily.day = days.day
ORDER BY days.day;
```

| day | errors |
| --- | ---: |
| 2026-08-17 | 2 |
| 2026-08-18 | 0 |
| 2026-08-19 | 1 |

Materialize streaming source data once before repeated joins or indexing. Keep series sizes small: a final `LIMIT` is not a substitute for sensible generator bounds when a sort or join must process intermediate rows.

## Detailed examples

### Error rate without division by zero

```sql
WITH events(level) AS (VALUES ('INFO'), ('ERROR'), ('INFO'), ('WARN'))
SELECT COUNT(*) AS total,
       SUM(CASE WHEN level='ERROR' THEN 1 ELSE 0 END) AS errors,
       ROUND(100.0 * SUM(CASE WHEN level='ERROR' THEN 1 ELSE 0 END)
             / NULLIF(COUNT(*), 0), 1) AS error_percent
FROM events;
```

Result: `total=4`, `errors=1`, `error_percent=25.0`.

### Median and tail latency

```sql
WITH requests(ms) AS (VALUES (10), (20), (30), (100))
SELECT AVG(ms) AS mean_ms, MEDIAN(ms) AS median_ms,
       ROUND(PERCENTILE_CONT(ms, 0.95), 2) AS p95_ms FROM requests;
```

Result: `mean_ms=40.0`, `median_ms=25.0`, `p95_ms=89.5`. Four observations explain the calculation but are not a statistically representative production latency sample.

### Normalize labels and timestamps

```sql
SELECT TO_SNAKE_CASE('RequestDuration') AS field_name,
       DT_TO_UNIX_SECONDS('1970-01-01T00:00:01Z') AS seconds,
       DT_IS_WEEKEND('2024-01-06') AS weekend;
```

Result: `field_name=request_duration`, `seconds=1`, `weekend=1`.

Continue with the [use-case tutorials](tutorials.md) for complete commands against the bundled data, or the [SQLite guide](sqlite-guide.md) for query syntax.
