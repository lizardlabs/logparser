# ULP Reference

This chapter is the readable reference for ULP command syntax, options, configuration, defaults, environment settings, exit codes, locations, logging, diagnostics, and runtime discovery. Use it when you know the task and need the exact control.

For a guided introduction, start with [Getting Started](getting-started.md). For provider and writer behavior, use [Input and Output Formats](inputs-and-outputs.md).

## Contents

- [Command-Line Syntax](#command-line-syntax)
- [Global Options](#global-options)
- [Commands](#commands)
- [Source Blocks](#source-blocks)
- [Query Syntax](#query-syntax)
- [Query Library](#query-library)
- [Web HTTP API](#web-http-api)
- [SQLite Connections](#sqlite-connections)
- [Configuration](#configuration)
- [Configuration Files](#configuration-files)
- [Environment Variables](#environment-variables)
- [Input Options](#input-options)
- [Output Options](#output-options)
- [Automation and Lifecycle Options](#automation-and-lifecycle-options)
- [Background Jobs](#background-jobs)
- [Exit Codes](#exit-codes)
- [File Locations](#file-locations)
- [Optional Coding-Agent Skills](#optional-coding-agent-skills)
- [Default Values](#default-values)
- [Logging](#logging)
- [Diagnostics](#diagnostics)
- [Supported Platforms](#supported-platforms)
- [Runtime Information](#runtime-information)
- [Generated Reference Files](#generated-reference-files)

## Command-Line Syntax

ULP supports a SQLite-first query form, direct utility commands, interactive interfaces, discovery commands, and help topics.

```text
ulp [global-options] [source-blocks] [query-actions] [output-options]
ulp <command> [command-options]
ulp --menu
ulp --tour[=auto|list|chapter]
ulp --shell
ulp --web [web-options]
ulp --mcp
ulp --help [topic]
```

Common forms:

```powershell
# Query one input through SQLite and print a terminal table.
ulp -i CSV --from .\data.csv --table records `
    --query "SELECT * FROM records LIMIT 20"

# Run a saved query by command tag.
ulp -c.dir

# Export one result to several formats.
ulp --query "SELECT 1 AS id, 'example' AS name" `
    --output file --format CSV --output-file .\out\result.csv `
    --also-pipeline JSON=.\out\result.json

# Stream a direct text search without SQLite.
ulp search timeout .\logs --ignore-case --include "*.log"
```

### Option spelling

Long options use `--name value`, `--name=value`, or, where accepted for compatibility, `--name:value`. Quote values containing whitespace, delimiters, wildcard characters interpreted by the shell, or a leading `-`.

Short aliases include:

- `-i` for `--input`;
- `-q` for `--query`;
- `-f` for `--query-file`;
- `-v` for `--verbose`;
- `-h`, `-?`, `--?` for `--help`;
- `-c.<name>` for a tagged Query library command.

`-c <file-or-pattern>` remains the application-configuration shorthand. It is different from `-c.<name>`.

### Repeated options

These important options are repeatable:

- `--input` begins another source block;
- `--query` and `--query-file` add ordered query actions;
- `--param` adds or replaces named values;
- `--also-pipeline` adds a file output;
- lifecycle SQL/file options append statements in configuration order;
- `--after-arg` appends one argument without invoking a command shell.

Use `--` in `search`, `analyze`, and `ingest` to treat the remaining values as positional sources rather than options.

## Global Options

### Basic source, query, and output options

| Option | Meaning |
| --- | --- |
| `--input`, `-i <provider>` | Begin a provider source block; use `Auto` for bounded detection |
| `--from`, `--source <value>` | Select file/glob, URL, archive entry, channel, or provider-specific source |
| `--detect-format <source>` | Report the detected provider, confidence, and evidence without querying |
| `--table <name>` | Set the SQLite virtual-table name |
| `--query`, `-q <sql>` | Execute SQL after source tables are created |
| `--query-file`, `-f <file>` | Read and execute SQL from a file; wildcards are accepted |
| `--command <name>` | Run a Query library recipe by command tag |
| `--select <expression>` | Set the projection for an automatic query |
| `--where <expression>` | Set the filter for an automatic query |
| `--limit <number>` | Limit an automatic query; default 100 |
| `--output`, `--destination <kind>` | Choose `console`, `file`, `none`, or `text-ui` |
| `--format <writer>` | Choose the result representation |
| `--output-file`, `--out <path>` | Select a file path; filename tokens are accepted |
| `--memory` | Use the default in-memory SQLite database explicitly |
| `--temp-db` | Use a temporary SQLite file deleted on exit |
| `--database`, `--db <value>` | Use a persistent SQLite file or connection string |

### Interactive and display options

| Option | Meaning |
| --- | --- |
| `--menu` | Open the guided menu |
| `--tour[=mode]`, `--showcase[=mode]` | Open the product tour; mode can be `auto`, `list`, or a named chapter |
| `--no-menu` | Override a saved menu startup and show normal help |
| `--startup-mode help\|menu` | Select no-command behavior |
| `--beginner-menu` | Use the focused beginner layout |
| `--advanced-menu` | Include shell, SQLite internals, jobs, and output fan-out |
| `--shell` | Open the SQLite SQL shell directly |
| `--tui` | Open the full-screen query editor without executing; optionally preload `--query`, `--query-file`, or `--command` |
| `--pager[=auto\|always\|never]` | Configure long terminal output paging |
| `--no-pager` | Disable paging for this run |
| `--verbose`, `-v` | Write additional sanitized diagnostics to stderr |
| `--quiet` | Suppress optional status without suppressing results |
| `--silent` | Suppress results and ordinary console status; errors/files/logs remain |
| `--full-errors` | Include sanitized technical error detail |
| `--show-tables` | Show the table catalog during interactive status |
| `--stats` | Write one compact JSON execution summary to stderr |

### Discovery and help options

| Option | Result |
| --- | --- |
| `--list-providers` | Registered input providers and aliases |
| `--list-writers` | Registered destinations/writers and aliases |
| `--list-functions` | Runtime SQL functions and compatibility status |
| `--list-tables` | Tables and views in deterministic order |
| `--list-columns <table>` | Columns in database declaration order |
| `--sqlite-info` | SQLite version, databases, catalog, storage, modules, and functions |
| `--help-provider <name>` | Generated fields/properties for one provider |
| `--help-writer <name>` | Generated properties for one writer |
| `--help <topic>` | Render one manual/help topic |
| `--examples` | Show example commands and queries |
| `--docs [directory]` | Open or locate packaged documentation |
| `--about` | Show product information and website |
| `--version` | Show the ULP version |

Help topics include `general`, `providers`, `writers`, `sqlite`, `query-builder`, `mcp`, `ai`, `ado`, `scriban`, `jobs`, `output`, `configuration`, `examples`, and `advanced`.

### Experimental AI configuration

| Option | Meaning |
| --- | --- |
| `--ai` / `--no-ai` | Explicitly enable or disable the shared chat configuration |
| `--ai-base-url <url>` | Compatible Chat Completions API base; remote URLs require HTTPS |
| `--ai-model <name>` | Model supported by the selected provider |
| `--ai-key <reference>` | Prefer `@env:NAME`, `@file:PATH`, or `@wincred:TARGET` |
| `--ai-timeout <seconds>` | Request timeout, 1–600 seconds; default 60 |
| `--help-ai` | Configuration, secret handling, privacy, and review workflow |

Use the same switches in an explicit `.config` file, or configure **Options → AI settings** in the menu. Saved menu settings accept key references only, not literal keys. SQL shell commands are `.ai question`, `.ai-run`, `.ai-clear`, and `.ai-config`. AI remains opt-in and never executes a proposal automatically. See [AI configuration and safety](ai.md) before enabling a provider.

For external agents, `ulp --mcp` exposes `CreateSession`, `ListSessions`, `CloseSession`, and `GetRuntimeInfo`. Initialization and the `ulp://runtime` resource advertise the exact CLI, Query library, and packaged-skill paths; `ulp://skills/{name}`, `ListAgentSkills`, and `GetAgentSkill` expose the relevant operating instructions. Pass `sessionId` on each stateful tool call for independent work. These sessions isolate SQLite state, not account/file permissions. See [MCP session guidance](ai.md#independent-agent-sessions).

## Commands

### SQLite-first query workflow

The normal `ulp` form turns providers into SQLite virtual tables, runs ordered SQL, and sends results through selected writers. This remains the primary workflow.

```powershell
ulp --input EVT --from System --table events `
    --query "SELECT EventID, SourceName, TimeGenerated FROM events LIMIT 25"
```

### `search`

Streams literal or regular-expression text search without creating SQLite tables.

```text
ulp search <text> <source...> [options]
ulp search --regex <pattern> <source...> [options]
```

| Option | Meaning/default |
| --- | --- |
| `--regex <pattern>` | Regular expression instead of literal text |
| `--stdin` | Include standard input |
| `-i`, `--ignore-case` | Ordinal case-insensitive matching |
| `--case-sensitive` | Case-sensitive matching; default |
| `-r`, `--recursive` / `--no-recursive` | Recurse by default or stop at one level |
| `--include <glob>` / `--exclude <glob>` | Repeatable relative-path filters |
| `--no-default-excludes` | Include common build/dependency directories |
| `-B`, `-A`, `-C <n>` | Before, after, or symmetric context lines |
| `-m`, `--limit <n>` | Maximum matches; default 1000 |
| `--max-line-length <n>` | Retained characters per line; default 1,048,576 |
| `--regex-timeout-ms <n>` | Per-line regular-expression timeout; default 2000 |
| `--format text\|json\|jsonl` | Deterministic output; default text |
| `--require-match` | Exit 4 when there is no match |
| `--quiet-match` | Do not print matches |
| `--ignore-errors` | Continue past unreadable sources |
| `--stats` | Print scan statistics to stderr |
| `--include-binary` | Attempt decoding sources containing NUL bytes |

### `analyze`

Streams bounded text statistics without SQLite. Its `auto` parser reports heuristic content shape, not parsed structured fields.

```text
ulp analyze <source...> [options]
command | ulp analyze --stdin [options]
```

| Option | Meaning/default |
| --- | --- |
| `--stdin` | Include standard input |
| `--parser auto\|text` | Heuristic label plus text analysis, or explicit text; default auto |
| `--normalize-lines none\|log-template` | Normalize repeated-line keys; default none |
| `-r`, `--recursive` / `--no-recursive` | Recurse by default or stop at one level |
| `--include <glob>` / `--exclude <glob>` | Repeatable relative-path filters |
| `--no-default-excludes` | Include common build/dependency directories |
| `--include-binary` | Attempt text decoding for NUL-containing sources |
| `--ignore-errors` | Continue after unreadable sources |
| `--max-line-length <n>` | Retained characters per line; default 1,048,576 |
| `--top <n>` | Repeated nonempty lines; default 10; 0 disables |
| `--max-distinct-lines <n>` | Repeated-line tracking bound; default 10,000 |
| `--max-top-line-length <n>` | Retained repeated-line text; default 512 |
| `--format text\|json` | Summary format; default text |
| `--require-content` | Exit 4 when no text line was analyzed |

### `ingest`

Streams provider rows into an ordinary table in a persistent SQLite database.

```text
ulp ingest <source...> --parser <provider> --db <file> --table <name> [options]
```

The default creates a new table and fails if it exists. `--append` requires a compatible schema; `--replace` replaces transactionally. `--index <column[,column]>` is repeatable. Table data, the ingest ledger, and the source manifest commit as one transaction, so failure or Ctrl+C rolls back the run.

Important controls are `--batch-size` (default 1000), `--input-options`, typed `--input.<property>`/`--i.<property>`, `--input-config`, `--config-dir`, `--use-factory-defaults`, `--no-migrate`, `--format text|json`, and `--quiet`. Compatible analysis-database migrations run automatically; `--no-migrate` refuses the operation when the database is not current.

### `db info`

Inspects, initializes, or upgrades a persistent ULP analysis database.

```text
ulp db info <sqlite-file> [--no-migrate] [--format text|json]
```

The default behavior initializes an ordinary SQLite file as a ULP analysis database or applies every compatible migration in one transaction. Existing user tables and rows are preserved. `--no-migrate` performs read-only ULP metadata inspection: an ordinary SQLite database is reported as uninitialized, and an older compatible ULP database is reported as requiring migration. Future schema versions are rejected so an older ULP executable cannot accidentally modify them.

The report includes the database schema version, runtime and parser versions, created/updated UTC timestamps, applied migration ledger, ingest/source-manifest counts, and table names. Use `--format json` for automation.

### `ado`

Runs commands against a registered ADO.NET provider and sends every result set through the normal output pipeline.

```text
ulp ado providers
ulp ado query --provider <name> --connection <string> --query <sql> [options]
```

The documented providers are:

| Name | Aliases | Notes |
| --- | --- | --- |
| `SQLite` | `sqlite3` | Direct SQLite database access without creating `ParsingModule` tables |
| `SqlServer` | `mssql`, `sql-server` | Microsoft SQL Server through the Windows/.NET Framework provider |
| `OleDb` | `ole-db` | Uses an OLE DB provider already installed on the Windows computer |

Use `--query`/`--sql` or `--query-file`, ordered `--param NAME=VALUE`, and the normal writer controls. `--also-output FORMAT=FILE` adds file pipelines. Scriban controls include `--template`, `--template-file`, `--template-files`, and `--template-dir`.

ULP retains `GO` script splitting, `#name#` constants from `--define`, cancellation, multiple result sets, fan-out, statistics, and overwrite protection. Values passed with `--param` become native command parameters rather than SQL text. Provider SQL dialects still apply: SQLite-only compatibility functions and `ParsingModule` are not added to SQL Server or OleDb, and OleDb parameters may be positional even when a command uses names.

Connection strings may contain credentials. Prefer integrated authentication or secret references; ULP masks recognized values in errors and omits the connection string from normal results/statistics. ULP does not install a database server, an OLE DB driver, or a commercial connector. Verify drivers, authentication, network access, and provider SQL in the deployment environment. See the [generated ADO.NET reference](reference/generated/ado-net-reference.md).

### Interactive services

| Command | Purpose |
| --- | --- |
| `ulp --menu` | Guided console workflow |
| `ulp --shell` | Interactive SQLite SQL buffer/shell |
| `ulp --web` | Optional local browser interface |
| `ulp --mcp` | Long-running stdio MCP server |

The web and MCP modes are services rather than one-shot queries. Their security and client setup are documented in [User Interface](user-interface.md), [Deployment and Packaging](deployment.md#mcp-deployment), and the [generated MCP reference](reference/generated/mcp-reference.md).

## Source Blocks

Every `--input` starts a new source block. The following `--from`, `--table`, `--input-config`, `--input-options`, and input-property switches belong to that block until the next `--input`.

```powershell
ulp --input EVT --from System --table events `
    --input CSV --from .\owners.csv --table owners `
    --query "SELECT e.EventID, o.Owner FROM events e LEFT JOIN owners o ON e.EventID=o.EventID"
```

When `--table` is omitted, ULP creates a provider-aware collision-free name such as `tEvt1` or `tCsv1`. Explicit names are recommended for saved SQL.

File-based providers expand source lists lazily. Lists may contain comma/semicolon-separated paths, glob patterns, `!` exclusions, and `archive|entry-glob` forms. See [File and Stream Source Syntax](inputs-and-outputs.md#file-and-stream-source-syntax).

## Query Syntax

### Ordered actions

`--query` and `--query-file` may be repeated and run in command-line order. Query-file wildcards expand in case-insensitive lexical order.

```powershell
ulp --query-file '.\sql\01-*.sql' `
    --query "INSERT INTO work VALUES (3)" `
    --query-file '.\sql\02-*.sql'
```

With shared connection scope, tables created by one action are available to later actions. `--connection-scope query` reopens the database and recreates configured provider tables between top-level actions.

### Automatic SELECT builder

When no explicit query is supplied, ULP creates one query per configured table. These options shape it:

| Option | SQL part |
| --- | --- |
| `--select <expression>` | `SELECT` projection |
| `--where <expression>` | `WHERE` |
| `--group-by <expression>` | `GROUP BY` |
| `--having <expression>` | `HAVING` |
| `--order-by <expression>` | `ORDER BY` |
| `--limit <n>` | `LIMIT` |
| `--offset <n>` | `OFFSET` |
| `--distinct` | `SELECT DISTINCT` |

Reusable query-builder properties also use `--query.<property> <value>`.

### SQL parameters

Bind named SQLite parameters without text replacement:

```powershell
ulp -i CSV --from .\events.csv --table events `
    --query 'SELECT * FROM events WHERE Severity=@level' `
    --param level=Error
```

Accepted property forms are `--param NAME=VALUE`, `--param.NAME <value>`, and `--p.NAME <value>`. SQL may use `@NAME`, `:NAME`, or `$NAME`. Parameter binding protects the value boundary; identifiers such as table or column names cannot be supplied as ordinary parameters.

### ParsingModule

ULP normally creates provider virtual tables for you. Manual SQL can use:

```sql
CREATE VIRTUAL TABLE events
USING ParsingModule('System', '-i:EVT -Direction:BACKWARD');
```

Provider default configuration is discovered outside this SQL. Generated table statements do not embed a local defaults-file path.

### Cancellation

Press Ctrl+C to cancel a running foreground query. ULP propagates cancellation through query execution and supported writers, cleans incomplete staged output, and returns exit code 130 for CLI cancellation.

## Query Library

The Query library scans `*.sql` recursively. Select its root with `--queries-dir`, `ULP_QUERIES_DIR`, or the persistent interactive setting. Leading SQL comments can describe a reusable recipe:

```sql
-- title: Recent errors
-- description: Show recent Windows error events.
-- command: errors
-- provider: EVT
-- source: System
-- table: events
-- input-options: -Direction:BACKWARD
-- default-format: Terminal
-- default-destination: console
-- parameter: minimum_level=2
SELECT * FROM events WHERE Level=@minimum_level LIMIT 100;
```

Run it with:

```powershell
ulp -c.errors --param minimum_level=3
ulp --command errors --param minimum_level=3
```

An explicit CLI source/output option overrides recipe metadata. Duplicate command tags and malformed metadata are reported with their file locations.

## Web HTTP API

ULP's browser application uses a JSON HTTP API that is also available to scripts and other applications while `ulp --web` is running. It is not a second service: API clients use the same Query library, permission policy, row limit, SQLite behavior, and per-session state as the packaged browser application.

The current route prefix is `/api`. Use the [Web interface guide](user/WEB.md) for interactive startup and [Web Interface Security](security.md#web-interface-security) before exposing a listener beyond localhost.

### Start an API server

For a copy-ready loopback demonstration:

```powershell
$env:ULP_WEB_PASSWORD = 'replace-with-a-strong-password'
ulp --web --web-bind localhost --web-port 8088 --web-http `
  --web-user api-user --web-password @env:ULP_WEB_PASSWORD `
  --web-mode full --web-max-rows 5000
```

This deliberately uses HTTP only on loopback so a first API call does not require trusting a development certificate. Do not use this form across a network. For routine automation, use HTTPS with a trusted PFX or certificate-store thumbprint:

```powershell
$env:ULP_CERT_PASSWORD = 'replace-with-the-PFX-password'
ulp --web --web-bind 192.168.1.20 --web-port 8443 --web-https `
  --web-certificate C:\Certificates\ulp.pfx `
  --web-certificate-password @env:ULP_CERT_PASSWORD `
  --web-user api-user --web-password @env:ULP_WEB_PASSWORD `
  --web-mode query-runner --web-max-rows 5000
```

Without an explicit certificate, ULP creates a temporary self-signed certificate. Use a trusted certificate for unattended clients and all LAN/remote use; do not disable certificate validation in production automation.

`--web-mode` controls the available API operations:

| Mode | Saved query list/run | Query source | Ad-hoc SQL | Create/edit/delete |
| --- | ---: | ---: | ---: | ---: |
| `full` | Yes | Yes | Yes | Yes |
| `query-runner` | Yes | No | No | No |
| `read-only` | Yes | Yes | No | No |
| `no-source` | Yes | No | No | No |

The switches `--web-no-query-source`, `--web-no-adhoc`, `--web-no-edit`, `--web-no-shell`, and `--web-no-ai` can remove permissions from the selected mode. Always read `/api/server` instead of assuming that a browser button or endpoint is available.

### Authentication and common headers

When authentication is configured, send HTTP Basic authentication on every request. Basic authentication protects access, but HTTPS provides confidentiality.

| Header | When to send | Meaning |
| --- | --- | --- |
| `Authorization: Basic ...` | Every request when authentication is enabled | Web username and password |
| `Accept: application/json` | Every API request | Request a JSON response |
| `Content-Type: application/json` | Requests with a JSON body | Describe the body |
| `X-ULP-Request: 1` | Every non-GET API request | Required application-request check; omission returns 403 |
| `X-ULP-Session: <id>` | Session-based requests only | Share one SQLite session; omission selects `default`; stateless routes reject this header |
| `X-ULP-Operation: <guid>` | A query or Shell request that may be cancelled | Correlate the running request with `/api/cancel` |

This PowerShell setup is reused by the examples below:

```powershell
$baseUrl = 'http://localhost:8088'
$session = 'automation-example'
$credentials = [Convert]::ToBase64String(
  [Text.Encoding]::UTF8.GetBytes("api-user:$env:ULP_WEB_PASSWORD"))

$headers = @{
  Authorization   = "Basic $credentials"
  Accept          = 'application/json'
  'X-ULP-Session' = $session
}
$writeHeaders = $headers.Clone()
$writeHeaders['X-ULP-Request'] = '1'
```

PowerShell 7 can use `-Authentication Basic -Credential` instead. Protect credentials as secrets and do not write the expanded `Authorization` value to logs.

### Sessions and operations

All Query-library runs, ad-hoc SQL, Shell SQL, schema discovery, and AI schema context with the same `X-ULP-Session` value share one SQLite connection. This allows one call to create a temporary or virtual table and a later call to query it. Different session IDs have independent connection-local state, and operations in one session are serialized.

Session IDs are case-sensitive, may contain letters, digits, `-`, and `_`, and may be at most 80 characters. The server accepts at most 64 active sessions. Omitting the header uses the shared `default` session. Close sessions you create with `POST /api/session/close`.

A session is a state boundary, not an account, authorization, or filesystem-security boundary. Every session still runs with the web-server process identity and the server's configured permissions.

For cancelable endpoints, generate a GUID, send it as `X-ULP-Operation`, and retain it until the request completes. A simultaneous `POST /api/cancel` request with that GUID asks SQLite and the active operation to stop. Operation IDs may not be reused while still active.

### Session-based versus stateless execution

ULP provides both models. Choose explicitly rather than relying on an omitted session header:

| Behavior | Session-based routes | Stateless routes |
| --- | --- | --- |
| Saved query | `POST /api/query/run` | `POST /api/stateless/query/run` |
| Ad-hoc SQL | `POST /api/query/adhoc` | `POST /api/stateless/query/adhoc` |
| SQLite connection | Reused by one session ID | New connection for every request |
| `X-ULP-Session` | Optional; omission uses `default` | Rejected with 400 |
| Temporary/virtual tables | Available to later calls in the same session | Available only inside that request's SQL script |
| Initialization | Once when the session connection opens | On every request |
| Cleanup | On session close or server shutdown | Before the request connection is disposed |
| Best fit | Browser workspaces, multi-step analysis, AI schema context | Independent service calls, jobs, webhooks, and horizontally simple clients |

Both paths apply the same authentication, permission checks, Query-library preparation, SQL preprocessing, named parameters, configured sources, lifecycle SQL, checkpoint transaction, returned-row limit, result format, logging, and cancellation. Stateless calls do not create entries in the Web session pool and do not require `/api/session/close`.

Stateless means connection-local state is discarded. It does **not** roll back successful writes to a persistent database, undo file/provider side effects, or erase committed checkpoint files. A successful multi-statement request can create a temporary table and query it later in that same SQL script, but a later stateless request receives a new connection. Initialization on every call also costs more than reusing a session, especially when it creates expensive virtual tables.

### Discover server capabilities

```powershell
$server = Invoke-RestMethod -Uri "$baseUrl/api/server" -Headers $headers
$server.permissions
```

`GET /api/server` returns the server name, access mode, read-only status, HTTPS/authentication flags, maximum returned rows, permission map, advertised stateless endpoint paths, Shell availability, and Experimental AI availability/model/base URL. It never returns passwords, API keys, certificate secrets, or connection strings.

### Endpoint reference

Query-string `id` values are Query-library-relative IDs and must be URL-encoded. The server rejects rooted paths and traversal outside the configured library.

| Method and path | Required permission | Request / result |
| --- | --- | --- |
| `GET /api/server` | No additional feature permission | Server capability and permission object |
| `GET /api/queries` | View Query library | Array of query summaries; source is omitted |
| `GET /api/query?id=<id>` | View Query library | One query summary; source is included only with source permission |
| `POST /api/query/run?id=<id>` | Run saved queries | Parameters and optional unsaved SQL override; query result |
| `POST /api/query/adhoc` | Run ad-hoc SQL | SQL and parameters; query result |
| `POST /api/stateless/query/run?id=<id>` | Run saved queries | Connection-per-request saved query; same body/result as session route |
| `POST /api/stateless/query/adhoc` | Run ad-hoc SQL | Connection-per-request SQL; same body/result as session route |
| `POST /api/query` | Create queries | New saved-query metadata/source; 201 summary |
| `PUT /api/query?id=<id>` | Edit queries | Updated `Source`; query summary |
| `DELETE /api/query?id=<id>` | Delete queries | No body; 204 on success |
| `POST /api/query/duplicate?id=<id>` | Create queries | New `Id`; 201 summary |
| `POST /api/shell` | Execute Shell commands | Safe ULP/SQLite command; message and optional result |
| `POST /api/ai` | Use AI and configured AI service | Conversation request; generated SQL and explanation |
| `POST /api/cancel` | Authenticated application request | Operation ID; `cancelled` is `true` or `false` |
| `POST /api/session/close` | Authenticated application request | Close the selected session; 204 |

### List and read saved queries

```powershell
$queries = Invoke-RestMethod -Uri "$baseUrl/api/queries" -Headers $headers
$queries | Select-Object Id, Folder, Title, Description, Provider

$queryId = [Uri]::EscapeDataString('files/directory-summary')
$query = Invoke-RestMethod -Uri "$baseUrl/api/query?id=$queryId" -Headers $headers
```

A query summary contains `Id`, `Folder`, `Category`, `Title`, `Description`, `Commands`, `Provider`, `Parameters`, and `Source`. `Source` is `null` when the server does not permit source viewing.

### Run a saved query

Parameter overrides must name parameters declared by that saved query. They are bound values, not SQL text substitution.

```powershell
$body = @{
  Parameters = @{
    extension = '.log'
    minimum_bytes = '1024'
  }
} | ConvertTo-Json -Depth 5

$result = Invoke-RestMethod -Method Post `
  -Uri "$baseUrl/api/query/run?id=$queryId" `
  -Headers $writeHeaders -ContentType 'application/json' -Body $body
```

In `full` mode, `Sql` may be included to run an unsaved edit of the selected saved query while retaining its metadata and data-source setup:

```json
{
  "Sql": "SELECT Extension, COUNT(*) AS Files FROM files GROUP BY Extension;",
  "Parameters": {}
}
```

An SQL override also requires the ad-hoc-query permission. Saving the query first is not required.

### Run ad-hoc SQL

```powershell
$body = @{
  Sql = 'SELECT @message AS Message, sqlite_version() AS SQLiteVersion;'
  Parameters = @{ message = 'Hello from the ULP API' }
} | ConvertTo-Json -Depth 5

$result = Invoke-RestMethod -Method Post `
  -Uri "$baseUrl/api/query/adhoc" `
  -Headers $writeHeaders -ContentType 'application/json' -Body $body
```

### Run a stateless query

Do not copy `$writeHeaders` for this call because that object contains `X-ULP-Session`. Build a request header set without the session header:

```powershell
$statelessHeaders = @{
  Authorization   = "Basic $credentials"
  Accept          = 'application/json'
  'X-ULP-Request' = '1'
}

$body = @{
  Sql = 'SELECT @message AS Message, sqlite_version() AS SQLiteVersion;'
  Parameters = @{ message = 'Independent request' }
} | ConvertTo-Json -Depth 5

$result = Invoke-RestMethod -Method Post `
  -Uri "$baseUrl/api/stateless/query/adhoc" `
  -Headers $statelessHeaders -ContentType 'application/json' -Body $body
```

Run a saved query through an independent connection by sending the same parameter body used by the session route:

```powershell
$body = @{ Parameters = @{ extension = '.log'; minimum_bytes = '1024' } } |
  ConvertTo-Json -Depth 5

$result = Invoke-RestMethod -Method Post `
  -Uri "$baseUrl/api/stateless/query/run?id=$queryId" `
  -Headers $statelessHeaders -ContentType 'application/json' -Body $body
```

The saved route still permits an unsaved `Sql` override only when the server grants ad-hoc-query permission. Add an `X-ULP-Operation` GUID when the call must be cancelable; `/api/cancel` works identically for session and stateless operations.

The query result has this shape:

```json
{
  "QueryId": "adhoc",
  "QueryTitle": "Ad-hoc query",
  "RowCount": 1,
  "Truncated": false,
  "DurationMilliseconds": 2.4,
  "Tables": [
    {
      "Name": "Result 1",
      "Columns": [
        { "Name": "Message", "Type": "String" },
        { "Name": "SQLiteVersion", "Type": "String" }
      ],
      "Rows": [["Hello from the ULP API", "3.x"]]
    }
  ]
}
```

Multiple SQL result sets appear as separate entries in `Tables`. A database `NULL` is JSON `null`. `RowCount` is the number of rows returned after the web row limit, not a count of every matching source row. When `Truncated` is `true`, narrow the query or raise the deliberate `--web-max-rows` limit; a returned-row limit does not make an unbounded source scan inexpensive.

### Create, edit, duplicate, and delete saved queries

Create a query:

```json
POST /api/query
{
  "Id": "team/recent-errors",
  "Title": "Recent errors",
  "Description": "Bounded error report for automation.",
  "Source": "SELECT * FROM events WHERE Level <= 2 LIMIT 100;"
}
```

Update its SQL source:

```json
PUT /api/query?id=team%2Frecent-errors
{
  "Source": "SELECT TimeGenerated, SourceName, Message FROM events WHERE Level <= 2 LIMIT 50;"
}
```

Duplicate it with `POST /api/query/duplicate?id=team%2Frecent-errors` and body `{ "Id": "team/recent-errors-copy" }`. Delete it with `DELETE /api/query?id=team%2Frecent-errors`. All non-GET calls require `X-ULP-Request: 1`; create and duplicate return 201, while successful delete returns 204.

### Use the safe Shell endpoint

```powershell
$body = @{ Command = '.tables'; Parameters = @{} } | ConvertTo-Json -Depth 5
$shell = Invoke-RestMethod -Method Post -Uri "$baseUrl/api/shell" `
  -Headers $writeHeaders -ContentType 'application/json' -Body $body
```

The Shell accepts `.help`, `.tables`, `.schema NAME`, `.info`, `.run QUERY_ID`, `.clear`, and SQLite SQL. It does not run operating-system commands. The response contains `Message` and, for commands that produce tabular data, `Result` in the query-result shape above.

### Cancel a request and close the session

Cancellation is a second request made while the original operation is still running:

```http
POST /api/cancel
X-ULP-Request: 1
X-ULP-Session: automation-example
Content-Type: application/json

{ "OperationId": "8e51aa37-cdd0-4f6e-a6fd-411711d270d5" }
```

The original saved-query, ad-hoc, or Shell request must have carried the same GUID in `X-ULP-Operation`. A canceled operation returns HTTP 499 with a JSON error.

Release connection-local state when the client finishes:

```powershell
Invoke-RestMethod -Method Post -Uri "$baseUrl/api/session/close" `
  -Headers $writeHeaders -ContentType 'application/json' -Body '{}'
```

### Experimental AI endpoint

`POST /api/ai` is **Experimental** and is available only when the server was started with AI enabled and the active policy permits it.

```json
{
  "Message": "Write a bounded query that groups the current files by extension.",
  "Messages": [
    { "Role": "user", "Content": "Use only tables in the current session." }
  ]
}
```

The response contains `Message`, `Sql`, and `Model`. ULP supplies a bounded description of the active session's schema to the configured provider; generated SQL is returned for review and is never executed automatically. An unconfigured AI service returns 503. See [AI Features](ai.md) for privacy and provider guidance.

### Errors and client rules

API failures use a JSON body such as `{ "error": "The saved query was not found." }`. Common statuses are:

| Status | Meaning |
| ---: | --- |
| 400 | Invalid JSON, missing ID, invalid parameter, session ID, or operation ID |
| 401 | Basic authentication required or rejected |
| 403 | Permission denied or missing `X-ULP-Request: 1` on a non-GET request |
| 404 | Query or endpoint not found |
| 499 | Request canceled |
| 500 | Request failed; sanitized response, details in the ULP log |
| 503 | Experimental AI requested but unavailable |

ULP does not enable cross-origin browser access. Browser JavaScript should be served from the same ULP origin or from a same-origin trusted reverse proxy. Native applications, PowerShell, and command-line HTTP clients are not subject to browser CORS enforcement.

Treat API access as direct access to the data available to the ULP server account. Use HTTPS, least-permissive web modes, bounded SQL, explicit sessions, protected secrets, and operating-system permissions on inputs, outputs, the Query library, configuration, and logs.

## SQLite Connections

Connection modes are mutually exclusive:

| Mode | Option | Lifetime |
| --- | --- | --- |
| Memory | default or `--memory` | Current process/connection |
| Temporary file | `--temp-db` | Deleted after ULP closes it |
| Persistent file | `--database <path>` | Remains at the selected path |
| Complete SQLite connection | `--connection <string>` | According to connection-string settings |

`--connection-scope shared` is the default. `--connection-scope query` isolates top-level actions but prevents an in-memory table created by one action from being used by the next.

Use SQL such as `CREATE TABLE ... AS SELECT ...` or `INSERT INTO ... SELECT ...` to materialize provider rows into an ordinary SQLite table.

## Configuration

Configuration is layered. For application options, later values override earlier scalar values:

1. built-in defaults;
2. `<config-dir>/defaults.ulp.config`;
3. files selected by `--config`/`-c`;
4. `ULP_*` environment settings;
5. command-line arguments.

Source blocks and query actions are additive rather than one scalar setting. `--no-env` skips environment configuration for a hermetic run.

### Choose a configuration method

| Need | Recommended method | Example |
| --- | --- | --- |
| One command or experiment | Command-line options | `ulp -i CSV --from .\data.csv --query "SELECT * FROM tCsv1 LIMIT 20"` |
| Repeatable job checked in with scripts | Named `.config` file | `ulp --config .\jobs\daily.config --no-env` |
| Personal interactive defaults | `<config-dir>\defaults.ulp.config` and `settings.config` | pager, menu mode, default writer |
| Shared provider defaults | `defaults.input.<TYPE>.config` | CSV encoding/delimiter or EVT direction |
| Shared writer defaults | `defaults.output.<TYPE>.config` | JSON indentation or HTML styling |
| Managed machine/deployment | `ULP_*` environment variables plus protected config files | central Query library and log paths |
| Agent or CI run that must ignore ambient settings | Explicit options plus `--no-env` | stable output and exit conditions |

Start with the CLI until the command is correct, then generate a configuration file instead of copying a long command into many scripts:

```powershell
ulp --generate-app-config .\config\daily-errors.config
ulp --config .\config\daily-errors.config --no-env
```

Inspect available settings before editing a file:

```powershell
ulp --help
ulp --list-providers
ulp --help-provider CSV
ulp --list-writers
ulp --help-writer JSON
```

Use `--config-dir` to move automatic defaults and interactive settings together. The default is the `config` subdirectory under the current working directory, not the working directory itself:

```powershell
ulp --config-dir C:\ProgramData\ULP\config --menu
```

Keep secrets out of ordinary `.config` files. Put `@env:`, `@file:`, or `@wincred:` references in the file and protect the referenced value separately.

Provider/writer properties have their own layering:

1. factory defaults;
2. `defaults.input.<TYPE>.config` or `defaults.output.<TYPE>.config`;
3. explicit `--input-config` or `--output-config`;
4. raw and typed properties supplied for the block/pipeline.

`--use-factory-defaults` disables automatic provider default discovery but still honors an explicit provider configuration file.

## Configuration Files

Configuration files contain command-line-style tokens. Lines beginning with `#` are comments.

```text
# config/defaults.ulp.config
--beginner-menu
--startup-mode="Help"
--pager="Auto"
--format="Markdown"
```

Provider and writer files contain properties scoped by their filename:

```text
# config/defaults.input.EVT.config
-Direction:BACKWARD
-FormatMsg:ON
```

Generate complete editable files:

```powershell
ulp --generate-input-config EVT
ulp --generate-output-config JSON
ulp --generate-app-config .\config\job.config
```

Use `--config-output <path>` to choose the generated target. Existing files are preserved unless `--overwrite-config` explicitly authorizes replacement.

Typed namespaces accepted by application files and CLI include:

```text
--input.ReverseDirection true
--i.EVT.IncludeMessage Never
--output.IndentJson true
--o.IncludeMetadata true
--w.JSON.IndentJson true
--query.OrderBy "TimeCreated DESC"
```

## Environment Variables

### Scalar settings

| Variable | Option |
| --- | --- |
| `ULP_DATABASE` | `--database` |
| `ULP_CONNECTION` | `--connection` |
| `ULP_CONNECTION_SCOPE` | `--connection-scope` |
| `ULP_OUTPUT` / `ULP_DESTINATION` | `--output` / `--destination` |
| `ULP_FORMAT` | `--format` |
| `ULP_OUTPUT_FILE` | `--output-file` |
| `ULP_OUTPUT_CONFIG` | `--output-config` |
| `ULP_CONFIG_DIR` | `--config-dir` |
| `ULP_QUERIES_DIR` | `--queries-dir` |
| `ULP_GROK_PATTERNS_DIR` | `--grok-patterns-dir` |
| `ULP_QUERY` / `ULP_QUERY_FILE` | `--query` / `--query-file` |
| `ULP_MAX_BACKGROUND_JOBS` | `--max-background-jobs` |
| `ULP_LOG_FILE` | `--log-file` |
| `ULP_LOG_MAX_SIZE_MB` | `--log-max-size-mb` |
| `ULP_LOG_RETAIN_DAYS` | `--log-retain-days` |
| `ULP_STARTUP_MODE` | `--startup-mode` |
| `ULP_PAGER` | `--pager` |
| `ULP_SESSION_INIT_SQL` | `--session-init-sql` |
| `ULP_BEFORE_QUERY_SQL` | `--before-query-sql` |
| `ULP_AFTER_QUERY_SQL` | `--after-query-sql` |
| `ULP_SESSION_CLEANUP_SQL` | `--session-cleanup-sql` |
| `ULP_WEB_AI_BASE_URL` | `--web-ai-base-url` |
| `ULP_WEB_AI_KEY` | `--web-ai-key` |
| `ULP_WEB_AI_MODEL` | `--web-ai-model` |
| `ULP_WEB_AI_TIMEOUT` | `--web-ai-timeout` |

### Boolean settings

True values for these variables enable their corresponding flag:

`ULP_VERBOSE`, `ULP_QUIET`, `ULP_STATS`, `ULP_REQUIRE_ROWS`, `ULP_NO_OUTPUT_IF_EMPTY`, `ULP_SHOW_TABLES`, `ULP_FULL_ERRORS`, `ULP_WEB_AI`, `ULP_SILENT`, `ULP_LOG`, `ULP_NO_LOG`, `ULP_ADVANCED_MENU`, `ULP_BEGINNER_MENU`, and `ULP_NO_PAGER`.

### Hierarchical settings

Double underscores map nested properties:

```powershell
$env:ULP_INPUT__Direction = 'BACKWARD'
$env:ULP_OUTPUT__IndentJson = 'OFF'
$env:ULP_QUERY__FilterDate = 'Last24Hours'
$env:ULP_ARGS = '--require-rows --stats'
```

`ULP_ARGS` is tokenized as additional application arguments. Treat control of this variable as equivalent to control of the ULP command line.

### Secret references

An option's complete value may be:

- `@env:NAME` — environment variable;
- `@file:path` — secret file with final line endings removed;
- `@wincred:target` — current user's Generic Windows credential.

ULP resolves references in memory and masks recognized secrets in displayed connection strings/errors. This does not make an arbitrary result column secret; avoid selecting credentials into output.

## Input Options

Use generated provider help for exact fields and writable properties:

```powershell
ulp --list-providers
ulp --help-provider CSV
```

Property forms:

| Form | Scope |
| --- | --- |
| `--input-options <text>` | Raw Log Parser-style property string for current block |
| `--input.<property> <value>` | Canonical typed property |
| `--i.<property> <value>` | Short typed property |
| `--i.<TYPE>.<property> <value>` | Provider-qualified short property |
| `--input-config <file>` | Explicit current-block configuration |
| `--input-default.<property> <value>` | Default applied to source blocks where supported |

Boolean values accept conventional forms such as true/false, ON/OFF, and 1/0 where the property type permits them. Quote values containing spaces.

## Output Options

Discover actual registered writers at runtime:

```powershell
ulp --list-writers
ulp --help-writer Excel
```

| Option | Meaning |
| --- | --- |
| `--output`, `--destination <kind>` | `console`, `file`, `none`, or `text-ui` |
| `--format <writer>` | Result representation |
| `--output-file`, `--out <path>` | Required for File destination |
| `--output-config <file>` | Explicit writer settings |
| `--output-options <text>` | Raw writer property string |
| `--output.<property> <value>` | Canonical typed writer property |
| `--o.<property>`, `--w.<property>` | Short typed forms |
| `--w.<FORMAT>.<property>` | Writer-qualified typed form |
| `--also-pipeline FORMAT=FILE` | Repeatable secondary file output |
| `--no-output-if-empty` | Preserve target when no rows are written |
| `--no-overwrite` | Refuse an existing target |

Output filenames support .NET date/time tokens plus aliases `{date}`, `{datetime}`, and the first-free counter `{n}`. Background output also supports `{JobId}`.

Standard output contains result data. Diagnostics and `--stats` use standard error, allowing data to be redirected or piped independently.

## Automation and Lifecycle Options

### Result gates

| Option | Behavior |
| --- | --- |
| `--require-rows` | Exit 4 unless at least one result row exists |
| `--expect-scalar <value>` | Exit 4 unless first row/column exactly matches invariant text |
| `--condition-query <sql>` | Run a scalar condition after the main batch |
| `--require-condition` | Exit 4 when the condition is false |
| `--output none` | Execute and collect metrics without result rendering |

### SQL lifecycle

Execution order:

1. `--session-init-sql` / `--session-init-file` once after connection open;
2. provider table creation;
3. `--before-query-sql` / `--before-query-file` before each user query;
4. user query and all outputs;
5. `--after-query-sql` / `--after-query-file` after a fully successful query/output;
6. `--session-cleanup-sql` / `--session-cleanup-file` once before close.

All lifecycle options are repeatable. Named SQL parameters are available to hooks. Failures fail the affected query/session; cleanup is still followed by deterministic connection disposal.

### Recurring queries and live tail

| Option | Behavior |
| --- | --- |
| `--every <duration>` | Repeat while the foreground process remains attached; accepts values such as `500ms`, `30s`, `5m`, or `2h` |
| `--interval <duration>` | Alias for `--every` |
| `--cron <expression>` | Repeat on a five-field calendar schedule: minute, hour, day of month, month, day of week |
| `--cron-time-zone <id>` | Evaluate cron in this timezone; default is local, and `UTC` is accepted explicitly |
| `--run-now` | Run once immediately before waiting for the first cron occurrence |
| `--runs <number>` | Stop after this many attempted runs; omit to continue until Ctrl+C |
| `--wait-first` | Wait one interval before the first run |
| `--continue-on-error` | Continue with the next interval after a failed run |
| `--tail` | Poll one local TextLine file and query only newly completed lines; default interval is one second |
| `--tail-existing` | Include current complete lines on the first tail run |

Recurring output paths support `{RunNumber}`, starting at 1. `--cron` supports wildcards, lists, increasing ranges, steps, numeric fields, and English three-letter month/day names. When day-of-month and day-of-week are both restricted, either may match. A nonexistent spring-forward local minute is skipped; both UTC instants represented by a repeated fall-back local minute can match. The advanced interactive menu manages application-scoped fixed-interval schedules with status, pause, resume, cancellation, and optional run limits. A running schedule completes its current query before pausing; a cancelled schedule propagates cancellation to it. Waiting and paused schedules consume no query worker, and one schedule never overlaps itself.

Tail mode uses a private in-memory checkpoint, skips existing lines unless requested, and withholds an unfinished trailing line. It is limited to one seekable local TextLine file. Interval, cron, and tail runs all end when the process exits and are not durable service schedulers.

### Post-actions

`--after <executable>` starts a program directly after the selected condition. It does not invoke an implicit shell. Add arguments with repeated `--after-arg`; select `success`, `rows`, `empty`, `file`, or `condition` through `--after-when`. Default timeout is 300 seconds and is configurable with `--after-timeout`.

The child receives:

- `ULP_ROWS`;
- `ULP_RESULT_SETS`;
- `ULP_FIRST_VALUE`;
- `ULP_OUTPUT_FILE`;
- `ULP_CONDITION`.

Textual file output with `--no-output-if-empty` is staged beside the requested file and published only when rows exist. An empty result therefore leaves an existing target unchanged. ULP starts `--after` directly rather than through an implicit command shell; use a purpose-built notifier or script when mail, retries, or workflow integration are required.

## Background Jobs

Background Jobs run long `SELECT`/CTE work without blocking the interactive menu. From the shared **Use query** screen choose **Run in background**, then manage queued, running, completed, failed, or cancelled work through **Background jobs**.

Jobs accept File pipelines and the `None` destination. Terminal, TUI, browser-grid, and other terminal-owned destinations are rejected rather than silently redirected. Each job captures its SQL, bound parameters, source definitions, masked connection settings, writer properties, output paths, and execution options when submitted.

The default limit is two concurrent jobs and is configurable with `--max-background-jobs` or interactive settings. Each job uses an isolated SQLite session and recreates configured provider tables; foreground-only temporary tables and views are not shared. Excess work remains queued.

Cancellation reaches SQLite, row enumeration, supported writers, and destination publication. Queued work cancels without starting. File output uses a temporary `.partial-*` sibling and publishes the requested name only after success; failed/cancelled partial files are removed. Active jobs reserve normalized destination paths, so use a pattern such as `events-{yyyy-MM-dd-HHmmss}-{JobId}.csv` when jobs may overlap.

Job Manager reports row, byte, queue, query, and output information when available. It does not invent a completion percentage when a query has no reliable total-row estimate. Jobs and their history exist only in the current interactive process. On exit with active work, ULP offers to wait, cancel and exit, or return; it does not claim to provide detached cross-process jobs.

## Exit Codes

| Code | Meaning |
| ---: | --- |
| 0 | Success |
| 1 | Unexpected/general application failure |
| 2 | Invalid command line or configuration |
| 3 | SQLite, query, input-provider, or execution failure |
| 4 | Required match/content/rows/scalar/condition not met |
| 5 | Output path or writer failure |
| 6 | Post-action failure, timeout, or nonzero child exit |
| 130 | User cancellation, normally Ctrl+C |

Scripts should branch on the numeric exit code and treat stderr as diagnostic text, not as a substitute for status.

## File Locations

| Item | Default location | Override |
| --- | --- | --- |
| Application config directory | `<working-directory>\config` | `--config-dir`, `ULP_CONFIG_DIR` |
| Automatic application config | `<config-dir>\defaults.ulp.config` | Change config directory |
| Interactive settings | `<config-dir>\settings.config` | Change config directory |
| Provider defaults | `<config-dir>\defaults.input.<TYPE>.config` | `--config-dir`; disable with `--use-factory-defaults` |
| Writer defaults | `<config-dir>\defaults.output.<TYPE>.config` | `--config-dir` |
| Query library | `queries` beside `ulp.exe` | `--queries-dir`, `ULP_QUERIES_DIR`, saved setting |
| Grok/RegEx patterns | `patterns\grok` in the installation | `--grok-patterns-dir`, `ULP_GROK_PATTERNS_DIR` |
| Optional session SQL | `session-sql` in the installation | Load explicitly with `--session-init-file` |
| Optional AI-agent skills | `skills` in the installation | Copy selected skill folders into the compatible agent's skill location |
| Web application assets | `web` beside `ulp.exe` | `--web-root` |
| Default log | `<working-directory>\logs\ulp-{date}.log` | `--log-file` |
| Persistent SQLite database | User-selected | `--database` / `--db` |
| Generated output | User-selected | `--output-file`, recipe/writer settings |

Relative paths are normally resolved from the current working directory unless the relevant feature documents a base such as the executable's Query library.

## Optional Coding-Agent Skills

The portable release includes optional Markdown skill packages for compatible coding/AI agents. They call the same public ULP commands available to people and scripts; they are not executable plugins and do not activate an AI service inside ULP.

| Skill | Best use |
| --- | --- |
| `ulp-repository-search` | Fast streaming text/RegEx search, file context, exact text ranges, globs, and exclusions |
| `ulp-code-intelligence` | Live SourceCode queries or reusable SQLite code indexes for symbols, calls, imports, inheritance, APIs, documentation, diagnostics, duplicates, behavior hints, metrics, and document structure |
| `ulp-data-investigation` | Bounded investigation of supported data sources |
| `ulp-query-automation` | Saved recipes, parameters, conditions, and output pipelines |

Copy the complete selected folder from the installed `skills` directory into the skill location supported by the agent. Keep its `references` subfolder: the coding skills intentionally use progressive disclosure so advanced field descriptions and recipes are loaded only when relevant. Review the instructions before enabling them; installing a skill grants no additional file, network, execution, or write permission.

## Default Values

| Setting | Default |
| --- | --- |
| No-command startup | Basic help |
| Menu layout | Beginner |
| Pager | Auto in an interactive terminal; never prompts for redirected streams |
| Input provider | TextLine when a provider is omitted; each row is one line chunk by default |
| Omitted table name | Provider-aware generated name |
| Automatic query limit | 100 |
| SQLite database | In-memory |
| Connection scope | Shared |
| Output destination | Terminal (formatted standard output; CLI destination `console`) |
| Terminal writer | Terminal table |
| Show tables on each run | Off |
| Verbose/full errors/statistics | Off |
| Automatic optional tables | None; load a supplied file explicitly with `--session-init-file` |
| Maximum concurrent interactive jobs | 2 |
| Log maximum file size | 10 MB |
| Log retention | 14 days |
| Post-action timeout | 300 seconds |
| Web bind/port | localhost / 8088 |
| Web transport | HTTPS unless HTTP is explicitly selected |
| Web AI | Off/experimental |
| Web AI timeout | 60 seconds |

Writer/provider properties have their own generated defaults. Do not infer one format's default from another.

## Logging

Enable the default rolling log:

```powershell
ulp --log --query "SELECT sqlite_version();"
```

Choose a path and retention:

```powershell
ulp --log-file '.\logs\batch-{yyyy-MM-dd}.log' `
    --log-max-size-mb 25 --log-retain-days 30 `
    --query-file .\report.sql
```

`--no-log` overrides configured logging. Logs include lifecycle, SQL, timing, warnings, and sanitized errors. Recognized secrets are masked, but SQL text, paths, schema names, and non-secret parameter context may still be sensitive. Restrict access and retention accordingly.

`--silent --verbose` is useful when detailed file diagnostics are required without ordinary console output.

## Diagnostics

### Console detail

- default: concise errors;
- `--verbose`: execution decisions, timing, table creation, conditions, and post-actions;
- `--full-errors`: sanitized technical details;
- `--stats`: one JSON summary on stderr;
- `--quiet`: fewer optional messages;
- `--silent`: no results/status on the console, but errors and file output remain.

### Runtime discovery

```powershell
ulp --version
ulp --about
ulp --sqlite-info
ulp --list-providers
ulp --list-writers
ulp --list-functions
ulp --list-tables
ulp --list-columns events
```

### Database diagnostics

`--sqlite-info` reports available sections such as SQLite/ULP version, attached databases, tables/views, columns, indexes, triggers, compile options, modules, functions, storage/page information, integrity checks, and statistics where available. Select only the sections appropriate to the current database and permissions.

### Empty results

An empty query is a valid result, not an object-reference failure. Use `--require-rows`, `--require-match`, `--require-content`, or `--expect-scalar` when emptiness must make automation fail.

## Supported Platforms

The documented ULP executable is a Windows application targeting .NET Framework 4.8.1. Windows-specific providers and features include Event Logs, Active Directory, Windows Credential Manager, certificate-store selection, and Windows process/thread inspection.

Some inputs also depend on external conditions:

- permissions to read the selected source;
- provider driver availability for ADO.NET/OleDb;
- network/domain access for remote databases or Active Directory;
- installed/native dependencies shipped with the chosen package;
- terminal capabilities for interactive menu/TUI rendering.

Use the package's release notes for its supported Windows versions and architecture. Do not assume that copying only `ulp.exe` is sufficient; use the complete release package.

## Runtime Information

The following values can vary by build and deployment:

- ULP version;
- SQLite version and compile options;
- registered functions/modules;
- provider and writer catalogs;
- .NET runtime version;
- attached databases and file paths;
- configuration and Query library locations.

Use runtime commands rather than relying on a stale document:

```powershell
ulp --version
ulp --sqlite-info
ulp --list-functions
ulp --list-providers
ulp --list-writers
```

The [SQL Function Reference](functions.md) records the ULP/SQLite version and generation date for its inventory.

## Generated Reference Files

Machine-generated material belongs under [`docs/reference/generated`](reference/generated/README.md). The current function inventory is:

- [`sqlite-functions.json`](reference/generated/sqlite-functions.json) — exact runtime signatures used to generate [SQL Function Reference](functions.md).
- [`configuration-objects.json`](reference/generated/configuration-objects.json) — complete machine-readable application, Query Builder, preprocessing, and execution property/default catalog.
- [`provider-catalog.json`](reference/generated/provider-catalog.json) and [`writer-catalog.json`](reference/generated/writer-catalog.json) — indexes for the generated input and output/formatting references.

Each input and output/formatting overview links to its exhaustive parameter table and copyable defaults. General setting roots likewise have separate parameter and default snapshots. Nested settings link to their public configuration references. Every file in this directory is replaced by `ulp --docs`; do not hand-edit generated pages. See the [format guide](inputs-and-outputs.md#nested-text-and-record-settings) and [complete SQL function catalog](reference/generated/sqlite-functions.md).

## Related Documentation

- [Getting Started](getting-started.md)
- [How-To Guide](how-to.md)
- [User Interface](user-interface.md)
- [SQLite Guide](sqlite-guide.md)
- [SQL Function Reference](functions.md)
- [Input and Output Formats](inputs-and-outputs.md)
- [AI Features](ai.md)
- [Generated CLI reference](reference/generated/cli-reference.md)
- [Generated configuration reference](reference/generated/configuration-reference.md)
- [Generated automation reference](reference/generated/automation-reference.md)
