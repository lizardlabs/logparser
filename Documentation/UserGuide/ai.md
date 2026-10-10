# AI Features

> **Experimental release feature:** ULP includes AI Chat in the browser, guided menu, and SQL shell. Its configuration, prompts, provider compatibility, and behavior may change. It can explain a request, ask for missing information, or propose SQLite SQL using the actual schemas and function names available to that session.

AI is disabled by default. It requires an explicitly configured OpenAI-compatible API, and generated SQL is never executed automatically. Configure it with CLI flags, a `.config` file, or **Options > Configure AI (experimental)**. The TUI editor does not have an embedded AI chat.

## Contents

- [Overview](#overview)
- [Choose an AI or Agent Integration](#choose-an-ai-or-agent-integration)
- [Packaged Agent Skills](#packaged-agent-skills)
- [Connect an Agent Through MCP](#connect-an-agent-through-mcp)
- [Independent agent sessions](#independent-agent-sessions)
- [JSON or TOON for agent results](#json-or-toon-for-agent-results)
- [Use ULP Directly From an Agent](#use-ulp-directly-from-an-agent)
- [What AI Can Do](#what-ai-can-do)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Providers](#providers)
- [Models](#models)
- [API Keys and Secret References](#api-keys-and-secret-references)
- [Generating SQL Queries](#generating-sql-queries)
- [Explaining and Fixing Queries](#explaining-and-fixing-queries)
- [Example Prompts](#example-prompts)
- [Example Conversation](#example-conversation)
- [AI and ULP Data](#ai-and-ulp-data)
- [Privacy](#privacy)
- [Security](#security)
- [What Data May Leave Your Computer](#what-data-may-leave-your-computer)
- [Limitations](#limitations)
- [AI Disclaimer](#ai-disclaimer)
- [Troubleshooting](#troubleshooting)

## Overview

The experimental feature follows a review-first workflow:

1. ULP prepares a bounded description of the current SQLite tables and views.
2. You describe the result you want in AI SQL Chat.
3. ULP sends the request, recent chat context, and schema description to the configured API.
4. The provider returns proposed SQLite SQL.
5. ULP displays an explanation, clarification, or SQL proposal. In the browser it offers **Open in Ad-hoc editor** and **Run here** when SQL is available and permitted.
6. You inspect and, if necessary, edit the query.
7. You choose whether to execute it through the normal query interface.

The proposal and execution are deliberately separate. Treat generated SQL like SQL received from another person: read it before running it.

### Current availability

| Surface | AI SQL status |
| --- | --- |
| Optional web interface | Experimental; available when explicitly configured |
| Normal CLI query execution | Configuration flags; use `--shell` or `--menu` for chat |
| Guided console menu | Options: configure AI and open experimental chat |
| SQL shell | `.ai`, `.ai-run`, `.ai-clear`, `.ai-config` |
| TUI query editor | Not supported |
| MCP server | No AI-generation tool provided by ULP |

An MCP client may have its own model and can use ULP's MCP discovery/query tools, but that is a feature of the MCP client rather than the ULP AI SQL Chat described here.

## Choose an AI or Agent Integration

ULP has three distinct integration styles. They can be used independently or together:

| Integration | Best when | Where the model runs | What ULP supplies |
| --- | --- | --- | --- |
| Web AI SQL Chat | A person wants natural language converted into reviewable SQL in ULP's browser interface | The explicitly configured OpenAI-compatible service | Bounded SQLite schema context and a review-first SQL editor |
| Agent skills plus CLI | A coding or automation agent can run local commands | The agent's own host/service | Focused operating instructions and the `ulp` command-line surface |
| MCP server | An MCP-capable assistant should discover schemas, saved queries, and exports as named tools | The MCP client's own host/service | A local STDIO tool server backed by one ULP SQLite session |

The web AI API key does **not** configure an external coding agent, and connecting an MCP client does **not** enable ULP's web AI. Choose the smallest integration that fits the task:

- use direct CLI calls for deterministic scripts and one-off agent commands;
- add a packaged skill when the agent should consistently follow ULP-specific discovery, bounding, and safety practices;
- add MCP when the client benefits from typed tools, a shared SQLite session, table/schema discovery, or saved-query inspection;
- enable web AI only when you want the browser's natural-language-to-SQL experience.

## Packaged Agent Skills

The portable package includes four optional Markdown skill folders under `skills`:

| Skill | Typical requests |
| --- | --- |
| `ulp-repository-search` | Find literal or regular-expression matches, return exact line ranges, search globs, and exclude build/vendor folders |
| `ulp-code-intelligence` | Run bounded structural searches or materialize a reusable SQLite code index for symbols, calls, imports, inheritance, APIs, documentation, diagnostics, duplicates, metrics, and exact source spans |
| `ulp-data-investigation` | Inspect CSV, JSON, YAML, logs, events, files, SQLite, and other supported sources before building bounded queries |
| `ulp-query-automation` | Reuse saved recipes, bind parameters, apply lifecycle SQL, enforce conditions, and fan one result out to several writers |

Each folder contains a `SKILL.md` plus any supporting references. A skill is guidance for the agent; it is not executable code, a ULP input provider, or permission to access data. The agent still invokes the public `ulp` CLI, and normal client approvals still apply. The data-investigation skill includes a schema-grounded planning reference that requires provider discovery, table description, a bounded preview, reviewed parameters, and materialization before repeated scans.

### Install the skills in Codex

For repository-only use, copy the complete desired folders to `.agents/skills` at the repository root. For personal use across repositories, copy them to `$HOME/.agents/skills`. Keep every folder name and its references intact. Codex normally detects skill additions automatically; restart Codex if they do not appear.

```powershell
$ulpSkills = 'C:\Tools\ULP\skills'
$repoSkills = Join-Path (Get-Location) '.agents\skills'
New-Item -ItemType Directory -Path $repoSkills -Force | Out-Null
Copy-Item (Join-Path $ulpSkills 'ulp-repository-search') $repoSkills -Recurse
Copy-Item (Join-Path $ulpSkills 'ulp-code-intelligence') $repoSkills -Recurse
Copy-Item (Join-Path $ulpSkills 'ulp-data-investigation') $repoSkills -Recurse
Copy-Item (Join-Path $ulpSkills 'ulp-query-automation') $repoSkills -Recurse
```

Ensure the packaged `ulp.exe` is on `PATH`, or adapt the skill's example commands to use its absolute path. Invoke a skill explicitly when you want to force that workflow:

```text
$ulp-repository-search find every use of "retry policy" in C# and VB files,
exclude bin and obj, keep two context lines, and return at most 50 matches.
```

```text
$ulp-code-intelligence map the public API and call hints around QueryRunner.
Use bounded ULP code queries first, then inspect exact source spans before making
conclusions. Do not modify the repository.
```

For a small question, the skill uses the bundled `code-symbol`, `code-calls`, `code-context`, and related recipes directly against the files. For a larger investigation, ask it to create a task-local code index so that many follow-up SQL queries reuse one scan:

```text
$ulp-code-intelligence materialize src and tests into a temporary ULP code index.
Map public APIs, inheritance, candidate callers, duplicate declaration bodies,
complexity hotspots, and parser diagnostics. Return exact source spans for every
important finding, report the database path, and remove it when the task is done.
```

The agent can build that index with `ulp ingest ... --parser SourceCode`, add indexes for paths and symbols, query it with ordinary SQLite, and refresh it transactionally with `--replace`. Materialization is useful for repeated investigation and before/after comparisons; it does not turn ULP's extracted call and behavior hints into compiler-resolved facts. The packaged skill contains copy-ready workflows in `ulp-code-intelligence/references/materialized-codebase.md` and a broader recipe catalog in `references/query-recipes.md`.

Codex skill locations and invocation behavior are documented in [OpenAI's skill guide](https://developers.openai.com/codex/build-skills). Other compatible agents may use different skill locations; follow the client documentation and review `SKILL.md` before installation.

### What a good agent response should preserve

Ask the agent to keep evidence that another person can verify:

- source path, table name, query, and named parameter values;
- file paths and 1-based line numbers for repository evidence;
- row limits, exclusions, and whether results were truncated;
- parser diagnostics and the difference between syntax hints and compiler/runtime facts;
- the exact output path for generated artifacts;
- an explicit statement when zero rows were returned rather than treating it as a failure.

## Connect an Agent Through MCP

Start ULP as a local STDIO MCP server:

```powershell
ulp --mcp
ulp --mcp --database C:\Data\agent-session.sqlite --queries-dir C:\Data\ulp-queries
```

Use an absolute executable path in client configuration. Do not wrap the command in a script that prints banners to standard output because stdout carries the MCP protocol.

After the client starts the server, ULP's initialization guidance includes the exact installed CLI and skills paths. Resource-capable clients can read `ulp://runtime` and then `ulp://skills/{name}`. The runtime resource lists every packaged skill with its exact `SKILL.md` path and resource URI. If a client does not show MCP resources, call `GetRuntimeInfo`, `ListAgentSkills`, and `GetAgentSkill` instead. You should not need to manually point the agent at the executable or skills folder after MCP initialization.

The complete generated setup includes copy-ready configuration for Codex/ChatGPT desktop, VS Code and GitHub Copilot, GitHub Copilot CLI, Claude Desktop, Cursor, and other STDIO clients: [MCP client configuration](reference/generated/mcp-reference.md#client-configuration).

A reliable first conversation separates inspection from execution:

```text
Use the ULP MCP server. List saved file queries, inspect the `dir` recipe, and
load it with extension=.log and source=C:\Logs\*. Show the prepared SQL and
bindings, but do not execute it yet.
```

After reviewing the prepared SQL:

```text
Execute that prepared recipe with the same arguments. Return the ten largest
files with their original paths and sizes. Do not export or modify anything.
```

For an ad-hoc data source, the preferred tool order is:

1. `ListDataProviders`;
2. `GetRecordProviderHelp` for the selected provider;
3. `CreateVirtualTable` for each source;
4. `ListTables` and `DescribeTable`;
5. `MaterializeTable` if a join/window plan rescans a streaming table;
6. `ExecuteQuery` with a bounded exploratory query;
7. `ListResultWriters` and `ExportQuery` only when an output artifact is requested.

For a saved recipe, use `ListSavedQueries`, `GetSavedQuery`, `LoadSavedQuery`, review `preparedSql` and `bindings`, then call `ExecuteSavedQuery`. Loading does not execute; execution may read source data. ULP returns JSON from query tools for interoperability and exposes other formats through explicit export.

### Configure common MCP clients

| Client | Recommended entry point | ULP server type |
| --- | --- | --- |
| Codex / ChatGPT desktop / Codex IDE extension | Settings > MCP servers, `codex mcp add`, or `.codex/config.toml` | STDIO |
| VS Code / GitHub Copilot | **MCP: Add Server** or `.vscode/mcp.json` | STDIO |
| GitHub Copilot CLI | `/mcp add`, `copilot mcp add`, or `~/.copilot/mcp-config.json` | Local/STDIO |
| Claude Desktop | Local server configuration; ULP is not packaged as a `.mcpb` extension | STDIO |
| Cursor | `.cursor/mcp.json` or Cursor MCP settings | STDIO |

Client schemas and configuration locations evolve independently of ULP. The generated reference records the values ULP needs, while the linked client documentation is authoritative for the surrounding file shape.

## Independent agent sessions

Call `GetRuntimeInfo` to discover the installed CLI path instead of searching the disk or guessing a release folder. The response also identifies the working directory, Query library, skills directory, skill entry points, and resource URIs. It does not expose API keys or connection strings. Skill reads accept only discovered packaged names; arbitrary paths and traversal are rejected.

For parallel tasks, call `CreateSession` once per task and pass the returned `sessionId` on every data tool call. This includes virtual-table creation, table inspection, query and saved-query execution, exports, materialization, dropping tables, and history. Help and recipe discovery remain shared. Calls that omit the ID use the existing default database.

Named sessions each have their own in-memory tables and history. One busy session does not hold the database lock for another. There are at most 32 named sessions; close unused ones with `CloseSession`. A busy-session error means an operation already owns that session; wait or use another task session, not repeated identical submissions. The five-second contention limit is not a query runtime limit.

Before closing, export anything worth keeping. A separate CLI process cannot see in-memory or TEMP tables from an MCP session. For cross-process reuse, explicitly materialize to a file-backed SQLite database and report its path. A snapshot also needs a refresh policy: changed source files do not update previously materialized rows automatically.

Session IDs are not credentials or authorization boundaries. All tasks share the process's operating-system account and file permissions. See the [MCP reference](reference/generated/mcp-reference.md) for examples and client setup.

## JSON or TOON for agent results

Keep JSON as the default for MCP interoperability. `ExecuteQuery` returns JSON; use `ExportQuery` with `writer: "TOON"` when a consuming agent explicitly supports TOON. This changes result representation, not the MCP protocol envelope or tool arguments.

TOON can avoid repeating column names for uniform rows. It is not automatically smaller for nested, irregular, or very small results, and a smaller byte count does not prove fewer model tokens or more accurate answers. Do not promise a fixed saving or assume a model understands unfamiliar syntax correctly.

For your actual workload, compare the **same selected columns and rows** in both formats, include metadata and tool-envelope overhead, count tokens with the target model's tokenizer, and check that the agent recovers every value, NULL, type, newline, and delimiter correctly. Keep JSON when the consumer expects structured JSON. Use TOON only when the measured saving is worthwhile and round-trip interpretation remains reliable.

The most dependable reduction comes before formatting: filter rows, project only needed fields, aggregate, return source spans instead of entire files, and materialize once for repeated analysis. A 30-row evidence table in JSON usually serves an investigation better than an entire repository dumped in any compact format.

## Use ULP Directly From an Agent

### Make ULP the first choice for code investigation

Place a short policy in your repository's agent-instruction file so you do not need to repeat it in every prompt. Adapt the scope and installation path to your workspace:

```text
For code inventory and repeated code analysis, prefer ULP over repeated shell
file scans. Discover ULP's executable via MCP GetRuntimeInfo when available.
Inspect SourceCode help, schema, and Code library recipes before writing SQL.
Start with a bounded subtree and exclude dependencies and generated output.
Use a separate MCP session for this task and pass its sessionId consistently.
For many questions, materialize once into a task-local SQLite snapshot and reuse it.
Select only fields needed for the question; return paths and exact source spans.
Use TextLine for literal phrases or bounded context that structural parsing misses.
Verify important findings against source. Text matches and parser hints do not
prove runtime dispatch or semantic call relationships. Report parser diagnostics.
Do not modify source code or remove a persistent snapshot without task authority.
Report the snapshot path and refresh it deliberately after source changes.
```

Useful investigation recipes:

| Question | ULP approach | Evidence to return |
| --- | --- | --- |
| Which declarations implement parsing? | Filter `SourceCode` by kind/name; inspect signatures and bodies only for candidates. | Full name, language, file, start/end line |
| What is the public surface of this component? | Query declaration/accessibility fields from the actual schema. | Types, public members, signatures, spans |
| Where might a changed method be called? | Use the Code call recipes, then verify candidates in source. | Caller/callee hints, source text, uncertainty |
| Which methods deserve review first? | Rank available complexity/size metrics and inspect parser diagnostics. | Metric, declaration, span; no unsupported quality verdict |
| Which files contain a phrase? | Use `TextLine` or the saved text-search recipe before structural parsing. | Matching path, line number, bounded context |
| What is between these two lines? | Inspect `TextLine` fields and filter the recorded line-number column to the requested range. | Exact text with line numbers |
| Are comments misleading a structural search? | Disable comments in `SourceCode`; use text search separately when comments are relevant. | Search scope and parser options |
| Do many questions need the same repository? | Materialize rows once, index repeatedly filtered columns, then reuse ordinary SQLite tables. | Snapshot path, source scope, creation/refresh state |
| Did the source change? | Rebuild a deliberate snapshot; compare stable paths, names, spans, and available hashes. | Added/removed/changed candidates, verified examples |

Start with the [code-snapshot tutorial](tutorials.md#build-a-searchable-code-snapshot). The Code library also includes language-specific queries for C#, VB.NET, Razor, HTML, JavaScript, TypeScript, Python, Java, and Markdown. Read the recipe's description and parameters before using it; do not assume every language provides identical fields or compiler-level semantic resolution.

MCP is optional. Any agent allowed to run commands can use ULP as a deterministic local tool. Prefer machine-readable, bounded output:

```powershell
ulp search "TODO|FIXME" . --regex --recursive `
  --include "*.cs" --include "*.vb" `
  --exclude "bin/**" --exclude "obj/**" `
  --limit 100 --format jsonl
```

```powershell
ulp -i SourceCode --from '.\src\*' --table code `
  --query "SELECT FileName, Kind, Name, StartLine, EndLine FROM code WHERE Name=@name LIMIT 50" `
  --param name=QueryRunner --format JSON --no-pager
```

```powershell
ulp -c.dir --from 'C:\Logs\*' --param extension=.log `
  --format JSON --no-pager --no-env
```

Useful practices for agent calls:

- use `--no-env` when inherited user settings would make a run non-reproducible;
- use `--format JSON` or `jsonl` search output when the agent must parse rows;
- use a small `LIMIT` during discovery and widen only after inspecting the schema;
- pass values with `--param` instead of substituting text into SQL;
- choose `--output none` with `--expect-scalar`, `--require-rows`, or `--require-condition` for automation gates;
- require explicit approval before remote access, destructive SQL, Query library mutations, output overwrite, or post-actions.

## What AI Can Do

The current feature is focused narrowly on generating SQLite queries. It is useful for requests such as:

- selecting and renaming columns;
- filtering by text, number, null, or date conditions;
- grouping and aggregation;
- joins between current tables;
- common table expressions and window functions;
- log-analysis summaries;
- using a known ULP or SQLite function when it appears in the supplied schema/context and the model knows its syntax.

The result is a SQL proposal, not a guaranteed-correct answer. The model does not run a query, inspect returned rows, validate business meaning, or confirm that an expensive query is appropriate for a streaming source.

## Getting Started

Before enabling AI, create a secret through an environment variable, secret file, or Windows Credential Manager. Do not put the literal API key in a checked-in configuration file or reusable command.

Start the optional web interface with AI enabled:

```powershell
ulp --web --web-ai --web-ai-key '@env:ULP_AI_API_KEY'
```

This uses the build's default API base URL and model identifier. For repeatable operation, choose both explicitly:

```powershell
ulp --web `
  --web-ai `
  --web-ai-base-url https://api.openai.com/v1 `
  --web-ai-model gpt-4.1-mini `
  --web-ai-key '@env:ULP_AI_API_KEY' `
  --web-ai-timeout 60
```

Then:

1. open the URL displayed by ULP;
2. choose **AI Chat — Experimental**;
3. enter a request;
4. select **Generate SQL**;
5. inspect the response;
6. choose **Open in Ad-hoc editor** only when the SQL is suitable;
7. edit or run it through the normal web query workflow.

For non-local access, configure HTTPS and authentication as described in the [browser workflow](user-interface.md#work-in-the-browser). AI configuration does not secure the web server by itself.

## Configuration

### Command-line options

| Option | Purpose | Default/notes |
| --- | --- | --- |
| `--web-ai` | Enable the experimental AI endpoint | Off |
| `--web-no-ai` | Forbid the AI endpoint for this run | Useful in restricted deployments |
| `--web-ai-base-url <url>` | Select the OpenAI-compatible API base URL | `https://api.openai.com/v1` in the documented build |
| `--web-ai-key <secret>` | Supply the API key or a secret reference | Required when AI is enabled |
| `--web-ai-model <name>` | Select the provider's model identifier | `gpt-4.1-mini` in the documented build |
| `--web-ai-timeout <seconds>` | Set the request timeout | 60; accepted range 1–600 |

If the base URL does not end in `/chat/completions`, ULP appends that path. A complete Chat Completions URL is also accepted.

### Environment settings

These environment variables map to the same web AI settings:

| Environment variable | Equivalent option |
| --- | --- |
| `ULP_WEB_AI` | `--web-ai` when set to a true value |
| `ULP_WEB_AI_BASE_URL` | `--web-ai-base-url` |
| `ULP_WEB_AI_KEY` | `--web-ai-key` |
| `ULP_WEB_AI_MODEL` | `--web-ai-model` |
| `ULP_WEB_AI_TIMEOUT` | `--web-ai-timeout` |

`ULP_WEB_AI_KEY` contains a value directly. `--web-ai-key '@env:NAME'` instead tells ULP to read a differently named environment variable as a secret reference. The latter is useful when one existing secret name is shared with another application.

### Configuration files

Non-secret AI options may be placed in a ULP `.config` file:

```text
--web-ai
--web-ai-base-url="https://api.openai.com/v1"
--web-ai-model="gpt-4.1-mini"
--web-ai-timeout="60"
--web-ai-key="@env:ULP_AI_API_KEY"
```

Store only the reference, not the key. ULP does not persist literal API keys to its normal interactive settings file. `--ai`, `--ai-base-url`, `--ai-model`, `--ai-timeout`, and `--ai-key` are shared names for the same settings; the `--web-ai*` names remain accepted aliases. Use `--no-ai` to disable saved AI settings for one invocation.

### Configure from the menu

Run `ulp --menu`, open **Options > Configure AI (experimental)**, and choose the endpoint, model, timeout, and key method. Prefer **Use a secret reference**. You can save the enabled state and non-secret settings plus that reference in `<config-dir>/settings.config`. A literal key entered through the masked prompt is kept for this process only. Saving does not test the provider or send a request.

### Chat in the SQL shell

```powershell
ulp --config ai.config --shell --input TextLine --from samples/data/application.log --table logs
```

Enter `.ai Find error messages and explain the query`. The response is a proposal, not an execution. Ask follow-ups with `.ai ...`; use `.ai-run` only after reviewing the SQL. `.ai-clear` removes the in-memory conversation and last proposal. `.ai-config` opens settings when the shell has an interactive terminal. Ctrl+C cancels a pending AI request.

### Keep results inside browser chat

Choose **Run here** beneath a SQL proposal and confirm that you reviewed it. A simple table appears in the same message; the app does not navigate to the Query library or Ad-hoc editor. The inline preview displays at most 100 rows and 30 columns per result set, truncating very long cells. The normal server result limit also applies. Use the Ad-hoc grid or export for complete interactive results.

Inline results are not added to the model's conversation or sent back to the provider automatically. Browser chat history retains the conversation and SQL locally, not these inline result tables. **New chat** clears that history. Query permissions still apply; disabling ad-hoc execution also disables inline execution.

## Providers

ULP uses an OpenAI-compatible Chat Completions request. A compatible service must:

- accept an HTTP `POST` at a `/chat/completions` endpoint;
- accept a JSON request containing `model` and `messages` (ULP does not force optional sampling parameters);
- accept bearer-token authentication;
- return generated text in `choices[0].message.content`;
- return SQLite SQL as text.

The default base URL targets OpenAI. Other services may work when they implement the same request and response contract, but compatibility is provider- and version-specific. ULP does not bundle, download, host, or manage an AI model.

Use HTTPS for any non-loopback provider. Although an HTTP base URL is accepted for controlled local services, HTTP sends the prompt, schema, and bearer value without transport encryption.

Provider account creation, model availability, pricing, data retention, geographic processing, rate limits, and terms are controlled by that provider. Confirm them before sending sensitive schema information.

## Models

`--web-ai-model` is passed to the configured provider as its model identifier. The documented build defaults to `gpt-4.1-mini`; the provider may rename, retire, deny, or not implement that identifier.

Choose a model that:

- is available to the configured API key;
- supports the Chat Completions-compatible endpoint;
- follows the requested `message` and optional `sql` response format, or returns clearly fenced SQL;
- has enough context for the schema and request;
- meets the organization's privacy, residency, latency, and cost requirements.

ULP does not query the provider's model list or automatically fall back to another model. An invalid or unavailable identifier produces a provider request error.

## API Keys and Secret References

The entire key value may be supplied through one of these references:

- `@env:NAME` reads an environment variable;
- `@file:path` reads a secret file and removes final line endings;
- `@wincred:target` reads a Generic credential from Windows Credential Manager for the current logon session.

Examples:

```powershell
ulp --web --web-ai --web-ai-key '@file:C:\Secrets\ulp-ai-key.txt'
```

```powershell
ulp --web --web-ai --web-ai-key '@wincred:ULP-AI'
```

Protect all three sources:

- limit access to the environment, file, or credential;
- use a key with only the permissions the provider requires;
- rotate a key after accidental disclosure;
- keep keys out of source control, screenshots, copied terminal output, and saved queries;
- avoid a literal key on the command line because process listings and shell history may expose it.

ULP resolves secret references in memory and does not return the key to the browser. A provider still receives the key in the authorization header, as required to authenticate the request.

## Generating SQL Queries

Good prompts state the desired table, columns, filters, grouping, ordering, and row limit. Use actual table and column names when known.

Weak prompt:

```text
Show errors.
```

Better prompt:

```text
From tEvt1, show ProviderName, EventId, and TimeCreated for Error-level
records from the last 24 hours. Put newest records first and limit the result to 100.
```

Ask for bounded exploratory output. ParsingModule tables can represent large or streaming sources, so `LIMIT` may reduce displayed rows but does not always eliminate all upstream work required by filtering, sorting, grouping, or joins.

### Review checklist

Before opening generated SQL in the editor, confirm:

- every table and column exists;
- date/time comparisons use the source's actual representation;
- null handling matches the question;
- joins use the intended keys and do not multiply rows unexpectedly;
- aggregation groups at the correct level;
- ordering and limits are present when appropriate;
- functions exist in the [SQL Function Reference](functions.md);
- the query does not expose secrets or sensitive records;
- the expected work is reasonable for the input size.

Opening a proposal in the editor still does not execute it. The normal Run action remains a separate decision.

## Explaining and Fixing Queries

ULP does not currently provide separate AI **Explain query** or **Fix query** commands. The experimental web endpoint is instructed to return SQL rather than prose.

You can include an existing query in a prompt and request a corrected replacement, for example:

```text
Rewrite this query so it groups errors by ProviderName and orders by the count
descending. Preserve the 7-day filter:

SELECT ProviderName, COUNT(*) AS ErrorCount
FROM tEvt1
WHERE EventTypeName = 'Error'
  AND TimeCreated >= datetime('now', '-7 days');
```

The response is still only a proposed replacement. It is not a diagnostic explanation, and the model cannot see an earlier SQLite error unless you include a safe, relevant part of that error in the prompt.

Do not paste credentials, connection strings, personal records, full logs, or proprietary source data into a repair prompt.

## Example Prompts

### Event errors by provider

```text
Using tEvt1, count Error-level events by ProviderName for the last 7 days.
Return ProviderName and ErrorCount, highest count first, limited to 20 providers.
```

### Slowest requests

```text
Using WebLogs, show the 95th percentile of TimeTaken grouped by UriStem.
Ignore null durations, require at least 20 requests per URI, and return the 25
slowest groups.
```

### Join two inputs

```text
Join employees to departments using DepartmentId. Return employee Name,
department Name as DepartmentName, and Location. Keep employees without a
matching department and order by employee Name.
```

### Find rare values

```text
From AccessLogs, count rows by ClientIp. Return only IPs occurring fewer than
three times, then sort by count and ClientIp.
```

### Normalize file sizes

```text
From Files, return FullPath, Size, and humanize_bytes(Size) as ReadableSize for
files larger than 100 MiB. Sort largest first and limit to 100.
```

### Window comparison

```text
For each day in Events, count errors and add a column containing the previous
day's count using a window function. Return the date, count, previous count,
and difference.
```

## Example Conversation

**User**

```text
Show the top event providers by error count during the last 24 hours.
```

**Possible AI proposal**

```sql
SELECT ProviderName,
       COUNT(*) AS ErrorCount
FROM tEvt1
WHERE EventTypeName = 'Error'
  AND TimeCreated >= datetime('now', '-24 hours')
GROUP BY ProviderName
ORDER BY ErrorCount DESC
LIMIT 20;
```

**User follow-up**

```text
Add the newest event time for each provider and exclude null provider names.
```

**Possible revised proposal**

```sql
SELECT ProviderName,
       COUNT(*) AS ErrorCount,
       MAX(TimeCreated) AS NewestEvent
FROM tEvt1
WHERE LevelDisplayName = 'Error'
  AND TimeCreated >= datetime('now', '-24 hours')
  AND ProviderName IS NOT NULL
GROUP BY ProviderName
ORDER BY ErrorCount DESC
LIMIT 20;
```

These examples assume those names and values exist in the selected provider schema. The actual proposal depends on the schema sent by the running instance and the configured model.

## AI and ULP Data

ULP gives the provider schema context so it can use real names instead of guessing. The context contains a bounded list of user tables and views with column names and declared types. It does not include result rows or source-file contents by default.

The current context is derived from the web server's SQLite connection. Therefore:

- command-line input blocks supplied when starting the web server can affect the schema;
- explicitly loaded session-initialization SQL can affect the schema;
- saved-query recipes may create sources only when their query runs and may not appear in advance;
- temporary or connection-specific objects may not exist in the context used for a later request;
- similarly named providers can have different schemas.

If the model invents a name, compare its query with the schema shown in ULP and correct the query manually.

## Privacy

AI processing is not local unless the configured base URL points to a service running locally. When a remote URL is used, the configured provider processes the request.

ULP itself does not enable telemetry merely because AI Chat is enabled. The external AI request is intentional network activity. The provider may retain prompts or metadata according to its own policy and account settings.

The browser stores recent AI conversation messages in that tab's session storage so the conversation survives navigation and can provide follow-up context. Choose **New chat** to clear that browser-session history. Closing the tab normally clears session storage, but browser restore behavior varies; do not rely on tab closure as a secure erasure mechanism.

ULP does not persist the API key in browser storage or return it through the server-information endpoint.

## Security

Use these controls together:

1. keep AI disabled when it is not needed;
2. bind the web server to localhost unless remote access is required;
3. use HTTPS and authentication for non-local access;
4. prefer a restricted web permission mode;
5. use a protected secret reference rather than a literal key;
6. choose a trusted API base URL and verify its certificate;
7. review generated SQL before execution;
8. use least-privilege access to input files, databases, event logs, and output locations;
9. avoid prompts containing secrets or raw sensitive records;
10. stop the server when the session is complete.

`--web-no-ai` is an explicit deployment control. Use it when a shared configuration or environment could otherwise enable AI:

```powershell
ulp --web --web-no-ai --web-mode query-runner
```

The AI endpoint accepts proposals beginning with read-oriented SQLite forms such as `SELECT`, `WITH`, `PRAGMA`, or `EXPLAIN`, but this is not a substitute for human review or database permissions. Some pragmas and functions can change state or access the filesystem. Review the complete statement and apply the [function safety guidance](functions.md#about-this-reference).

## What Data May Leave Your Computer

When AI Chat is used with a remote provider, ULP sends:

- the current user prompt;
- up to the recent bounded conversation context used for follow-up questions;
- table and view names from the current SQLite schema;
- column names and declared types for those tables/views;
- a system instruction describing the SQL-generation task;
- the configured model identifier;
- the API key in the authorization header;
- ordinary network metadata such as source address and request timing.

ULP does **not** intentionally include these items by default:

- query result rows;
- complete input files or event records;
- saved-query file contents;
- arbitrary local files;
- database connection strings;
- the web-server password;
- the API key in the browser-visible response.

However, names themselves may be sensitive, and anything you type into the prompt becomes transmitted content. A table or column name can reveal customer names, project codenames, security controls, or data classifications. Review schema naming as well as row data when deciding whether the provider is acceptable.

## Limitations

- The feature is experimental and may change in future releases.
- It is available only through the optional web interface.
- It generates SQLite SQL; it is not a general conversational assistant.
- It does not execute or validate the returned query automatically.
- It does not inspect result rows and cannot confirm that the answer is correct.
- It may invent tables, columns, functions, or value formats despite its instructions.
- Schema context is bounded and may omit very large catalogs.
- Conversation context is bounded; older messages eventually stop being sent.
- A single prompt is limited in length.
- The provider must implement the expected Chat Completions request/response form and bearer authentication.
- ULP requires a non-empty API-key setting even when a controlled local compatible service would otherwise accept anonymous requests.
- Provider outages, quotas, rate limits, content filters, and model changes are outside ULP's control.
- SQL safety checks do not prove semantic correctness, low cost, or absence of side effects.
- Generated queries may be slow against large, recursive, remote, or streaming inputs.

## AI Disclaimer

AI-generated SQL can be incomplete, inefficient, misleading, or unsafe. Verify the query, its data access, and its output before relying on it. Do not use generated results as the sole basis for security, legal, medical, financial, employment, compliance, or operational decisions.

You are responsible for determining whether data may be sent to the configured provider and whether that processing complies with applicable policy, contracts, law, and regulation. ULP does not grant permission to disclose data and does not control a third-party provider's retention or use.

## Troubleshooting

### AI Chat says it is not configured

Confirm all three requirements:

```text
--web-ai
--web-ai-key <secret-or-reference>
--web-ai-model <provider-model>
```

The base URL must be an absolute HTTPS URL for remote services. Plain HTTP is accepted only for a loopback service on your computer. Do not embed credentials or query parameters in the URL. Restart the web server after changing startup options.

### `Web AI requires --web-ai-key`

The reference resolved to no value or the option was omitted. Verify the environment variable, secret-file path, or Windows credential under the same account that runs ULP. Do not print the secret while diagnosing it.

### Provider request failed with 401 or 403

Check the key, account permissions, provider base URL, and model access. Rotate the key if it may have been exposed. ULP reports the HTTP status but deliberately omits the provider response body, which might contain sensitive information. Check the provider's account dashboard for access or quota problems.

### Provider request failed with 404

Verify the base URL. Supply either the API base ending before `/chat/completions` or the complete Chat Completions URL. Confirm that the chosen service implements that endpoint.

### Provider request times out

Increase `--web-ai-timeout` within the accepted 1–600 second range, choose a faster model, reduce a very large schema, or diagnose network/provider latency. A longer timeout does not fix an unavailable endpoint.

### The provider returned an explanation without SQL

A clarification or explanation is a valid chat response; it does not need SQL. Answer the question or ask for a concrete query against a named table. Execution buttons appear only when there is a SQL proposal. If the provider returns no message at all, verify that it supports Chat Completions text responses.

### ULP rejected the returned text

ULP accepts a SQL proposal only when it begins with a read-oriented SQLite form. Ask the model to return a JSON object with `message` and `sql` fields; `sql` can be null when clarification is needed. SQL-only and fenced SQL replies from compatible providers are also accepted. Prefix validation is not a security sandbox: review the complete SQL before executing it.

### The generated query reports `no such table` or `no such column`

The proposal used a name absent from the execution connection. Refresh the current table/schema information, use the exact identifier in a new prompt, and edit the query before running it. A saved-query recipe may create a source only as part of its own execution.

### The generated query is slow

Add selective filters and a sensible `LIMIT`, avoid unnecessary sorting and broad joins, and inspect the query plan. Remember that a final limit does not guarantee that a recursive input, aggregate, sort, or join reads only that number of source rows.

### AI Chat is visible but disabled

The server reports AI availability to the browser. If it was started without complete AI configuration or with `--web-no-ai`, the controls remain unavailable. Restart with the intended settings; the browser cannot enable the server-side feature.

## Related Documentation

- [User Interface](user-interface.md)
- [SQLite Guide](sqlite-guide.md)
- [SQL Function Reference](functions.md)
- [Tutorial: review an AI-assisted investigation](tutorials.md#review-an-ai-assisted-investigation)
- [Configuration](reference.md#configuration)
- [Optional local web server](user-interface.md#work-in-the-browser)
- Consolidated security chapter — planned; current web and AI security guidance is included above
