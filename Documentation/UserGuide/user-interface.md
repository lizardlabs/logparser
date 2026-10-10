# ULP User Interface

ULP provides several interactive surfaces for different jobs: a guided terminal menu, an SQL shell, a Text User Interface (TUI) for query editing and tabular results, and an optional local web interface. They use the same core ideas—data providers, SQLite tables, queries, parameters, and output writers—but they do not expose every feature in exactly the same way.

## Contents

Short introductions: [CLI](interfaces/cli.md), [guided menu](interfaces/menu.md), [TUI editor](interfaces/tui.md), [SQL shell](interfaces/shell.md), [browser](interfaces/web.md), and [agents/MCP](interfaces/mcp.md). Each has a dedicated screenshot placeholder; this chapter remains the detailed manual.

- [Overview](#overview)
- [Main Window](#main-window)
- [Opening Input Data](#opening-input-data)
- [Query Editor](#query-editor)
- [Results View](#results-view)
- [File and Input Selection](#file-and-input-selection)
- [Saved Queries](#saved-queries)
- [Query Builder](#query-builder)
- [Query History](#query-history)
- [Settings](#settings)
- [AI Interface](#ai-interface)
- [Menus and Commands](#menus-and-commands)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Common UI Workflows](#common-ui-workflows)
- [UI Troubleshooting](#ui-troubleshooting)

## Overview

| Interface | Start command | Best for |
| --- | --- | --- |
| Product tour | `ulp --tour` | Explained, bounded demonstrations before configuring your own data |
| Guided menu | `ulp --menu` | Beginner-friendly source, query, output, settings, and help workflows |
| Advanced menu | `ulp --menu --advanced-menu` | SQL shell, SQLite internals, background jobs, and output fan-out |
| SQL shell | `ulp --shell` | Repeated SQL in one terminal session |
| TUI | Choose **Open TUI**, or use the `text-ui` destination | Keyboard-driven query editing and result-table browsing |
| Local web interface | `ulp --web` | Browser Query library, ad-hoc SQL, grid filtering/export, Shell, and optional AI Chat |

Run `ulp` without arguments for concise command help. The default no-command behavior can be changed from help to the guided menu in **Options**, or with `--startup-mode menu`.

The beginner menu is intentionally smaller. It keeps guided sources and tables, output selection, the Query library, Query Builder, TUI, Options, and Help. The advanced menu adds operational features that new users do not need for a first query.

For a safe introduction, choose **LEARN · Product tour** from either main menu. The tour previews each query, explains what it demonstrates, and lets you run, skip, repeat, or stop. It uses an isolated in-memory database and does not replace the sources, database, output destination, or writer defaults already configured in the menu.

## Main Window

<!-- Screenshot placeholder: beginner menu with the title divider, status summary, main actions, and separated Clear/Exit commands. -->

The guided terminal menu uses a consistent layout:

- blank space and a title divider identify the current section;
- a status line summarizes menu mode, configured sources, output, active jobs, and the masked SQLite connection;
- ordinary actions appear as the main menu body;
- terminal actions such as **Clear screen**, **Back**, and **Exit** are visually separated;
- selection lists, such as providers, writers, tables, and files, are labeled as lists rather than menus.

Choose actions with the arrow keys and Enter. Number-key behavior depends on terminal capabilities and is not required. A submenu normally remains open after showing information so you can inspect another provider, writer, table, or setting without repeatedly navigating from Help.

### Beginner and advanced modes

Start explicitly in beginner mode:

```powershell
ulp --menu --beginner-menu
```

Start in advanced mode:

```powershell
ulp --menu --advanced-menu
```

The mode can also be saved under **Options > Change runtime settings**. Use beginner mode for normal discovery. Switch to advanced mode when you need the SQL shell, connection management, background jobs, SQLite information, or multiple-output management.

### Clear screen

Interactive menus include **Clear screen** alongside terminal navigation commands. It clears the terminal and redraws the current menu without adding another title, logo, or informational page to the scrollback.

## Opening Input Data

The guided source workflow is:

1. choose **Add data source**;
2. select a data provider, choose automatic detection, or cancel;
3. enter the source or use the full-screen file/directory picker;
4. accept or edit the provider-aware table name;
5. edit properties in the full-screen TUI editor or retain factory/config defaults;
6. review the complete `CREATE VIRTUAL TABLE ... USING ParsingModule(...)` SQL;
7. edit, copy, run, or cancel.

Provider default configuration is loaded by the provider factory and is not embedded as an `-i.config` path in the generated SQL. This keeps saved SQL portable. Use `--use-factory-defaults` when provider configuration autoloading must be disabled for a run.

If an operation asks you to choose a table and only one suitable table exists, ULP selects it automatically.

### Common source choices

- files and wildcard patterns;
- several comma/semicolon-separated sources;
- negative file patterns prefixed with `!`;
- archive entries using `archive-path|entry-glob`;
- Windows Event Log channels or `.evtx` files;
- generated number/date ranges;
- Active Directory, processes, threads, source code, and managed assemblies;
- existing SQLite tables or another configured ADO.NET data source.

Use provider Help before selecting an unfamiliar source. The TUI property editor groups settings by category, shows the description/type/current value beside the list, offers direct Boolean and enum choices, opens nested settings in another TUI page, and masks secret-like values. Provider properties shown in the UI are configuration settings; parsed row fields are displayed as table schema, not mixed into the property editor.

## Query Editor

<!-- Screenshot placeholder: TUI query editor with a multiline SQL query and Run/Save actions. -->

### Writing Queries

ULP uses SQLite SQL. A typical query is:

```sql
SELECT TimeCreated,
       EventTypeName,
       SourceName,
       Message
FROM events
WHERE EventTypeName IN ('Warning', 'Error')
ORDER BY TimeCreated DESC
LIMIT 100;
```

Use `LIMIT` while exploring large sources. Materialize a forward-only provider table before joins, window functions, or another plan that scans it repeatedly:

```sql
CREATE TEMP TABLE events_snapshot AS
SELECT * FROM events;
```

### Running Queries

The shared query-review workflow shows the SQL before execution and offers actions such as edit, copy, execute, return, or create a view where applicable. Press Ctrl+C to cancel a running terminal query.

In the SQL shell, a trailing semicolon executes the buffered SQL. You can also enter `.run`, `.r`, `run`, or `go`.

In the web Query library and ad-hoc editor, click **Run query**/**Run SQL** or press Ctrl+Enter.

### Editing Queries

In the TUI choose **File > Edit / Run Query** or press F2. The multiline dialog returns to the result viewer after a successful run. Query errors stay in the editor so you can correct the SQL without losing it. Press F5 or choose **Run Query Again** to rerun the current text without reopening the editor.

In the web interface:

- saved-query source is visible only when the permission mode allows it;
- the saved Query-library editor uses a blue accent, while the Ad-hoc editor uses an amber accent, so the active workspace is visible at a glance;
- editing a saved query and choosing **Run query** executes the text currently in the editor, including unsaved changes, without overwriting the `.sql` recipe;
- running an ad-hoc query keeps the Ad-hoc workspace open after results arrive;
- edit/create/delete controls require the corresponding server permission;
- ad-hoc SQL requires `RunAdHocQueries` permission;
- running an unsaved edit of a library query also requires `RunAdHocQueries`, because the SQL is no longer the reviewed saved text;
- generated AI SQL is displayed for review and never runs automatically.

### Syntax Features

- SQLite expressions, joins, subqueries, CTEs, JSON, and window functions;
- ULP-specific text, date, numeric, filesystem, and compatibility functions;
- named parameters using `@name`, `:name`, or `$name`;
- multiple SQL statements and result sets;
- `GO` and configured script separators where supported;
- ParsingModule virtual-table declarations;
- Query library metadata for sources, parameters, commands, and default output.

The editor does not treat a parameter as an SQL identifier or arbitrary SQL fragment. Values are bound safely.

### Open, Save, and Save As

The TUI **File** menu includes:

- **Open Query...** — choose a `.sql` file;
- **Save Query** — save to the current path;
- **Save Query As...** — select a new path and create directories where needed;
- **Edit / Run Query** — open the current SQL in the multiline editor;
- **Run Query Again** — rerun the current SQL;
- **Quit**.

An empty query cannot be saved. A missing extension is completed with `.sql`.

## Results View

<!-- Screenshot placeholder: TUI table viewer with table selector, headers, selected cell, and status bar. -->

<!-- Screenshot placeholder: web result grid with filters, search, export, column chooser, and Expand action. -->

### Terminal results

The default Terminal writer formats a readable table with colors and borders. Use JSON, CSV, TSV, TOON, PlainText, or another machine-friendly writer when output is redirected to another program.

Long Markdown help, information tables, and Terminal results can use the shared terminal pager. Auto mode pages only when content is taller than the terminal.

### TUI table viewer

The TUI displays a `DataTable`-style grid and supports:

- switching among result tables from the **Tables** menu;
- full-row selection;
- optional editing mode for the in-memory displayed result;
- showing column names in the cell preview;
- toggling headers and cell lines;
- maximum cell-width choices;
- activating a cell for a larger value view/edit operation;
- copying selected cells as tab-separated text, with optional column names;
- a selected-cell status showing row and column context;
- a title showing the active result table, result-set position, dimensions, and query filename;
- F1 keyboard/navigation help inside the viewer.

Editing the displayed result does not imply that the original file, event log, provider source, or database has been updated. Data-changing SQL must be explicit.

### Web result grid

The web grid supports:

- multiple-column sorting;
- filter row and header filters;
- result search;
- column resizing and column chooser;
- row selection;
- spreadsheet export;
- one selector for multiple result tables;
- an **Expand** full-window workspace;
- virtual scrolling through all rows returned by the server.

The grid does not use a page-number pager. Scroll to reach later rows. The server still applies `--web-max-rows`; a query should also use a responsible `LIMIT` when the source is expensive.

Press Escape to leave the expanded result view.

### Sorting

UI sorting changes the displayed result. For deterministic saved/exported ordering, put `ORDER BY` in SQL.

### Selecting

Use row/cell selection for copying and inspection. Selection is not an SQL filter and does not change the saved query.

### Copying

The query-review workflow can copy SQL. Grid/table copying depends on the active interface and terminal. For reproducible data transfer, export a defined writer format rather than relying on visual selection.

### Exporting

The web grid includes its built-in spreadsheet export. ULP's output pipeline supports additional writers and multiple destinations. For repeatable exports, save the query and output options rather than treating a manual grid export as automation.

## File and Input Selection

The Add data source workflow uses a full-screen TUI picker for files and directories. It supports keyboard directory navigation, typed location entry, and explicit selection or cancellation. The smaller terminal file dialog remains available to non-menu workflows and supports:

- current-directory display;
- directory navigation;
- file/folder filtering;
- explicit path entry;
- validation before returning a selection;
- separate special commands for navigation/cancel;
- overwrite confirmation for save targets.

Selection dialogs are visually distinct from action menus. **Clear screen** is not inserted into lists where it would be mistaken for a provider, table, output format, or file.

The TUI also uses native terminal open/save dialogs for `.sql` query files. The web UI accesses only saved queries inside the configured Query library; it does not expose an unrestricted browser-side server filesystem picker.

## Saved Queries

The Query library is a recursive folder tree of `.sql` files. Subfolders become categories. A recipe can declare:

- title and concise description;
- one or more command aliases;
- provider, source, table, and provider options;
- named parameters and defaults;
- default output destination and writer.

Open it from the top-level menu or run a command directly:

```powershell
ulp -c.dir --from ".\samples\data\*" --p.extension .cs
```

The web UI displays the complete folder hierarchy. Select a query to see its description and parameters. Saved and ad-hoc modes are labelled explicitly. A saved query can be reloaded from disk or reset to its last loaded SQL; overwriting or deleting it requires confirmation. **Open in new tab** opens a URL containing the query ID and selects that query in another tab without running it.

SQL files remain authoritative. Changes made through an allowed web edit are visible to the CLI because both use the configured library directory. Rooted paths and traversal outside that directory are rejected.

### Web query sessions

Each browser tab receives an isolated ULP Web session. Query-library runs, unsaved Query-library edits, the ad-hoc editor, the safe shell, schema browsing, AI schema context, and inline query execution share that session's SQLite connection. A temporary or virtual table created in one of those surfaces is therefore immediately available in the others, and AI suggestions see the same table definitions without receiving table rows. A different browser tab or session does not inherit connection-local tables. Operations within one session are serialized so two requests cannot use the same SQLite connection concurrently. Leaving or closing the browser page asks the server to dispose that tab's session; stopping the ULP Web server disposes any sessions that remain.

## Query Builder

The interactive Query Builder reads the current SQLite catalog and automatically selects a table when only one is available. It guides column selection, filters, aggregates, grouping, sorting, limits, joins, `UNION`/`UNION ALL`, and optional materialization without hiding the SQL it creates.

A join workflow chooses the first and second tables, join type, one typed column from each side, and optional output columns. Nested **Back** or **Cancel** returns to Query Builder rather than abandoning the whole menu. Materialization choices use ordinary SQLite forms such as `CREATE TABLE ... AS SELECT ...`; use them when a streaming source would otherwise be rescanned repeatedly.

Every generated query goes through the shared **Use this query** preview. From there, edit SQL, bind parameters, copy it, execute it, save it, create a view, or go back. **Create View** saves the SQL definition; **CREATE TABLE AS** copies the current rows. No query executes merely because the builder produced it.

## Query History

### SQL shell

The SQL shell maintains session query history for review. Use its help command to see the exact history commands available in the current version.

### Web Shell

The web Shell keeps command history only in the current browser tab/session. Press Up/Down to navigate it. The Shell supports SQLite SQL plus a small safe set of ULP commands such as `.tables`, `.schema NAME`, `.info`, and `.run QUERY_ID`; it never starts operating-system commands. While a query or Shell request is active, **Stop** sends a correlated cancellation request to SQLite and closes that browser request.

### MCP session

MCP exposes query-history review and a clear-history action for its shared session. Clearing query history does not remove tables or input data.

Do not treat interactive history as a durable Query library. Save important SQL in a reviewed `.sql` file.

## Settings

<!-- Screenshot placeholder: Options menu with beginner/advanced mode, pager, output, query library, and startup behavior. -->

The Options menu manages non-sensitive preferences such as:

- beginner or advanced menu mode;
- no-command startup behavior (`help` or `menu`);
- pager behavior;
- default writer and destination;
- verbose/error/statistics behavior;
- showing tables after runs;
- Query library location;
- selected AI base URL/model metadata where applicable.

Connection strings, passwords, API keys, and other secrets are not written to the normal settings file. Connection strings displayed in the UI or logs are masked.

Provider defaults belong in `defaults.input.<TYPE>.config`, writer defaults in `defaults.output.<TYPE>.config`, and general application defaults in `defaults.ulp.config`. By default ULP uses the current working directory's `config` subdirectory.

Use configuration-generation actions to create a starting file. Existing configuration is not silently overwritten; choose another name or explicitly approve replacement.

## AI Interface

<!-- Screenshot placeholder: experimental web AI Chat with conversation, generated SQL block, and review warning. -->

AI Chat is experimental and disabled by default. Configure it in the menu's **Options → AI settings**, in a `.config` file, or with explicit startup switches. The same configuration is available to web chat and the SQL shell's `.ai question`, `.ai-run`, and `.ai-clear` commands. See [AI configuration](ai.md#configuration) for secret references and examples.

When explicitly enabled for the web interface, it can:

- receive a bounded schema description and conversation context;
- propose SQLite SQL;
- explain or revise a proposed query;
- display SQL for human review.

It never executes a proposal automatically. In the web chat, choose **Run here** to review the confirmation and display a bounded plain-table preview in the conversation, or **Open in Ad-hoc editor** for editing and the full grid. Inline result rows are not added to the conversation sent to the provider. The API key remains on the server and is not returned to the browser.

Before enabling AI, confirm authorization to send schema, prompts, and conversation content to the configured provider. Review the provider's privacy, retention, security, and regional-processing terms. Use `--web-no-ai` to forbid the endpoint.

## Menus and Commands

### Guided menu

Major beginner-menu areas include:

- data sources and tables;
- Query library;
- Query Builder;
- output selection;
- TUI;
- Options;
- Help and About.

Advanced mode adds SQL shell, SQLite connection/information, background jobs, and multiple-output management.

### SQL shell commands

| Command | Purpose |
| --- | --- |
| SQL ending in `;` | Execute the buffer |
| `.run`, `.r`, `run`, `go` | Execute the buffer |
| `.show` | Display the current buffer |
| `.clear`, `.c` | Clear the buffer |
| `.help`, `.h` | Show shell help |
| `.menu` | Return to the existing main menu |
| `.quit`, `.q`, `.exit`, `quit`, `exit` | Leave the shell |

### Web navigation

Depending on permission mode, the top navigation contains:

- Query Library;
- Ad-hoc Query;
- Shell;
- AI Chat (Experimental);
- Server.

Panels and navigation can be collapsed to preserve workspace. On narrower windows, use the Sections/navigation controls.

## Keyboard Shortcuts

| Context | Key | Action |
| --- | --- | --- |
| Running terminal query | Ctrl+C | Request cancellation |
| TUI | F1 | Show keyboard and navigation help |
| TUI | F2 | Edit and run the current query |
| TUI | F5 | Run the current query again |
| TUI | Ctrl+O / Ctrl+S | Open or save a query file |
| TUI | Ctrl+C | Copy selected cells as tab-separated text |
| TUI | Ctrl+Q | Quit |
| Web saved/ad-hoc query | Ctrl+Enter | Run the active query |
| Web expanded result | Escape | Leave expanded view |
| Web Shell | Enter | Run command |
| Web Shell | Up/Down | Navigate tab-local history |
| Terminal pager | Space, PageDown, Down | Advance |
| Terminal pager | PageUp, Up | Go back |
| Terminal pager | Home/End | Jump to beginning/end |
| Terminal pager | A | Read from the current page to the end into scrollback |
| Terminal pager | P | Resume paging after showing all |
| Terminal pager | Q or Escape | Return |

Terminal.Gui and browser behavior can also depend on the host terminal/browser. On-screen menu labels remain authoritative.

## Common UI Workflows

### Explore a file

1. Open `ulp --menu`.
2. Add a data source.
3. Choose the provider and source.
4. review/edit the generated table SQL.
5. choose **Preview table data (20 rows)** or open the table in the TUI.
6. use Query Builder or edit SQL.
7. preview and execute.
8. choose an output writer when the result should be saved.

### Run a saved recipe

1. Open **Query library**.
2. browse folders or search.
3. review the description and declared source/parameters.
4. set overrides.
5. review or temporarily edit the complete SQL.
6. run the current editor text, copy it, save deliberate recipe changes, or return. A run does not silently save the editor.

### Build a join

1. add two sources;
2. open Query Builder;
3. choose the first and second tables;
4. choose join columns and join type;
5. select output columns and filters;
6. preview the generated SQL;
7. materialize streaming inputs if repeated scans are required;
8. execute only after review.

### Work in the browser

1. run `ulp --web`;
2. choose localhost, port, HTTPS, authentication, and permission mode in guided setup;
3. accept the temporary-certificate browser warning only after verifying it belongs to your local ULP process, or use a trusted certificate;
4. select a saved query or open Ad-hoc Query when allowed;
5. bind parameters through fields or Advanced JSON;
6. run and inspect the virtual-scrolling grid;
7. expand, filter, sort, or export;
8. press Ctrl+C in the server terminal to stop.

Automation and other applications can use the same JSON service as this browser workflow. See the [Web HTTP API reference](reference.md#web-http-api); it documents authentication, permissions, sessions, endpoint bodies, cancellation, and errors.

## UI Troubleshooting

### The menu does not open

Run explicitly:

```powershell
ulp --menu
```

`ulp` without an action shows basic help unless startup mode was saved as `menu`. `--no-menu` overrides a saved menu default.

### The terminal layout is damaged

Use **Clear screen**. Resize the terminal to a practical width/height. If colors or cursor behavior remain incorrect, try Windows Terminal or another compatible host.

### Long help immediately returns to a menu

Enable paging:

```powershell
ulp --menu --pager=always
```

Use `A` to put all remaining content into terminal scrollback. Redirected output never waits for pager keys.

### The TUI does not fit

Increase the terminal window size and reduce maximum cell width from **View**. Use a file writer for very wide or very large results.

### A TUI query fails

The query remains in the editor. Read the error, inspect table schema, correct SQL, and run again. Empty SQL is rejected rather than producing a null-reference error.

### The web page cannot connect

Confirm that the server terminal still shows the listening URL, the port is not blocked, and the URL scheme is correct. HTTPS is the default; HTTP requires `--web-http`. A self-signed HTTPS certificate causes a browser trust warning.

### The web UI hides a feature

Check the server permission mode. Query source, ad-hoc SQL, editing, Shell, AI, and server manipulation are independently restricted. Hiding a control is only presentation; the server enforces every request.

### The grid shows fewer rows than expected

Check SQL `LIMIT` and `--web-max-rows`. The grid has no page-number pager; scroll within it to see later returned rows.

### A browser query is slow

Bound the SQL, avoid expensive recursive sources during exploration, materialize a source reused by a complex plan, disable unnecessary media metadata, and inspect query plans where appropriate. Cancelling the browser request may not make a non-cancellable underlying source instantaneous.

### Sensitive text appears in a screenshot

Do not share it. Redact source paths, event messages, connection information, query parameters, usernames, API/schema names, and result data. ULP masks recognized connection-string secrets, but arbitrary query results remain the user's responsibility.

## Related Chapters

- [Getting Started](getting-started.md)
- [ULP Tutorials](tutorials.md)
- [How-To Guide](how-to.md)
- [ULP Reference](reference.md)
- [Optional local web server workflow](#work-in-the-browser)
- [Configuration](reference.md#configuration)
