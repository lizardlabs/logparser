# Universal Log Parser manual

Universal Log Parser (ULP) turns files, logs, system information, databases, and structured data into queryable tables. Use SQLite SQL to inspect the data, then display it in the terminal or write it to formats such as CSV, JSON, Excel, HTML, Markdown, YAML, TOON, SQL, and Scriban-generated text.

Project home: [log-parser.com](https://log-parser.com)

## Start with your goal

| I want to... | Read this |
| --- | --- |
| Install the portable ZIP and run my first command | [Getting Started](getting-started.md) |
| Learn by completing realistic jobs | [Use-case tutorials](tutorials.md) |
| Find a short command for a specific task | [How-To Guide](how-to.md) |
| Choose the correct input or output format | [Input and Output Formats](inputs-and-outputs.md) |
| Learn the SQLite syntax used by ULP | [SQLite Guide](sqlite-guide.md) |
| Find a SQL or ULP function with an example | [SQL Function Reference](functions.md) |
| Use the guided menu, TUI, SQL shell, or browser UI | [User Interfaces](user-interface.md) |
| Save, parameterize, and automate queries | [How-To: Queries and Automation](how-to.md#queries) |
| Search and inventory source code | [Code-analysis tutorials](tutorials.md) |
| Connect an AI agent through MCP or packaged skills | [AI and Agent Features](ai.md) |
| Look up an exact switch, setting, or exit code | [Command Reference](reference.md) |
| Diagnose a problem | [Troubleshooting](troubleshooting.md) |

## Ten-minute learning path

1. [Install and verify ULP](installation.md#install-from-the-release-zip).
2. Run the [first query](getting-started.md#your-first-query).
3. Inspect a real input schema before writing a larger query.
4. Complete one [tutorial](tutorials.md) that resembles your job.
5. Save a useful query in the Query library and give it parameters.
6. Choose a terminal or file writer from [Input and Output Formats](inputs-and-outputs.md#output-formats).

You do not need to learn every provider, writer, interface, or switch. A typical workflow needs one input, one query, and one output:

```text
input data -> queryable table -> SQLite query -> terminal or file output
```

For example:

```powershell
ulp --input TextLine --from '.\logs\*.log' --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%' LIMIT 50" `
    --output console --format Terminal
```

## Common jobs

### Investigate files and logs

- [Search text without SQL](how-to.md#how-to-search-text)
- [Query one log file](how-to.md#how-to-query-a-log-file)
- [Query a recursive file set](how-to.md#how-to-query-multiple-files)
- [Exclude files with negative wildcards](how-to.md#how-to-use-wildcards)
- [Read only newly appended records with checkpoints](how-to.md#how-to-read-appended-records-only)
- [Analyze Windows events](tutorials.md)

### Work with structured data

- [CSV and delimited text](inputs-and-outputs.md#csv-tsv-and-delimited-text)
- [JSON](inputs-and-outputs.md#json)
- [YAML and TOON](inputs-and-outputs.md)
- [Excel workbooks](inputs-and-outputs.md#excel)
- [ADO.NET data sources](reference.md#ado)

### Analyze and report

- [Filter and search records](how-to.md#filtering-and-searching)
- [Group, count, and calculate statistics](how-to.md#analysis)
- [Join or combine tables](sqlite-guide.md#joins)
- [Export or fan out one result to several outputs](inputs-and-outputs.md#multiple-output-pipelines)
- [Generate files with Scriban](inputs-and-outputs.md#scriban)

### Automate repeatable work

- [Save and reuse a query](how-to.md#queries)
- [Bind query parameters safely](how-to.md#how-to-parameterize-a-query)
- [Run from PowerShell or a pipeline](how-to.md#automation)
- [Use exit conditions in scripts](reference.md#automation-and-lifecycle-options)
- [Connect an MCP client](ai.md#connect-an-agent-through-mcp)

## Choose an interface

| Interface | Best for |
| --- | --- |
| Command line | Scripts, repeatable commands, pipelines, and quick queries |
| Guided menu | Discovering providers, writers, saved queries, and settings |
| SQL shell | Iterative SQL in a terminal session |
| TUI | Full-screen query editing and interactive results |
| Web interface | Local browser editing, saved queries, results, and experimental AI SQL assistance |
| MCP server | Controlled query access from compatible AI and coding tools |

See [User Interfaces](user-interface.md) for workflows, controls, and security boundaries.

## Reference shelf

- [Input and Output Formats](inputs-and-outputs.md) explains format selection, source syntax, properties, streaming, and output pipelines.
- [SQLite Guide](sqlite-guide.md) teaches SQL through ULP-oriented examples.
- [SQL Function Reference](functions.md) describes built-in SQLite functions and ULP extensions with usage examples.
- [ULP Reference](reference.md) lists commands, global options, configuration, environment variables, file locations, diagnostics, and exit codes.
- [Generated Runtime Reference](reference/generated/README.md) contains exact provider, writer, and command catalogs generated by the executable.
- [Sample Catalog](samples.md) points to checked-in input files, queries, scripts, templates, and expected output forms.

## Safety, support, and project information

- [Security](security.md) covers package verification, untrusted input, credentials, network features, web access, MCP, and AI data handling.
- [Troubleshooting](troubleshooting.md) maps common symptoms to concrete checks and fixes.
- [Installation](installation.md) covers download, extraction, upgrades, removal, and checksum verification.
- [Deployment](deployment.md) covers the supported portable deployment and release-package administration.
- [Versions](versions.md) explains how to identify an installed build and review compatibility.
- [About ULP](about.md) describes the product's goals and design philosophy.
- [Legal and Privacy](legal.md) explains product and third-party terms, privacy boundaries, and disclaimers.

ULP is distributed under its product license. Bundled third-party components retain their separate license terms and notices.
