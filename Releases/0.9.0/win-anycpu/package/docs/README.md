# Universal Log Parser documentation

This documentation is organized as a technical manual. Start with the introductory chapters, then use the task guides and reference material when you need a specific command, provider, writer, or SQL feature.

> The chapter-based manual is the primary user documentation. Runtime-generated command, provider, and writer details live under `reference/generated`; earlier `docs/user` paths remain only where generated help or stable moved-page notices are useful.

## Choose how you want to work

| Goal | Start with |
| --- | --- |
| Run a first file query | [Getting Started](getting-started.md#your-first-query) |
| Learn SQLite through real ULP examples | [Tutorials](tutorials.md) and [SQLite Guide](sqlite-guide.md) |
| Find the correct input provider or output writer | [Input and Output Formats](inputs-and-outputs.md) |
| Build a repeatable command or `.config` file | [Configuration](reference.md#configuration) |
| Use ULP from a coding or AI agent | [Agent skills and direct CLI](ai.md#packaged-agent-skills) |
| Connect Codex, Copilot, Claude Desktop, Cursor, or another MCP client | [MCP setup](ai.md#connect-an-agent-through-mcp) |
| Generate SQL from natural language in the browser | [Experimental AI SQL Chat](ai.md#getting-started) |
| See query results in several output formats | [Export samples](samples.md#export-examples) |

## Start here

- [Getting Started](getting-started.md) — understand ULP, run a first query, and export the result.
- [Installing ULP](installation.md) — choose an installation method, upgrade, remove, and verify a package.
- [ULP Tutorials](tutorials.md) — thirteen progressive, executable lessons from a first query through log analysis.
- [Sample catalog](samples.md) — executable ParsingModule, SQL, and automation examples.

## Using ULP

- [How-To Guide](how-to.md) — task-oriented recipes for input, filtering, analysis, output, queries, and automation.
- [User Interface](user-interface.md) — guided menu, SQL shell, TUI, web interface, shortcuts, and workflows.
- [Samples](samples.md) — browsable catalog of checked-in data, SQL, Query library recipes, exports, scripts, and templates.
- [Command line and interactive shell](reference.md)
- [Query Builder](user-interface.md#query-builder)
- [Configuration](reference.md#configuration)
- [Automation](how-to.md#automation)
- [Background jobs](reference.md#background-jobs)

The consolidated chapters are authoritative. Generated details remain available when an exact runtime option/property list is needed.

## SQL and data

- [SQLite Guide](sqlite-guide.md) — ULP-oriented SQL from `SELECT` and filtering through joins, windows, JSON, and log-analysis patterns.
- [SQL Function Reference](functions.md) — the complete runtime-generated function inventory, organized by category with examples and compatibility status.
- [Input and Output Formats](inputs-and-outputs.md) — registered providers, writers, source syntax, checkpoints, output pipelines, and the compatibility matrix.
- [Output destinations and pipelines](inputs-and-outputs.md#multiple-output-pipelines)

The consolidated SQLite Guide, SQL Function Reference, and Input and Output Formats chapters are the primary SQL-and-data reading path. Exact runtime catalogs are generated under `docs/reference/generated`.

## Advanced features

- [AI Features](ai.md) — choose between web AI, agent skills, direct CLI use, and MCP; configure clients, secrets, prompts, privacy, and review workflows.
- [Deployment and Packaging](deployment.md) — portable/enterprise deployment, current package availability, release artifacts, verification, and CI/CD.
- [ADO.NET data sources](reference.md#ado)
- [Scriban templates and code generation](inputs-and-outputs.md#scriban)
- [MCP server deployment](deployment.md#mcp-deployment)

AI SQL Chat is experimental, disabled by default, and available only in the optional web interface. The ordinary CLI, guided menu, TUI, SQL shell, and MCP server do not expose this ULP AI generator.

## Reference and support

- [ULP Reference](reference.md) — readable command syntax, options, commands, configuration, environment, exit codes, locations, defaults, diagnostics, and runtime information.
- [Troubleshooting ULP](troubleshooting.md) — exact symptoms, corrective actions, diagnostic collection, and safe bug reporting.
- [ULP Security](security.md) — package integrity, untrusted data, SQL/files/secrets, AI, web, MCP, network activity, and reporting guidance.
- [Generated CLI reference](reference/generated/cli-reference.md)
- [Testing and diagnostics](developer/TESTING.md)
- [Project release process](developer/RELEASING.md)

Machine-generated references are kept under `docs/reference/generated` and identified by ULP version and generation method.

## Project information

- [Versions and Release History](versions.md) — current source version, upgrade/compatibility guidance, verified history boundaries, and release placeholders.
- [Blog and Stories](blog/README.md) — independent articles and the editorial template.
- [About ULP](about.md) — purpose, philosophy, Log Parser inspiration, goals, roadmap boundaries, and credits placeholders.
- [Legal, Licensing, Privacy, and Disclaimers](legal.md) — readable legal/privacy summary and explicit owner/counsel review requirements.
- [Developer documentation](developer/README.md)
- [Legal source material and third-party notices](legal/README.md)
- [Product website](https://log-parser.com)

The operative product license, vulnerability-reporting address, release dates/history, author credits, and publisher legal/privacy details still require verified owner or counsel input. Third-party notice/license files remain separate from explanatory documentation.

## Documentation conventions

- Commands use PowerShell syntax unless stated otherwise.
- SQL examples use SQLite syntax and ULP providers.
- A command containing a placeholder such as `<path>` requires a value supplied by the user.
- Experimental, platform-limited, or unpublished features are labeled explicitly.
- End-user chapters explain behavior and workflows, not internal class or interface names.
- Large chapters include local contents lists and links to their major sections.

### Chapter size and splitting

Keep related user guidance together even when a chapter has many sections. At about **1,500 lines** or **150 KB**, review navigation, browser-search usability, printing, and ownership. A large chapter is not split automatically: record a clear usability or lifecycle reason before splitting it. A new short page at the documentation root must either join an existing chapter or carry a `standalone-reason` comment explaining its different audience, generated nature, or independent lifecycle.

The repository documentation check validates local Markdown links and anchors, requires contents lists in manual chapters, flags undocumented short root pages, and requires an explicit review decision for unusually large chapters.

## Documentation worklist

This published copy is synchronized from the ULP source manual. Generated reference pages identify the ULP version and generation method used to produce them.
