# Execution and reusable architecture

`LizardLabs.PortableLogParserCommon.dll` contains the application-neutral parts intended for desktop, web, service, test, and agent hosts:

- ParsingModule and provider discovery/factories.
- `QueryBuilder`, `QueryBuilderOptions`, and the richer `Querying.QueryDefinition` / `Querying.SqliteQueryBuilder` model.
- Provider and property Markdown generation through `Documentation.HelpBuilder`.
- Secret reference resolution.
- `Writers.IResultWriter`, `ResultWriterBase`, `TextResultWriterBase`, `ResultWriterFactory`, result fan-out support, generated-file output, and noninteractive writers such as JSON, TOON, XML, CSV, TSV, HTML, Markdown, YAML, SQL, Excel, Scriban, and null/metrics output.
- Minimal SQLite identifier quoting and centralized secret masking for connection strings and diagnostic text.
- SQLite helper functions.

The CLI executable keeps host concerns: Spectre.Console menus, the SQL shell, the Terminal.Gui Text User Interface (TUI), console-specific property dialogs, process exit codes, job scheduling, and the stdio MCP host.

`Execution.QueryExecutionService` is the single cancellable foreground/background query engine. `BackgroundJobManager` supplies bounded process-scoped scheduling and immutable job snapshots. `IResultFormatter`, `IOutputDestination`, `OutputPipelineSnapshot`, and capability flags separate representation from destination while `RegisteredWriterFormatter` adapts registered Result Writers to the pipeline.

`Execution.AdoQueryExecutionService` is the explicit provider-neutral path. `AdoDataSourceFactory` creates a selected `IDbConnection`; commands return `IDataReader`, which is buffered into the same DataSet-oriented fan-out path used by multi-output queries. Shared preprocessing and script operations live in Common. SQLite compatibility rewriting is applied only to SQLite connections. New ADO providers require one catalog registration and do not require another output subsystem.

`ScribanOutput` is a buffered Common writer. It exposes only plain result tables, rows, columns, and scalars to templates. `IGeneratedFileResultWriter` is the narrow capability used when a writer emits a safe file set under one output root; the ordinary single-stream writer contract remains unchanged for all existing formats.

Each background request owns an independent SQLite connection and recreates its configured ParsingModule sources. This avoids unsafe cross-thread connection sharing and leaves a clean seam for a future persistent worker or MCP `start_query/get_job_status/cancel_job` API.

`IResultWriter` is the public abstraction name. The older `OutputBase`, `TextOutputBase`, and `OutputerFactory` names remain obsolete compatibility aliases for one migration period; new applications should not use the term *Outputer*.

Input providers and result writers are registered in explicit descriptor catalogs. Each registration contains the canonical public name, description, category, compatibility aliases, and its constructor. Writer registrations additionally declare the default extension and streaming/seek requirements. Menus and generated documentation list canonical names; factories accept both canonical names and aliases. Add or remove a format in the appropriate catalog instead of editing a separate enum, listing method, and switch statement.

`FileSystem` is the canonical general file and directory provider name. `FS` is its documented short name. Provider implementations retain the shared input and stream contracts.
