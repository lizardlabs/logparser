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
| `--input`, `-i <provider>` | Begin a provider source block; default provider is `TextLine` |
| `--from`, `--source <value>` | Select file/glob, URL, archive entry, channel, or provider-specific source |
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
| `--no-menu` | Override a saved menu startup and show normal help |
| `--startup-mode help\|menu` | Select no-command behavior |
| `--beginner-menu` | Use the focused beginner layout |
| `--advanced-menu` | Include shell, SQLite internals, jobs, and output fan-out |
| `--shell` | Open the SQLite SQL shell directly |
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

Help topics include `general`, `providers`, `writers`, `sqlite`, `query-builder`, `mcp`, `ado`, `scriban`, `jobs`, `output`, `configuration`, `examples`, and `advanced`.

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
| Input provider | TextLine when a provider is omitted |
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

Provider/writer detail pages remain in their existing location until the generator, CLI links, tests, and inbound documentation links can move together without breaking users. The readable manual intentionally summarizes formats rather than copying every generated property.

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
