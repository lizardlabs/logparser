# Getting Started

Universal Log Parser (ULP) turns files, logs, Windows events, structured data, system information, and other record sources into tables that you can query with SQLite SQL. The same result can be reviewed in a terminal or user interface, saved in several formats, reused by automation, or exposed to an MCP client.

Project home: [https://log-parser.com](https://log-parser.com)

## Contents

- [What Is ULP?](#what-is-ulp)
- [Who Is ULP For?](#who-is-ulp-for)
- [Main Features](#main-features)
- [Requirements](#requirements)
- [Install ULP](#install-ulp)
- [Run ULP for the First Time](#run-ulp-for-the-first-time)
- [Your First Query](#your-first-query)
- [Understanding the Result](#understanding-the-result)
- [Exporting Results](#exporting-results)
- [Privacy and External Services](#privacy-and-external-services)
- [Where to Go Next](#where-to-go-next)
- [For Microsoft Log Parser Users](#for-microsoft-log-parser-users)

## What Is ULP?

ULP is a Windows command-line data exploration and transformation tool built around SQLite. A **data provider** reads a source format. ULP exposes its records as a table, runs SQL against that table, and sends the result to one or more destinations.

The basic workflow is:

1. Choose an input provider, such as `CSV`, `JSON`, `TextLine`, `FileSystem`, or `EVT`.
2. Identify the source, such as a filename, wildcard, directory, URL, event channel, or provider-specific value.
3. Give the source a table name.
4. query the table with SQLite SQL.
5. Display or save the result.

For example, this command reads a CSV file as a table named `employees`, selects three columns, and prints the five highest salaries:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name, department_id, salary FROM employees ORDER BY CAST(salary AS INTEGER) DESC LIMIT 5" `
    --output console --format Terminal
```

ULP also has direct `search` and `analyze` commands for tasks that do not need SQL:

```powershell
ulp search ERROR .\logs --ignore-case --include "*.log"
ulp analyze .\logs --include "*.log"
```

Use the SQL workflow when you need structured parsing, grouping, statistics, joins, repeated analysis, or multiple output formats. Use direct search when filenames, line numbers, matching text, and optional surrounding lines are enough.

## Who Is ULP For?

ULP is useful for:

- administrators investigating Windows events, services, files, and system activity;
- developers examining application logs, structured files, source code, or managed assemblies;
- support and operations teams building repeatable diagnostic queries;
- security analysts correlating events and file metadata;
- data users who want SQL over CSV, JSON, YAML, TOON, Excel, and text without first importing everything into a server database;
- automation authors who need stable exit codes and machine-readable output;
- Microsoft Log Parser users who want a familiar query workflow with SQLite and additional input/output options;
- coding agents and MCP clients that need bounded, structured access to saved queries and local data.

You do not need to be a database administrator. The guided menu and Query Builder can prepare common operations, and the installed Query library contains reusable examples. Basic SQL knowledge becomes useful as questions become more specific.

## Main Features

- Query many record sources with SQLite SQL.
- Stream input through `ParsingModule` virtual tables.
- Use saved SQL from a recursive Query library.
- Build filters, sorting, grouping, joins, unions, and materialization statements interactively.
- Display results in the terminal, TUI, or optional local web interface.
- Write CSV, TSV, JSON, XML, YAML, TOON, Markdown, HTML, Excel, SQL script, text, and template-generated output where compatible.
- Send one result to multiple file outputs.
- Bind named query parameters without SQL text replacement.
- Read appended file/event data incrementally with checkpoints where supported.
- Persist selected provider rows in an ordinary SQLite database with `ingest`.
- Query other practical ADO.NET data sources while keeping SQLite and ParsingModule as the primary workflow.
- Run as an MCP server for compatible local tools.

AI-assisted SQL is in development and is not a supported ULP 1.0 command-line feature. Experimental web AI features require explicit configuration and may send schema and conversation data to the configured external provider.

## Requirements

The current ULP 1.0 build targets Windows and .NET Framework 4.8.1.

You need:

- a supported Windows installation;
- .NET Framework 4.8.1;
- permission to read the selected input and write any requested output;
- a terminal such as Windows Terminal, PowerShell, or Command Prompt.

Some providers have additional requirements:

- Windows Event Log queries depend on Windows event APIs and the caller's access to the selected channels.
- Active Directory queries depend on network/domain access and suitable credentials.
- network URLs and external database connections depend on the relevant network access and provider configuration.
- the optional local web interface needs an available TCP port; HTTPS certificate selection may require access to the Windows certificate store.

ULP is packaged as an AnyCPU Windows application and includes native SQLite components for both x86 and x64 in its release package. Do not copy only `ulp.exe` out of the package; keep its runtime dependencies and native folders together.

## Install ULP

For a portable installation:

1. Download the current Windows ZIP from the official project site or another publisher-approved channel.
2. Verify the download when a checksum or digital signature is supplied.
3. Extract the complete archive to a directory you control.
4. Open PowerShell in that directory.
5. Run:

```powershell
.\ulp.exe --help
```

You can keep ULP portable and run it by full path, or add its directory to your user `PATH`.

See [Installing ULP](installation.md) for upgrade, removal, source build, verification, and package-channel guidance. The installation chapter labels unpublished distribution methods rather than presenting speculative commands.

## Run ULP for the First Time

Run ULP without arguments to see concise command help:

```powershell
.\ulp.exe
```

Open the guided menu with:

```powershell
.\ulp.exe --menu
```

The beginner menu emphasizes data sources, the Query library, the TUI, output selection, and help. The advanced menu adds the SQL shell, SQLite information, background jobs, and multi-output tools:

```powershell
.\ulp.exe --menu --advanced-menu
```

To make the menu the default when no command is supplied, use **Options > Change runtime settings > No-command startup**, or run with `--startup-mode menu`. Use `--no-menu` to override a saved menu default for one invocation.

Useful discovery commands include:

```powershell
.\ulp.exe --list-providers
.\ulp.exe --list-writers
.\ulp.exe --list-functions
.\ulp.exe --help sqlite
```

## Your First Query

The repository and release package include fictional sample data. From the ULP directory, query the employee CSV sample:

```powershell
.\ulp.exe --input CSV `
    --from .\samples\data\employees.csv `
    --table employees `
    --query "SELECT employee_name, department_id, salary FROM employees ORDER BY CAST(salary AS INTEGER) DESC LIMIT 5" `
    --output console `
    --format Terminal
```

The command has five important parts:

| Part | Meaning |
| --- | --- |
| `--input CSV` | Select the CSV input provider. |
| `--from ...` | Select the source file. |
| `--table employees` | Name the SQLite virtual table. |
| `--query ...` | Run SQL against that table. |
| `--output console --format Terminal` | Display a formatted terminal result. |

The SQL itself is ordinary SQLite SQL:

```sql
SELECT employee_name,
       department_id,
       salary
FROM employees
ORDER BY CAST(salary AS INTEGER) DESC
LIMIT 5;
```

`CAST` makes the numeric intent explicit when the CSV schema is text-oriented. A provider configuration or typed header can supply stronger types for repeated workflows.

### A first text-log query

The `TextLine` provider exposes one record per line. This command finds error lines in the sample application log:

```powershell
.\ulp.exe --input TextLine `
    --from .\samples\data\application.log `
    --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%'" `
    --output console --format Terminal
```

For this simple case, direct search is shorter:

```powershell
.\ulp.exe search ERROR .\samples\data\application.log
```

The SQL version becomes more valuable when the source has structured fields, or when you need aggregates, joins, materialization, named parameters, or reusable saved queries.

## Understanding the Result

The terminal writer displays one column for each expression in the `SELECT` list and one row for each matching record. For the employee example, the values should be ordered from the highest salary downward. A simplified representation is:

| employee_name | department_id | salary |
| --- | ---: | ---: |
| Margaret | 30 | 132000 |
| Grace | 10 | 126000 |
| Ada | 10 | 118000 |
| Ken | 30 | 115000 |
| Alan | 10 | 109000 |

The exact terminal borders and colors depend on the console and writer settings. The data and ordering come from the SQL query.

An empty result is not automatically an error: it may mean that no source rows matched the filter. For automated checks, use `--require-rows`, `--expect-scalar`, or a condition query when an empty or unexpected result must produce a nonzero exit code.

ULP normally limits automatically built queries to a safe number of rows. Explicit SQL should also use a suitable `LIMIT` while exploring large or expensive sources.

## Exporting Results

Change the destination to `file`, select a format, and supply an output filename:

```powershell
.\ulp.exe --input CSV `
    --from .\samples\data\employees.csv `
    --table employees `
    --query "SELECT * FROM employees WHERE lower(active)='true' ORDER BY employee_name" `
    --output file --format JSON --output-file .\active-employees.json
```

Export CSV instead:

```powershell
.\ulp.exe --input CSV `
    --from .\samples\data\employees.csv `
    --table employees `
    --query "SELECT * FROM employees ORDER BY employee_id" `
    --output file --format CSV --output-file .\employees-copy.csv
```

Send the same executed result to more than one file writer:

```powershell
.\ulp.exe --input CSV `
    --from .\samples\data\employees.csv `
    --table employees `
    --query "SELECT * FROM employees ORDER BY employee_id" `
    --output file --format CSV --output-file .\employees.csv `
    --also-pipeline Excel=.\employees.xlsx `
    --also-pipeline JSON=.\employees.json
```

`--output` selects the destination (`console`, `file`, `none`, or `text-ui`). `--format` selects how the result is represented. Keep these concepts separate when reading examples.

Output names may use documented date/time tokens and `{n}` for the first available positive sequence number. Use `--no-overwrite` when an existing target must never be replaced.

## Privacy and External Services

ULP processes local inputs locally unless you explicitly choose a feature or source that uses a network service. Public web inputs, remote databases, Active Directory, post-actions, MCP clients, and optional experimental AI configuration can send requests or data outside the computer.

You are responsible for having permission to process and transmit the selected data. Review the third party's privacy terms, retention, access controls, and security before sending confidential, personal, regulated, or operational information. ULP cannot control data after it reaches an external service. Store API keys and passwords through supported secret references rather than command-line text, configuration committed to source control, screenshots, or logs. See [ULP Security](security.md) and [Legal, Licensing, Privacy, and Disclaimers](legal.md) for the complete guidance.

## Where to Go Next

- Use the [sample catalog](samples.md) for checked-in SQL and automation examples.
- Read the [SQLite guide](sqlite-guide.md) for SQL basics, ParsingModule, functions, and database information.
- Browse [input providers and output writers](inputs-and-outputs.md) to select a format and inspect generated properties.
- Use the [ULP Reference](reference.md) for complete command and configuration options.
- Use [incremental input and checkpoint files](inputs-and-outputs.md#incremental-input-and-checkpoints) for append-only logs and large event sources.
- Open the [local web interface guide](user-interface.md#work-in-the-browser) if you want a browser-based Query library and result grid.
- Read [MCP deployment](deployment.md#mcp-deployment) to expose saved queries to a compatible local client.

The remaining chapters cover tutorials, task recipes, interfaces, formats, functions, deployment, troubleshooting, security, versions, legal information, and project background.

## For Microsoft Log Parser Users

ULP is inspired by the usefulness of Microsoft Log Parser, but the query engine is SQLite and the command surface is ULP 1.0. Do not assume every Log Parser command-line switch or SQL behavior is identical.

Familiar ideas include:

- selecting an input format and source;
- treating records as rows and fields as columns;
- filtering, grouping, sorting, and aggregating with SQL;
- writing the result in a chosen format;
- compatibility functions for many Microsoft Log Parser 2.2 expressions.

Important differences include:

- ULP uses SQLite syntax, typing, joins, common table expressions, JSON support, and window functions.
- Providers are exposed through ParsingModule virtual tables.
- Streaming sources may need to be materialized before a plan scans them repeatedly.
- output destination and output format are separate options.
- ULP supports named SQLite parameters instead of unsafe string replacement.
- ULP adds a Query library, TUI, optional web interface, MCP server, multiple output pipelines, checkpoints, and direct search/analyze/ingest commands.

A ParsingModule table can also be created explicitly in SQL:

```sql
CREATE VIRTUAL TABLE logs
USING ParsingModule('System', '-i:EVT');

SELECT TimeCreated,
       EventTypeName,
       SourceName,
       Message
FROM logs
WHERE EventTypeName IN ('Warning', 'Error')
ORDER BY TimeCreated DESC
LIMIT 200;
```

For joins, windows, or repeated scans of a forward-only source, materialize it once:

```sql
CREATE TEMP TABLE logs_snapshot AS
SELECT * FROM logs;
```

Use `ulp --list-functions` and the SQLite help to see which Microsoft Log Parser function names are compatible, which operations use SQLite-native equivalents, and which helpers are ULP extensions.
