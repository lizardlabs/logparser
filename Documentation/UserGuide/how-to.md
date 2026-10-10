# ULP How-To Guide

This chapter is a task-oriented collection of short ULP recipes. Use it when you know what you want to accomplish and need a command or SQL pattern. For a progressive introduction, start with [ULP Tutorials](tutorials.md).

Examples use PowerShell and the fictional files under `samples/data`. Run them from the ULP directory unless a recipe says otherwise.

## Contents

- [Files and Input](#files-and-input)
- [Filtering and Searching](#filtering-and-searching)
- [Analysis](#analysis)
- [Output](#output)
- [Queries](#queries)
- [Automation](#automation)
- [Related Chapters](#related-chapters)

## Files and Input

### How to Query a Log File

For one record per line, use `TextLine`:

```powershell
ulp --input TextLine --from .\samples\data\application.log --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%' LIMIT 100" `
    --output console --format Terminal
```

Use `RegEx` when a repeatable pattern can split each line into fields. Use `W3C` for W3C extended logs such as IIS, and use `log4jXML` for supported Log4j/log4net XML event files. Inspect the generated provider reference before choosing properties:

```powershell
ulp --help-provider TextLine
ulp --help-provider RegEx
ulp --help-provider W3C
```

For a quick search that does not need SQL:

```powershell
ulp search ERROR .\samples\data\application.log --ignore-case
```

### How to Query CSV Files

CSV headers become table columns dynamically:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name, salary FROM employees LIMIT 20"
```

CSV parsing supports quoted values, escaped quotes, delimiters inside quotes, multiline quoted fields, empty fields, trailing fields, CRLF/LF, and UTF-8 BOM input. Use `Delimiter` for a nonstandard separator or `TSV` for tab-separated data.

Inspect the detected columns:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "PRAGMA table_info(employees)" --format Terminal
```

When numeric-looking CSV fields are text, cast them explicitly:

```sql
SELECT employee_name,
       CAST(salary AS INTEGER) AS salary
FROM employees
ORDER BY salary DESC;
```

### How to Query JSON

Read the bundled JSON array:

```powershell
ulp --input JSON --from .\samples\data\structured-sample.json --table people `
    --query "SELECT id, name, active FROM people ORDER BY id"
```

Boolean values may be exposed as textual values by a provider configuration. Normalize them when filtering:

```sql
SELECT id, name
FROM people
WHERE lower(active) = 'true';
```

Use SQLite JSON functions for JSON stored inside an existing text column. Use the JSON provider when the JSON document itself is the input source.

### How to Query Text Files

Read every line:

```powershell
ulp --input TextLine --from .\notes.txt --table lines `
    --query "SELECT Text FROM lines LIMIT 100"
```

`TextLine` always returns `Text` plus compact JSON `Metadata`. By default each logical line is one chunk. Extract optional location details only when needed:

```powershell
ulp --input TextLine --from .\notes.txt --table lines `
    --query "SELECT json_extract(Metadata, '$.startLine') AS line, Text FROM lines ORDER BY json_extract(Metadata, '$.chunkNumber')"
```

Tokenize text into words with `TextWord`:

```powershell
ulp --input TextWord --from .\notes.txt --table words `
    --query "SELECT Word, COUNT(*) AS occurrences FROM words GROUP BY Word ORDER BY occurrences DESC LIMIT 50"
```

Check the generated provider page if the actual field names or tokenization options differ for the selected provider version:

```powershell
ulp --help-provider TextWord
```

Read an entire normal file, a DOCX/ODT document, or each PDF page with `Text`:

```powershell
ulp --input Text --from .\manual.pdf --table pages `
    --query "SELECT PageNumber, Text FROM pages WHERE Text LIKE '%configuration%'"
```

Create overlapping chunks for search or later retrieval workflows without adding an AI dependency:

```powershell
ulp --input Text --from .\logs\large.log --table chunks `
    --input.ChunkMode Lines --input.ChunkSize 100 --input.ChunkOverlap 10 `
    --query "SELECT ChunkNumber, ChunkStartLine, ChunkEndLine, Text FROM chunks WHERE Text LIKE '%timeout%'"
```

The same extractor is available inside SQLite through `READTEXT` (alias `READ_TEXT`). The optional second argument is a semicolon-separated list. Scalar reads default to a 16 Mi-character safety limit:

```sql
SELECT READTEXT('manual.pdf');
SELECT READ_TEXT(
  'unknown.bin',
  'format=binary;nonText=ignore;preserveLineBreaks=false;maxChars=1048576'
);
```

Supported scalar options are `format`, `nonText`, `replacement`, `preserveLineBreaks`, `maxChars`, `documentMaximumBytes`, and `pdfMaximumPages`. Use a table input when you need chunks rather than one combined scalar value. `Text` exposes separate chunk/page fields; `TextLine` keeps its stable `Text, Metadata` schema and stores optional page/range details in JSON.

### How to Query Multiple Files

Use a wildcard:

```powershell
ulp --input TextLine --from ".\logs\*.log" --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%' LIMIT 200"
```

Separate several sources with a semicolon or comma. Quote the complete value in the shell:

```powershell
ulp --input TextLine --from ".\api\*.log;.\worker\*.log" --table logs `
    --query "SELECT Text FROM logs LIMIT 200"
```

Stream/file providers expand sources lazily, so an early result does not require a complete recursive file list first. A source prefix of `!` excludes matching files:

```text
C:\Logs\*;!*.bak;!archive-*.log
```

If every source is negative, ULP starts from `*`. Use `!!name` for a literal source beginning with `!`.

With recursion enabled, filename-only exclusions apply in every subdirectory. Relative path exclusions are based on the positive wildcard directory, so `C:\Logs\*.log;!archive\*.log` omits the `C:\Logs\archive` subtree.

### How to Use Wildcards

`*` matches any sequence and `?` matches one character. Examples:

```text
C:\Logs\*.log
C:\Logs\server-2026-??.csv
.\samples\data\*
```

For archive entries, put the archive path before `|` and the entry pattern after it:

```text
C:\Logs\archive.zip|*.log
C:\Logs\*.zip|errors\*.txt
```

For an encrypted archive, prefer a named environment-variable secret rather than an inline password:

```text
file:///C:/Logs/archive.zip?password-env=ULP_ARCHIVE_PASSWORD|*.log
```

### How to Read Appended Records Only

Providers that support checkpoints expose `CheckpointFile`. The first successful run reads the full source; later runs process appended records:

```powershell
ulp --input TextLine --from "C:\Logs\*.log" --table logs `
    --i.TextLine.CheckpointFile "C:\ULP-State\logs.checkpoint" `
    --query "SELECT Text FROM logs" `
    --output file --format CSV --output-file .\new-records.csv
```

Checkpoint changes are committed only after query execution, output, and the after-query hook succeed. See [incremental input](inputs-and-outputs.md#incremental-input-and-checkpoints) for truncation, replacement, new/deleted file, and early-limit behavior.

## Filtering and Searching

### Extract fields from an XML payload

If a row contains XML, select attributes with XPath `@name` and element text with `text()`. First inspect the input schema: XML function names do not imply a generic XML input format or a particular event payload column. Follow the [complete XML extraction recipe](functions.md#validate-and-extract-event-fields) for a runnable sample, malformed-row handling, and expected output; see [namespace handling](functions.md#handle-xml-namespaces-explicitly) when your payload uses namespaces.

### Inspect encoded log fields

For percent-encoded UTF-8 text, use `URLUNESCAPE(value, 65001)` and retain the original value as evidence. It preserves literal plus signs, so it is not automatically a form decoder. To generate a path segment, query key, or query value, use `URL_COMPONENT_ENCODE(value)`; do not apply it to a complete URL. The [URL recipes](functions.md#url-text) show both contracts.

For Base64 text and binary payloads, see the [binary-safe Base64 recipe](functions.md#decode-base64-text-and-binary-data-safely). Decoding returns a BLOB; cast it to `TEXT` only when the decoded character encoding is known. These helpers do not redact secrets, so exclude sensitive fields before exporting or sharing results.

### How to Filter Records

Use `WHERE`:

```sql
SELECT *
FROM employees
WHERE lower(active) = 'true'
  AND CAST(salary AS INTEGER) >= 100000;
```

Common operators include `=`, `<>`, `<`, `<=`, `>`, `>=`, `LIKE`, `IN`, `BETWEEN`, `IS NULL`, `AND`, `OR`, and `NOT`.

### How to Search Text

Use direct search for filenames, line numbers, and matching text without SQLite:

```powershell
ulp search timeout .\logs --ignore-case --include "*.log"
ulp search --regex "ERROR|FATAL" .\logs --include "*.log" --format jsonl
```

Use SQL when text is one field in a structured record:

```sql
SELECT TimeCreated, SourceName, Message
FROM events
WHERE Message LIKE '%timeout%'
ORDER BY TimeCreated DESC
LIMIT 100;
```

`LIKE` is convenient for simple patterns. For complex parsing, prefer the `RegEx` provider or an appropriate SQLite pattern function registered by the current runtime.

### How to Find Missing Values

Find SQL nulls:

```sql
SELECT *
FROM records
WHERE Message IS NULL;
```

Find nulls, empty strings, or whitespace-only values:

```sql
SELECT *
FROM records
WHERE Message IS NULL
   OR trim(Message) = '';
```

Use `COALESCE(Message, '(missing)')` to provide a display value without changing the source.

### How to Filter by Date

Use ISO-8601 values and an exclusive upper boundary:

```sql
SELECT *
FROM events
WHERE TimeCreated >= '2026-08-01'
  AND TimeCreated <  '2026-09-01'
ORDER BY TimeCreated;
```

For a rolling interval:

```sql
WHERE datetime(TimeCreated) >= datetime('now', '-24 hours')
```

Be explicit about UTC versus local time. ULP provides additional UTC, timezone, and Unix-time helpers; inspect them with `ulp --list-functions`.

### How to Filter by IP Address

For exact textual matching:

```sql
WHERE ClientIp = '192.0.2.25'
```

For an IPv4 numeric range, use compatibility helpers:

```sql
WHERE IPV4_TO_INT(ClientIp)
      BETWEEN IPV4_TO_INT('192.0.2.0')
          AND IPV4_TO_INT('192.0.2.255')
```

Invalid IP values can produce null results. Add `IPV4_TO_INT(ClientIp) IS NOT NULL` when malformed records must be excluded explicitly.

## Analysis

### How to Count Records

```sql
SELECT COUNT(*) AS records
FROM logs;
```

For automation, test a scalar result:

```powershell
ulp --query "SELECT COUNT(*) FROM sqlite_master" --output none --expect-scalar 0
```

Use `--require-rows` when at least one result row is required.

### How to Group Results

```sql
SELECT EventTypeName,
       COUNT(*) AS events
FROM windows_events
GROUP BY EventTypeName
ORDER BY events DESC;
```

Use `HAVING` to filter groups:

```sql
HAVING COUNT(*) >= 10
```

### How to Calculate Statistics

```sql
SELECT COUNT(*) AS samples,
       MIN(DurationMs) AS minimum_ms,
       ROUND(AVG(DurationMs), 2) AS average_ms,
       MEDIAN(DurationMs) AS median_ms,
       PERCENTILE_CONT(DurationMs, 0.95) AS p95_ms,
       MAX(DurationMs) AS maximum_ms
FROM requests;
```

Use a numeric field with a meaningful order. A percentile over event names, severity labels, or other categorical values is not meaningful.

### How to Find Top Values

```sql
SELECT SourceName,
       COUNT(*) AS events
FROM windows_events
GROUP BY SourceName
ORDER BY events DESC, SourceName
LIMIT 20;
```

The secondary sort makes ties deterministic.

### How to Find Rare Values

```sql
SELECT SourceName,
       COUNT(*) AS events
FROM windows_events
GROUP BY SourceName
HAVING COUNT(*) <= 2
ORDER BY events, SourceName;
```

Rare does not automatically mean suspicious. Compare against the correct time window and population.

### How to Join Two Streaming Sources

Materialize forward-only ParsingModule sources before a plan scans them repeatedly:

```sql
CREATE TEMP TABLE employees_data AS SELECT * FROM employees_stream;
CREATE TEMP TABLE departments_data AS SELECT * FROM departments_stream;

SELECT e.employee_name,
       d.department_name
FROM employees_data AS e
JOIN departments_data AS d
  ON CAST(e.department_id AS INTEGER) = CAST(d.department_id AS INTEGER);
```

The checked-in `samples/parsingmodule/05-csv-join-and-window.sql` demonstrates the complete setup and a window ranking.

### How to Summarize Text Without SQL

```powershell
ulp analyze .\logs --include "*.log"
Get-Content .\build.log | ulp analyze --stdin --format json --normalize-lines log-template
```

Automatic content-shape labels and severity keywords are evidence-based hints, not authoritative parsed fields.

## Output

### How to Export CSV

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees ORDER BY employee_id" `
    --output file --format CSV --output-file .\output\employees.csv
```

The target directory must exist unless a specific writer documents directory creation.

### How to Export JSON

```powershell
ulp --input TSV --from .\samples\data\requests.tsv --table requests `
    --query "SELECT * FROM requests ORDER BY timestamp" `
    --output file --format JSON --output-file .\output\requests.json
```

Use `--help-writer JSON` to inspect formatting properties.

### How to Save Results

Choose a file destination and writer:

```powershell
ulp --query "SELECT sqlite_version() AS version" `
    --output file --format Markdown --output-file .\output\sqlite-version.md
```

Send one executed result to several writers:

```powershell
ulp --query "SELECT 1 AS id, 'example' AS name" `
    --output file --format CSV --output-file .\output\result.csv `
    --also-pipeline JSON=.\output\result.json `
    --also-pipeline Excel=.\output\result.xlsx
```

Use `--no-output-if-empty` to leave targets untouched for an empty result and `--no-overwrite` to reject an existing target.

### How to Use Dynamic Output Names

Use documented date/time tokens and `{n}`:

```powershell
ulp --query "SELECT 1 AS value" --output file --format JSON `
    --output-file ".\output\result-{yyyy-MM-dd}-{n}.json"
```

`{n}` resolves to the first available positive number without overwriting a collision.

### How to Pipe Output

Choose a plain machine-friendly console writer and redirect standard output:

```powershell
ulp --query "SELECT 1 AS id, 'example' AS name" `
    --output console --format JSON |
    Set-Content -LiteralPath .\output\result.json -Encoding utf8
```

Keep diagnostics on standard error and data on standard output. Avoid the decorated Terminal writer when another program will parse the output.

### How to Suppress Normal Output

```powershell
ulp --query "SELECT COUNT(*) FROM sqlite_master" --output none --silent --expect-scalar 0
```

`--silent` suppresses normal console status and results but preserves failures, explicit file outputs, and configured file logging.

## Queries

### How to Save a Query

Save SQL in a `.sql` file:

```sql
SELECT employee_name,
       CAST(salary AS INTEGER) AS salary
FROM employees
ORDER BY salary DESC
LIMIT 10;
```

Run it after defining its source:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query-file .\top-employees.sql --output console --format Terminal
```

Use the TUI editor or its Open/Save/Save As commands when you prefer an interactive editor.

### How to Reuse a Query

Put a metadata-bearing `.sql` recipe in the recursive Query library. The installed `queries/Files/dir.sql` recipe declares a title, description, command alias, provider, source, table, default output, and parameter.

Run it by command alias:

```powershell
ulp -c.dir
```

Override its source and parameter:

```powershell
ulp -c.dir --from "C:\Logs\*" --p.extension .log --format JSON
```

Change the library directory with `--queries-dir`, `ULP_QUERIES_DIR`, or the corresponding menu setting.

### How to Parameterize a Query

Use native SQLite parameters, not string replacement:

```powershell
ulp --query "SELECT @customerId AS customer_id, @enabled AS enabled" `
    --param customerId=42 --param enabled=true
```

SQLite accepts `@name`, `:name`, and `$name`. Repeat `--param`, or use `--param.name`/`--p.name` forms. Parameters are values, not SQL identifiers or fragments.

### How to Preview a Query

Use the menu, Query library, or Query Builder. These workflows show the complete SQL and allow editing, copying, execution, or return without running it. For a script, store the SQL in source control and review the `.sql` file before invoking `--query-file`.

### How to Materialize Data for Reuse

Persist provider rows to an ordinary SQLite database:

```powershell
ulp ingest .\samples\data\employees.csv --parser CSV `
    --db .\investigation.db --table employees
```

Append another compatible source:

```powershell
ulp ingest .\new-employees.csv --parser CSV `
    --db .\investigation.db --table employees --append
```

Use `--replace` explicitly to replace an existing table. Without it, ingest does not silently overwrite the table.

Inspect the database and its migration history:

```powershell
ulp db info .\investigation.db
ulp db info .\investigation.db --no-migrate --format json
```

Normal inspection initializes an ordinary SQLite database or upgrades an older compatible ULP analysis database. Add `--no-migrate` in audits and automation that must not modify the file. A successful ingest records a masked source manifest together with its row count, schema hash, table, provider, and timestamps. ULP rejects databases created by a newer, unsupported analysis schema.

## Automation

### How to Run ULP From PowerShell

Use the call operator for a path containing spaces and check `$LASTEXITCODE`:

```powershell
& 'C:\Tools\ULP\ulp.exe' `
    --input CSV --from 'C:\Data\employees.csv' --table employees `
    --query 'SELECT COUNT(*) AS employees FROM employees' `
    --output file --format JSON --output-file 'C:\Reports\employees.json'

if ($LASTEXITCODE -ne 0) {
    throw "ULP failed with exit code $LASTEXITCODE."
}
```

Use arrays when building arguments so spaces and special characters stay separated:

```powershell
$ulpArguments = @(
    '--input', 'TextLine',
    '--from', 'C:\Logs\*.log',
    '--table', 'logs',
    '--query', "SELECT Text FROM logs WHERE Text LIKE '%ERROR%' LIMIT 100",
    '--output', 'file',
    '--format', 'JSON',
    '--output-file', 'C:\Reports\errors.json'
)

& 'C:\Tools\ULP\ulp.exe' @ulpArguments
```

### How to Use ULP in a Script

For non-interactive execution:

- provide the query and all paths explicitly;
- use `--no-env` when ambient `ULP_*` variables must not affect the run;
- choose `--output file` or a machine-friendly console format;
- use `--require-rows`, `--expect-scalar`, or a condition query for assertions;
- use `--silent` for normal status suppression;
- configure a masked rolling log for diagnostics;
- avoid interactive destinations and menu commands.

Example gate:

```powershell
ulp --input TSV --from .\samples\data\requests.tsv --table requests `
    --query "SELECT COUNT(*) FROM requests WHERE CAST(status AS INTEGER)>=500" `
    --output none --expect-scalar 1 --silent
```

### How to Use ULP in a Pipeline

Pipe text into the direct analyzer:

```powershell
Get-Content .\build.log | ulp analyze --stdin --format json
```

Or parse machine-friendly ULP JSON in PowerShell:

```powershell
$result = ulp --query "SELECT sqlite_version() AS version" --format JSON |
    ConvertFrom-Json

$result.Table0.Data[0].version
```

Keep the query bounded when a downstream command buffers the complete output.

### How to Schedule ULP

Put the complete non-interactive command in a reviewed PowerShell script. Use absolute paths for the executable, config directory, Query library, input, checkpoints, database, output, and log. Run the script manually under the same account before scheduling it.

A scheduled script should:

1. set a predictable working directory;
2. use `--no-env` or explicitly controlled environment values;
3. write logs to a retained, access-controlled directory;
4. use a checkpoint for append-only sources where appropriate;
5. check the ULP exit code;
6. avoid prompts, menus, TUI, and the browser interface;
7. use secret references instead of inline passwords;
8. define whether an empty result is success or failure.

Use Windows Task Scheduler or the organization's automation platform to run that script. Scheduler account, credential, retention, and failure-notification policy are deployment decisions outside ULP.

For a fixed interval while the current terminal remains attached, ULP can repeat the query itself:

```powershell
ulp --query "SELECT datetime('now') AS checked_at" `
    --every 30s --runs 10 `
    --output file --format JSON --output-file '.\status-{RunNumber}.json'
```

The first run is immediate. Add `--wait-first` to wait one interval before it. Omit `--runs` to continue until Ctrl+C, and add `--continue-on-error` only when a later poll should still run after a failed one. This is an attached, process-scoped schedule—not a durable service. In the advanced interactive menu, **Recurring queries** can create, inspect, pause, resume, and cancel fixed-interval schedules; pausing lets an active query finish and prevents its next run.

For a calendar schedule, use a five-field cron expression:

```powershell
ulp --query "SELECT datetime('now') AS checked_at" `
    --cron "0 2 * * MON-FRI" --cron-time-zone UTC `
    --output file --format JSON --output-file '.\daily-{yyyy-MM-dd}.json'
```

The fields are minute, hour, day of month, month, and day of week. ULP supports `*`, comma-separated lists, increasing ranges, `/` steps, numeric values, and English three-letter month/day names. Day-of-month and day-of-week use standard cron OR behavior when both are restricted. The default timezone is the computer's local timezone; use `UTC` for deterministic automation or a Windows timezone ID such as `Eastern Standard Time`. Cron waits for the first match; add `--run-now` to run once immediately. A nonexistent spring-forward local minute is skipped, while a repeated autumn minute can run twice because it represents two UTC instants.

### How to Follow a Growing Log

Use `--tail` with one local `TextLine` file. ULP keeps an in-memory checkpoint, waits for complete lines, and applies the SQL filter only to each newly available group:

```powershell
ulp --input TextLine --from 'C:\Logs\application.log' --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%'" `
    --tail --every 500ms `
    --output console --format Terminal
```

Existing complete lines are skipped by default. Add `--tail-existing` to include them on the first run. An unfinished final line is retained and appears only after its newline is written. Ctrl+C stops both the current query and future polling.

Tail mode polls rather than subscribing to filesystem notifications. It currently supports exactly one seekable local TextLine file, not globs, URLs, or archive members. Checkpoint state exists only for that ULP process. Successful query and output completion advances it; a failed run is retried from the previous safe position. This gives useful at-least-once behavior, not a durable exactly-once guarantee. For file output, include `{RunNumber}` in the path to avoid replacing the preceding poll.

The query sees only the newly completed group for that poll. An aggregate such as `COUNT(*)` therefore describes that group, not every line seen since startup. For cumulative statistics, append selected rows to a deliberate persistent SQLite table or run ordinary checkpointed batches; do not assume tail keeps a lifetime aggregate in memory.

### How to Run a Post-Action

Start a program only after a successful file result:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees WHERE lower(active)='true'" `
    --output file --format JSON --output-file .\active.json `
    --no-output-if-empty `
    --after notify.exe --after-arg .\active.json --after-when file
```

ULP starts the executable directly and does not pass it through an implicit command shell. To run a script, specify its interpreter explicitly. Use `--after-arg=<value>` when an argument begins with `-`.

## Related Chapters

- [Getting Started](getting-started.md)
- [ULP Tutorials](tutorials.md)
- [ULP Reference](reference.md)
- [SQLite and ParsingModule](sqlite-guide.md)
- [Input providers and writers](inputs-and-outputs.md)
- [Configuration](reference.md#configuration)
- [Automation and lifecycle options](reference.md#automation-and-lifecycle-options)
- [Incremental input](inputs-and-outputs.md#incremental-input-and-checkpoints)
