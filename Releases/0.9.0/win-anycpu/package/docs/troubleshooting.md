# Troubleshooting ULP

Use this chapter to identify a failure, collect sanitized diagnostics, and select the smallest corrective action. Exact messages shown here come from the documented ULP command surface where available.

## Contents

- [First Diagnostic Steps](#first-diagnostic-steps)
- [Installation Problems](#installation-problems)
- [ULP Is Not Found in PATH](#ulp-is-not-found-in-path)
- [File Not Found](#file-not-found)
- [Permission Errors](#permission-errors)
- [SQL Syntax Errors](#sql-syntax-errors)
- [Unknown Columns](#unknown-columns)
- [Unknown Functions](#unknown-functions)
- [Input Parsing Problems](#input-parsing-problems)
- [Encoding Problems](#encoding-problems)
- [Date and Time Problems](#date-and-time-problems)
- [Export Problems](#export-problems)
- [Performance Problems](#performance-problems)
- [User Interface Problems](#user-interface-problems)
- [AI Problems](#ai-problems)
- [Chocolatey Problems](#chocolatey-problems)
- [WinGet Problems](#winget-problems)
- [Windows Installer Problems](#windows-installer-problems)
- [NuGet Problems](#nuget-problems)
- [Getting Diagnostic Information](#getting-diagnostic-information)
- [Reporting a Bug](#reporting-a-bug)

## First Diagnostic Steps

Run these from the same account, directory, and terminal where the failure occurs:

```powershell
ulp --version
ulp --list-providers
ulp --list-writers
ulp --sqlite-info
```

Then repeat the failing command with sanitized detail:

```powershell
ulp --verbose --full-errors --log --stats <the-rest-of-your-command>
```

Before sharing output, remove credentials, API keys, connection strings, personal records, private paths, hostnames, query parameters, and proprietary SQL. ULP masks recognized secret patterns, but no automatic masker can understand every sensitive value.

Interpret the exit code first:

| Code | Category |
| ---: | --- |
| 0 | Success |
| 1 | Unexpected/general failure |
| 2 | Command/configuration error |
| 3 | SQL/provider/input execution error |
| 4 | Required result condition not met |
| 5 | Output writer/path error |
| 6 | Post-action failure |
| 130 | Cancelled with Ctrl+C |

## Installation Problems

### ULP starts and immediately reports a missing DLL

The package was probably copied incompletely. Keep `ulp.exe`, runtime DLLs, `x86`, `x64`, configuration, Query library, web assets, and other release content together. Re-extract the complete official archive into a new empty directory.

### `.NET Framework` is missing

The documented executable targets .NET Framework 4.8.1. Install/enable the supported runtime through an approved Windows administration channel, then restart the terminal or machine if required by Windows servicing.

### Windows blocked downloaded files

Verify source, checksum, and signature claims first. Only then unblock the trusted extracted files. Do not use unblocking as a substitute for provenance verification.

### ULP works in the build folder but not the package

Compare the release directory/package against [Release Artifacts](deployment.md#release-artifacts). A dependency may have been omitted, or a local development-only path may have hidden a packaging problem.

## ULP Is Not Found in PATH

Typical PowerShell message:

```text
The term 'ulp' is not recognized as the name of a cmdlet, function, script file, or operable program.
```

Check resolution:

```powershell
Get-Command ulp -All
where.exe ulp
```

If no result appears, run the exact executable path or add its exact directory to PATH. Open a new terminal after changing persistent environment variables.

If several results appear, an older copy may be running. Compare:

```powershell
Get-Command ulp -All | Select-Object Source
ulp --version
```

## File Not Found

### Query/input/config file is missing

Relative paths start from the current working directory unless the feature documents another base. Display it:

```powershell
Get-Location
Resolve-Path .\samples\data\employees.csv
```

Quote paths containing spaces. For a missing query file, ensure `--query-file` receives a file rather than SQL text.

### Query command was not found

Exact message begins:

```text
Query command '<name>' was not found in '<directory>'.
```

Confirm the Query library root and metadata:

```powershell
$env:ULP_QUERIES_DIR
ulp --queries-dir .\queries -c.dir
```

The SQL file needs a leading metadata line such as `-- command: dir`. Duplicate command tags also invalidate the library.

### Source glob returns nothing

Check shell quoting, working directory, recursive property, inclusion/exclusion order, and whether default exclusions omit build/dependency folders. Test a literal file before broadening to a glob.

## Permission Errors

Messages may contain `Access is denied`, `UnauthorizedAccessException`, or a provider-specific permission result.

Check permissions for:

- input files/directories;
- Windows Event Log channels;
- Active Directory/network resources;
- SQLite database and its directory;
- output and temporary sibling files;
- configuration, Query library, checkpoint, and log paths;
- certificate/private-key access for HTTPS;
- secret files and Windows credentials.

Do not solve ordinary access failures by running every query as administrator. Grant the smallest required permission to the intended account.

## SQL Syntax Errors

Use a minimal query:

```powershell
ulp --query "SELECT sqlite_version();"
```

Then isolate source creation from SQL:

```powershell
ulp -i CSV --from .\data.csv --table records --list-tables
ulp -i CSV --from .\data.csv --table records --list-columns records
```

Common causes:

- SQL Server/Microsoft Log Parser syntax used where SQLite syntax is required;
- missing quotes around string/date values;
- trailing/incomplete statement;
- using `SELECT TOP` instead of `LIMIT`;
- referencing a provider-generated name rather than the explicit `--table` name;
- query-file preprocessing or delimiter assumptions;
- an empty file: `The SQL script contains no executable query blocks.`

Use the [SQLite Guide](sqlite-guide.md) and run `EXPLAIN QUERY PLAN` after correctness is established.

## Unknown Columns

SQLite reports a message such as:

```text
no such column: ColumnName
```

Inspect the real provider schema:

```powershell
ulp -i CSV --from .\data.csv --table records --list-columns records
ulp --help-provider CSV
```

CSV headers may contain whitespace, punctuation, duplicates, or unexpected encoding. Quote only identifiers that require it:

```sql
SELECT [Column With Spaces] FROM records;
```

Do not assume EVT, EVTXECMD, and EVTXP expose interchangeable fields.

## Unknown Functions

SQLite reports:

```text
no such function: FUNCTION_NAME
```

Check the running build:

```powershell
ulp --list-functions
ulp --sqlite-info
```

Then consult [SQL Function Reference](functions.md). Function availability may differ between builds, SQLite versions, or restricted hosts. Confirm spelling and required argument count.

## Input Parsing Problems

### CSV columns shift or rows split

Use `CSV` for comma-separated input, `TSV` for tabs, or `Delimiter` for a custom delimiter. Inspect quoting, delimiter, encoding, header, and malformed-record options:

```powershell
ulp --help-provider CSV
ulp --help-provider Delimiter
```

RFC-style CSV supports delimiters/newlines inside quoted fields and escaped `""` quotes. A malformed unclosed quote should produce a predictable parser error rather than silently realign later rows.

### Structured records do not flatten as expected

JSON/YAML/TOON documents can be arrays, mappings, or nested objects. Test a small representative file and list its columns. Do not assume that different structured providers use identical flattening rules.

### Archive input fails

Check `archive|entry-glob` quoting, installed archive support, password environment variable, entry names, and corruption. Never place an archive password directly in the source URL.

### Checkpoint repeats or skips data

Use a stable checkpoint path per source/configuration. Do not share one checkpoint between unrelated jobs. Checkpoint state commits only after complete successful processing; cancellation/output failure intentionally retains the previous safe point. Replaced/truncated files may restart.

## Encoding Problems

Symptoms include replacement characters (`�`), wrong header names, invalid delimiters, or failed JSON/YAML parsing.

ULP recognizes common byte-order marks. Unmarked text is generally treated as UTF-8 by direct text tools. Provider-specific encoding settings may differ; inspect provider help.

`ulp analyze --format json` reports `decoding_replacement_characters`. A nonzero value means decoding was not clean. Convert the file using a known source encoding or configure the provider explicitly—do not merely hide replacement characters.

## Date and Time Problems

Check whether the source value is:

- text, Unix seconds, Unix milliseconds, Julian day, or a native provider value;
- UTC, local time, or an offset-bearing timestamp;
- sortable ISO text or locale-specific text;
- null/invalid for some records.

Prefer explicit conversion and verify with a few known timestamps. Examples:

```sql
SELECT datetime('now'), datetime('now', '-24 hours');
SELECT dt_from_unix_seconds(1700000000);
```

Timezone conversion cannot correct a timestamp whose original timezone is unknown. Daylight-saving transitions can create ambiguous/nonexistent local wall times.

## Export Problems

### `A File destination requires --output-file`

Add a path:

```powershell
ulp --query "SELECT 1" --output file --format JSON --output-file .\result.json
```

### Existing file is not replaced

`--no-overwrite` intentionally rejects it. `{n}` chooses a free numbered filename. `--no-output-if-empty` intentionally preserves the old target when no rows exist.

### Multi-output partially fails

An output failure returns exit code 5. Check every destination path, writer option, open file lock, disk space, and permission. Successful fan-out should not be assumed when one pipeline fails.

### Excel opens incorrectly

Use the `Excel` writer and `.xlsx` extension. Do not rename CSV or HTML output to `.xlsx`. Test the generated workbook in Excel and LibreOffice; each result set should become a worksheet.

### HTML styling is unwanted

Choose the writer's Clean or BuiltIn style mode, or configure controlled custom CSS. Tailwind mode may be inappropriate for offline/self-contained output.

## Performance Problems

First determine whether time is spent discovering input, reading/parsing, SQL, output, or display. Use `--stats`, `--verbose`, and a bounded query.

Common fixes:

- use selective source paths and exclusions;
- take advantage of lazy file enumeration;
- preview with a small `LIMIT`;
- avoid unnecessary `ORDER BY`, grouping, joins, windows, or hashes;
- materialize a forward-only provider once before repeated scans;
- index materialized/persistent join/filter columns;
- avoid TUI/web grids for enormous unbounded results;
- use streaming file writers;
- narrow duplicate-file candidates before hashing file contents;
- use checkpoints for incremental processing where applicable.

A final `LIMIT` does not guarantee little input work when the plan must sort, aggregate, recurse, or join before returning rows.

## User Interface Problems

### Menu numbers do not work

Menus use arrow keys, Enter, and type-to-filter search. Numeric shortcuts depend on the active menu/input behavior and are not guaranteed for every selection list.

### Long help immediately returns to a menu

Enable paging:

```powershell
ulp --pager=always --help general
```

Use Space/PageDown/Down, PageUp/Up, Home/End, `A` for all remaining content, and Q/Escape to return.

### Terminal is visually damaged

Use the menu's Clear screen action or restart the terminal. Disable color/interactive rendering through a redirected or noninteractive workflow when the terminal does not support it.

### TUI does not fit

Increase terminal dimensions, reduce font size, or use terminal/file output. TUI requires an interactive terminal.

### Web page cannot connect

Confirm displayed URL, bind address, port, HTTPS certificate warning/trust, firewall, server process, and authentication. Explicit HTTP requires `--web-http`. Remote unauthenticated binds are blocked unless risk is explicitly accepted.

### Web grid shows fewer rows

`--web-max-rows` bounds returned rows. The SQL itself may also contain `LIMIT`. Narrow the query rather than raising the grid limit indefinitely.

## AI Problems

### `AI Chat is not configured for this web server`

AI is disabled by default. It requires `--web-ai`, a base URL, model, and API-key reference. Restart the web server after changing startup configuration.

### Authentication/provider errors

Check the key reference under the server account, model access, base URL, network, TLS, timeout, quota, and provider compatibility. ULP expects a Chat Completions-compatible response.

### Generated SQL is wrong

Do not execute it. Compare tables/columns with the current schema, edit manually, reduce the prompt, and include exact safe identifiers. AI output is a proposal, not validation.

See [AI Troubleshooting](ai.md#troubleshooting).

## Chocolatey Problems

No publisher-approved Chocolatey ID or package definition is documented in this source tree. If `choco` installed something named ULP, verify its publisher and provenance; it may be unofficial. Use the official portable package until the project website publishes a verified channel.

## WinGet Problems

No publisher-approved WinGet identifier or manifest is documented here. Do not guess an ID from search results. Use the verified portable package.

## Windows Installer Problems

No supported MSI/MSIX/setup project or product code exists in the current source tree. Installer repair/silent/uninstall commands therefore cannot be documented. If an organization wrapped the portable ZIP, contact that package maintainer.

## NuGet Problems

No supported public ULP SDK/tool package ID is documented. A similarly named NuGet package is not evidence of ownership. ULP is distributed as an application through the verified portable workflow.

## Getting Diagnostic Information

Collect only what is needed:

```powershell
ulp --version
ulp --sqlite-info
ulp --list-providers
ulp --list-writers
ulp --list-functions
```

For the failing run:

```powershell
ulp --verbose --full-errors --stats --log-file '.\logs\repro-{date}.log' <arguments>
```

Record:

- exact sanitized command/config;
- expected and actual behavior;
- exit code;
- ULP and Windows/.NET version;
- provider/writer names;
- minimal fictional/sample input;
- whether the problem reproduces without saved settings/default config;
- whether it reproduces with `--use-factory-defaults --no-env`;
- sanitized stderr/log excerpt;
- file/output type and size;
- UI terminal/browser details when relevant.

Never attach real credentials, API keys, checkpoint secrets, customer logs, personal data, or proprietary database contents.

## Reporting a Bug

The repository does not currently contain a verified public issue-tracker URL or approved private support address. Use the contact/reporting path published on [log-parser.com](https://log-parser.com) for the release you are using.

A useful report includes a minimal reproducible example built from fictional data, exact version, command, exit code, expected/actual result, and sanitized diagnostics. For a suspected vulnerability, follow the root `SECURITY.md` policy once the publisher supplies/approves it; do not disclose exploitable details in a public issue.

## Related Documentation

- [Installing ULP](installation.md)
- [ULP Reference](reference.md)
- [Input and Output Formats](inputs-and-outputs.md)
- [User Interface](user-interface.md)
- [Deployment and Packaging](deployment.md)
