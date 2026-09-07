# Universal Log Parser (ULP)

**Use SQLite to query files, logs, Windows data, structured documents, source code, assemblies, and databases—then write the result to the terminal, files, workbooks, templates, or several outputs at once.**

This repository contains the public ULP user manual, configuration and extension information, sample data, and locally staged release artifacts. ULP 1.0 is being prepared for release; experimental features and package locations may still change before publication.

Project home: [https://log-parser.com](https://log-parser.com)

## Why ULP Was Built

Useful operational data is scattered across formats. Answering one question can require a log viewer, a CSV script, Event Viewer, a directory utility, a database client, and another tool to create the final report. ULP puts those sources behind one table-and-query model:

```text
input source -> table -> SQLite query -> result -> one or more outputs
```

This approach can reduce throwaway scripts, repeated imports, tool switching, and manual copy/paste. A query that proves useful can become a named Query library recipe, an automation gate, an MCP tool workflow, or a repeatable export. The same result can be delivered as a terminal table, CSV, JSON, Excel, HTML, Markdown, YAML, TOON, SQL, or Scriban-generated files.

ULP is especially useful when a full database or observability platform would be too heavy for a short investigation, but plain text search is not structured enough.

## Who It Is For

| Audience | Example uses |
| --- | --- |
| Administrators | Event Log summaries, file/directory reports, process and thread snapshots |
| Developers and support teams | Log triage, source-code discovery, assembly inspection, reproducible customer diagnostics |
| Analysts | Filter, join, aggregate, and export CSV, JSON, YAML, Excel, and database results |
| Security responders | Find rare values, correlate evidence, compare time windows, and preserve reviewable output |
| Automation engineers | Parameterized saved queries, conditions, multiple outputs, lifecycle SQL, scheduled runs |
| AI and coding agents | Bounded repository search, code intelligence, provider/schema discovery, MCP query and export tools |
| Microsoft Log Parser users | A familiar input/query/output workflow with SQLite joins, CTEs, windows, JSON, and modern writers |

## Quick Example

```powershell
ulp -i CSV --from .\employees.csv --table employees `
  --query "SELECT department_id, COUNT(*) AS employees, ROUND(AVG(CAST(salary AS REAL)), 0) AS average_salary FROM employees WHERE lower(active)='true' GROUP BY department_id ORDER BY average_salary DESC" `
  --format Markdown --no-pager
```

Representative result:

| department_id | employees | average_salary |
| :--- | ---: | ---: |
| 30 | 1 | 132000.00 |
| 10 | 3 | 117667.00 |
| 20 | 1 | 99000.00 |
| 40 | 1 | 88000.00 |

Export the same kind of result to several destinations in one run:

```powershell
ulp -i CSV --from .\employees.csv --table employees `
  --query "SELECT * FROM employees ORDER BY employee_id" `
  --output file --format CSV --output-file .\reports\employees.csv `
  --also-pipeline JSON=.\reports\employees.json `
  --also-pipeline Excel=.\reports\employees.xlsx `
  --also-pipeline HTML=.\reports\employees.html
```

Other entry points are explicit and reuse the same core capabilities:

```powershell
ulp --help
ulp --menu
ulp --tui
ulp --web
ulp --mcp --database C:\Data\agent-session.sqlite
```

## AI, Agents, and MCP

ULP offers three different integration styles:

- experimental web AI SQL Chat converts natural language into reviewable SQL and never executes generated SQL automatically;
- four packaged agent skills teach compatible agents repository search, code intelligence, data investigation, and safe query automation through the CLI;
- the local STDIO MCP server exposes provider/schema discovery, saved-query review, query execution, materialization, and exports to compatible assistants.

These are separate choices: an agent can use the CLI without ULP's web AI, and an MCP client uses its own model. See [AI Features](Documentation/UserGuide/ai.md) and the [generated MCP setup](Documentation/UserGuide/reference/generated/mcp-reference.md).

## Documentation

The chapter-based [ULP User Manual](Documentation/UserGuide/README.md) is the authoritative documentation.

### Start here

- [Getting Started](Documentation/UserGuide/getting-started.md)
- [Installation](Documentation/UserGuide/installation.md)
- [Tutorials](Documentation/UserGuide/tutorials.md)
- [Samples](Documentation/UserGuide/samples.md)

### Use and configure ULP

- [How-To Guide](Documentation/UserGuide/how-to.md)
- [User Interfaces](Documentation/UserGuide/user-interface.md)
- [SQLite Guide](Documentation/UserGuide/sqlite-guide.md)
- [Input and Output Formats](Documentation/UserGuide/inputs-and-outputs.md)
- [AI, Agent Skills, and MCP](Documentation/UserGuide/ai.md)
- [CLI and Configuration Reference](Documentation/UserGuide/reference.md)
- [Deployment and Packaging](Documentation/UserGuide/deployment.md)
- [Troubleshooting](Documentation/UserGuide/troubleshooting.md)

Exact runtime-generated provider, writer, CLI, configuration, MCP, ADO.NET, Scriban, automation, and SQLite inventories are under [generated reference](Documentation/UserGuide/reference/generated/README.md).

## Repository Areas

| Area | Purpose |
| --- | --- |
| [`Documentation/UserGuide`](Documentation/UserGuide/README.md) | Current ULP 1.0 user manual |
| [`Documentation`](Documentation/README.md) | Documentation entry point and legacy-reference notice |
| [`Configuration`](Configuration/README.md) | Configuration examples |
| [`Extensions`](Extensions/README.md) | Extension and plugin information |
| [`Samples`](Samples/README.md) | Sample inputs and queries |
| [`Releases`](Releases/README.md) | Versioned release archives, checksums, and expanded review packages |

## Release and License Status

The `Releases` directory is populated locally by the release workflow for review; its presence does not by itself mean a public release has been approved. Verify the selected archive's checksum, license, signing status, and release notes before distribution.

See [LICENSE](LICENSE). Third-party notices and component licenses are documented separately in the manual's [legal source material](Documentation/UserGuide/legal/README.md).
