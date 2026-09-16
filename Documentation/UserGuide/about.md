# About ULP

## Contents

- [What Is ULP?](#what-is-ulp)
- [Why ULP Exists](#why-ulp-exists)
- [Design Philosophy](#design-philosophy)
- [Microsoft Log Parser Inspiration](#microsoft-log-parser-inspiration)
- [Project History](#project-history)
- [Goals](#goals)
- [Roadmap](#roadmap)
- [Credits](#credits)
- [Contributing](#contributing)
- [Project Information](#project-information)

## What Is ULP?

Universal Log Parser (ULP) is a Windows command-line, interactive, and integration tool that exposes many record sources as SQLite tables. It can query files, structured data, Windows/system sources, source code, assemblies, databases, and generated sequences, then render the same results to terminal, files, workbooks, templates, and multiple pipelines.

The main workflow is:

```text
source -> provider table -> SQLite SQL -> result -> destination/writer
```

ULP also includes direct streaming search/analysis, persistent SQLite ingestion, saved Query library recipes, ADO.NET query execution, TUI/web interfaces, MCP integration, and experimental web AI SQL generation.

## Why ULP Exists

Operational data is fragmented across formats and tools. ULP provides one query language and one output pipeline so users can inspect, combine, automate, and export records without first building a separate application for every source.

It is useful for:

- log and event investigation;
- file/disk inventory and statistics;
- CSV/JSON/YAML/TOON/Excel analysis;
- repeatable reports and batch gates;
- source-code inventory/search for developers and coding agents;
- data-driven code/configuration/document generation;
- migration from Microsoft Log Parser-style workflows.

## Design Philosophy

### SQLite first

SQLite is the common query engine. Provider-specific acquisition is separated from filtering, joins, aggregation, windows, and output.

### Streaming where practical

Inputs and writers stream when possible, with lazy file discovery and cancellation. Operations that require sorting, joining, windows, TUI/web display, multi-output, or generated files may buffer/materialize.

### Explicit safety boundaries

Secrets use references, connection strings are masked, output overwrite is explicit, generated paths stay under selected roots, web access is restricted by default, and AI SQL requires review.

### Beginner and advanced paths

The normal command help and Beginner menu keep initial choices focused. Advanced menu/options expose connection internals, shell, jobs, fan-out, and expert controls.

### Discoverable extensibility

Runtime provider/writer/function catalogs describe what the current build actually supports. Configuration remains command-line-like and generated reference material is separated from the readable manual.

### Automation contract

Result data, diagnostics, statistics, exit codes, cancellation, staged files, conditions, hooks, and post-actions are designed for predictable scripting.

## Microsoft Log Parser Inspiration

Microsoft Log Parser 2.2 demonstrated that varied logs and system data could be queried through SQL using input and output formats. ULP keeps that approachable idea and compatibility-minded naming/functions where practical while using SQLite and adding modern providers, structured formats, joins/windows/CTEs/JSON, multiple outputs, templates, interactive interfaces, checkpoints, saved queries, ADO.NET, MCP, and optional AI assistance.

ULP is not Microsoft Log Parser and is not affiliated with or endorsed by Microsoft. Syntax, schemas, types, functions, and behavior can differ. See [Getting Started for Microsoft Log Parser users](getting-started.md#for-microsoft-log-parser-users).

## Project History

Repository evidence shows an evolving Log Parser-inspired .NET codebase now named Universal Log Parser, with [log-parser.com](https://log-parser.com) as its home URL.

An approved author biography, founding date, milestone timeline, and public release chronology have not yet been supplied.

**Owner input required:** origin story, author/team attribution, dates, important milestones, prior product names, and any organizations/communities that should be credited.

## Goals

- Make heterogeneous records queryable with familiar SQL.
- Preserve a strong SQLite + ParsingModule primary workflow.
- Keep the normal CLI useful without forcing users into menus.
- Provide guided interfaces for discovery and query construction.
- Stream large inputs/outputs and support cancellation/checkpoints.
- Offer accurate generated provider/writer/function references.
- Be useful for both human operators and automation/coding agents.
- Produce clean, interoperable output formats.
- Remain explicit about security, privacy, experimental features, and package availability.
- Support maintainable extensions without exposing implementation details to end users.

## Roadmap

Current planning notes contain working ideas. They are not release commitments, schedules, or guarantees.

At a high level, continuing goals include:

- broader/stronger provider and query recipes;
- improved documentation and generated catalogs;
- deeper code-intelligence use cases;
- performance/streaming improvements;
- optional interfaces and integration workflows;
- release packaging/distribution maturity;
- compatibility and security hardening.

**Owner input required:** approved public roadmap, prioritization, target versions, and deprecation policy.

## Credits

ULP uses many third-party components. See [Open Source Software Notices](legal/THIRD-PARTY-NOTICES.md) for component authors and licenses.

Microsoft Log Parser is acknowledged as design inspiration. SQLite provides the query language/runtime foundation used by ULP's primary workflow.

**Owner input required:** product author/team, contributors, testers, sponsors, translators, design/community acknowledgements, and permission to publish names.

## Contributing

ULP is a proprietary product. You can help by reporting reproducible problems, suggesting useful queries and formats, and sharing sanitized examples through the [product website](https://log-parser.com). Do not send confidential data or assume that source-code contributions are accepted.

**Owner input required:** approved community contact and contribution terms.

## Project Information

- Product: Universal Log Parser (ULP)
- Home: [https://log-parser.com](https://log-parser.com)
- Platform: Windows / .NET Framework 4.8.1
- Primary query engine: SQLite
- Documentation: [ULP Manual](README.md)
- Legal status: see [Legal, Licensing, Privacy, and Disclaimers](legal.md)

## Related Documentation

- [Getting Started](getting-started.md)
- [Versions and Release History](versions.md)
- [Deployment and Packaging](deployment.md)
