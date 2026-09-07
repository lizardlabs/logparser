# Input and Output Formats

ULP separates three decisions:

1. an **input provider** reads a source and exposes records as table rows;
2. an **output destination** decides where a result goes;
3. an **output writer** decides how the result is represented.

This chapter is the readable format manual. Exact provider fields and configurable properties remain generated reference material because they change with the runtime.

## Contents

- [Input Formats](#input-formats)
- [Choosing an Input Provider](#choosing-an-input-provider)
- [File and Stream Source Syntax](#file-and-stream-source-syntax)
- [CSV, TSV, and Delimited Text](#csv-tsv-and-delimited-text)
- [JSON, YAML, and TOON](#json-yaml-and-toon)
- [Text and Log Inputs](#text-and-log-inputs)
- [Windows and System Inputs](#windows-and-system-inputs)
- [File, Source Code, Assembly, and Excel Inputs](#file-source-code-assembly-and-excel-inputs)
- [Generated and Extensible Inputs](#generated-and-extensible-inputs)
- [Incremental Input and Checkpoints](#incremental-input-and-checkpoints)
- [Output Formats](#output-formats)
- [Choosing a Destination and Writer](#choosing-a-destination-and-writer)
- [Terminal and Text Output](#terminal-and-text-output)
- [Structured Data Output](#structured-data-output)
- [Documents, Workbooks, and Templates](#documents-workbooks-and-templates)
- [Multiple Output Pipelines](#multiple-output-pipelines)
- [Output Files and Overwrite Behavior](#output-files-and-overwrite-behavior)
- [Format Compatibility Matrix](#format-compatibility-matrix)
- [Generated Format References](#generated-format-references)

# Input Formats

## Overview

Start a provider block with `--input`/`-i`, select its source with `--from`, and optionally name its table:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees LIMIT 20"
```

Repeat provider blocks to create several tables:

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --input CSV --from .\samples\data\departments.csv --table departments `
    --query-file .\samples\sql\00-materialize-sources.sql
```

If a table name is omitted, ULP chooses a provider-aware name such as `tCsv1` or `tEvt1` and avoids collisions. When you write durable SQL, explicit meaningful names are usually clearer.

Use these discovery commands against the executable you are running:

```powershell
ulp --list-providers
ulp --help-provider CSV
```

Provider defaults are loaded from `config/defaults.input.<TYPE>.config` unless `--use-factory-defaults` disables configuration autoloading. Generated ParsingModule SQL does not embed the config-file path.

## Choosing an Input Provider

The following providers are registered in the documented ULP runtime:

| Provider | Aliases | Category | Best for |
| --- | --- | --- | --- |
| `EVT` | `WindowsEventLog` | Windows events | Modern Windows channels and `.evtx` files |
| `EVTXECMD` | — | Forensic events | `.evtx` parsing with EvtxECmd-compatible fields |
| `EVTXP` | — | Windows events | Classic Win32 event-log access |
| `CSV` | — | Structured text | RFC-style comma-separated records |
| `TSV` | — | Structured text | Tab-separated records |
| `Delimiter` | `Delimited` | Structured text | A configurable delimiter/quote/escape syntax |
| `JSON` | — | Structured data | JSON objects and arrays |
| `YAML` | `YML` | Structured data | YAML documents, mappings, and sequences |
| `TOON` | — | Structured data | TOON 4.1 tabular/keyed-tabular input |
| `TextLine` | `Lines` | Text | One record per line |
| `TextWord` | `Words` | Text | Tokenized words |
| `RegEx` | `Grok` | Text parsing | Multiline regular-expression or Grok records |
| `W3C` | — | Web/server logs | IIS, FTP, SMTP, Exchange, firewall, and other W3C extended logs |
| `log4jXML` | — | Application logs | Log4j/log4net XML events |
| `Excel` | `XLSX`, `XLS` | Workbook | `.xlsx`, `.xlsm`, and `.xls` without Office/ACE drivers |
| `FileSystem` | `FS` | File system | Files/directories, sizes, timestamps, and optional media metadata |
| `SourceCode` | `CSharp`, `CS` | Code | C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown structure |
| `DotNetAssembly` | `Assembly`, `DotNet` | Managed binaries | Static metadata from managed `.dll` and `.exe` files |
| `ADS` | `ActiveDirectory`, `LDAP` | Directory services | Active Directory objects/properties and Log Parser-compatible modes |
| `Processes` | `Process`, `PROC` | System snapshot | Local process memory, CPU, handles, threads, and executable details |
| `Threads` | `ProcessThreads`, `THR` | System snapshot | Operating-system thread state, priority, and sampled CPU |
| `Numbers` | — | Generated data | Numeric series for ranges, joins, and tests |
| `Dates` | — | Generated data | Date series for calendars, ranges, and tests |
| `CustomPlugin` | `DotNetPlugin` | Extension | Records from an explicitly selected custom .NET source plugin |

Do not choose a provider by filename alone when several interpretations are possible. A `.txt` file might be lines, words, delimited fields, regular-expression records, W3C data, or another log grammar.

## File and Stream Source Syntax

Stream-based providers accept local files, wildcards, and—where supported—URLs. Several sources can be separated by comma or semicolon:

```text
C:\Logs\api-*.log;C:\Logs\worker-*.log
```

Expansion is lazy. Taking the first records does not require ULP to build a complete recursive list first.

### Exclusions

Prefix a negative file pattern with `!`:

```text
C:\Logs\*;!*.bak;!archive-*.log
```

When every entity is negative, ULP implicitly includes `*` before applying exclusions. Use `!!name` to escape a literal leading exclamation mark. On Windows, filename-pattern comparison is case-insensitive.

An exclusion containing a relative directory is resolved from each positive wildcard's directory. For example, `C:\Logs\*.txt;!archive\*.txt` excludes matches below `C:\Logs\archive` when recursion is enabled. A filename-only exclusion such as `!*.bak` applies at every recursive depth.

### Archive entries

Use `archive-path|entry-glob`:

```text
C:\Logs\archive.zip|*.log
C:\Logs\*.zip|errors\*.txt
```

ZIP, TAR, RAR, 7z, BZip2, and other formats depend on the archive support shipped with ULP. Ordinary `.gz` behaves as a transparent single compressed stream.

Read an archive password from an environment variable rather than exposing it inline:

```text
file:///C:/Logs/archive.zip?password-env=ULP_ARCHIVE_PASSWORD|*.log
```

Outer exclusions filter archive files; the entry glob filters content inside each selected archive.

## CSV, TSV, and Delimited Text

### Detection

`CSV` uses a comma, `TSV` uses a tab, and `Delimiter` allows another delimiter. Use the explicit provider when the format is known. Delimiter detection is quote-aware but cannot make every ambiguous short sample unambiguous.

### Options

Common concerns include:

- header row versus explicit header;
- delimiter, quote, and escape behavior;
- encoding/BOM;
- typed header suffixes and header replacements;
- combining headers across several files;
- malformed-input error policy;
- extended source fields;
- checkpoints.

Use generated help for exact property names/defaults:

```powershell
ulp --help-provider CSV
ulp --help-provider TSV
ulp --help-provider Delimiter
```

### Types

Delimited values often begin as text. Use provider typing options when the schema is stable, or cast in SQL:

```sql
SELECT CAST(status AS INTEGER) AS status,
       CAST(duration_ms AS REAL) AS duration_ms
FROM requests;
```

### Example

```powershell
ulp --input TSV --from .\samples\data\requests.tsv --table requests `
    --query "SELECT status, COUNT(*) AS requests FROM requests GROUP BY status ORDER BY CAST(status AS INTEGER)"
```

### Limitations

Malformed quoting fails predictably with source/line context according to the configured error policy. Do not silently reinterpret broken CSV as unquoted lines. A streaming parser does not load the complete file, but SQL sorting/grouping can still require substantial SQLite memory or temporary storage.

## JSON, YAML, and TOON

### JSON

Reads objects and arrays from files or streams:

```powershell
ulp --input JSON --from .\samples\data\structured-sample.json --table people `
    --query "SELECT id, name, active FROM people ORDER BY id"
```

Use SQLite JSON functions when an existing column contains nested JSON text. Provider schema depends on the document shape.

### YAML

Reads YAML documents, mappings, and sequences. YAML can express types and structures that do not map perfectly to a flat table; inspect the resulting schema before writing a durable query.

```powershell
ulp --input YAML --from .\samples\data\structured-sample.yaml --table records `
    --query "SELECT * FROM records LIMIT 20"
```

### TOON

Reads TOON 4.1 tabular and keyed-tabular data:

```powershell
ulp --input TOON --from .\samples\data\structured-sample.toon --table records `
    --query "SELECT * FROM records LIMIT 20"
```

TOON can be compact for language-model contexts, but JSON is more widely interoperable. Choose based on the receiving tool, schema fidelity, and measured token usage rather than assuming one format is always smaller or safer.

## Text and Log Inputs

### TextLine

Exposes one `Text` value per line by default:

```powershell
ulp --input TextLine --from .\samples\data\application.log --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%'"
```

Use direct `search` when SQL is unnecessary.

### TextWord

Tokenizes streams into words for frequency and vocabulary analysis. Confirm the generated field names/tokenization properties for the current runtime.

### RegEx / Grok

Use a record pattern with named groups to turn unstructured or multiline logs into columns. Grok patterns are translated to regular expressions by the provider/runtime.

ULP ships a catalog under `patterns\grok`. Select a replacement catalog with `--grok-patterns-dir <directory>` or `ULP_GROK_PATTERNS_DIR`; the explicit directory replaces rather than merges with the installed catalog. The legacy Log Parser Lizard documents folder is only a compatibility fallback. The shipped `notice.txt` records the Apache 2.0 notice for definitions derived from Logstash patterns.

For multiline logs, `RegularExpression` extracts fields while `RecordStartRegularExpression` can independently identify the first physical line of each record. Set `AutoDetectRecordStart=ON` to sample up to `AutoDetectSampleLines` physical lines and try conservative timestamp/severity prefixes. Detection requires multiple starts and at least one continuation line; ambiguous input falls back to the configured expression. Sampled lines are replayed, including on non-seekable streams, so detection does not discard input.

Automatic detection is a convenience, not schema inference. Prefer an explicit reviewed record-start expression for production jobs, keep patterns bounded, and test malformed records and unusually long continuation blocks.

### W3C

Reads the field directives and records used by IIS and other W3C extended logs. Actual columns follow the log's `#Fields` declaration.

### log4jXML

Reads supported Log4j/log4net XML event records. XML fragments, namespaces, encodings, and malformed trailing content require provider-specific handling; use the generated reference.

## Windows and System Inputs

### EVT

The primary Windows Event Log provider reads channels and `.evtx` files using the modern Windows event API:

```powershell
ulp --input EVT --from System --table events `
    --query "SELECT TimeCreated, EventTypeName, SourceName, Message FROM events ORDER BY TimeCreated DESC LIMIT 100"
```

Access depends on Windows, channel permissions, and source availability. Message rendering can be expensive or unavailable when provider resources are missing.

### EVTXECMD and EVTXP

Use `EVTXECMD` when its forensic-compatible field model is required. `EVTXP` exists for classic Win32 behavior. Do not treat the three event providers as interchangeable schemas.

### ADS

Queries Active Directory objects and properties. Network/domain availability, credentials, scope, and directory permissions apply. Avoid broad unbounded directory queries.

### Processes and Threads

These providers return point-in-time local or remote Windows snapshots. Leave `ComputerName` empty for the local computer, or set it to a Windows computer/DNS name. An explicit remote failure is reported and never falls back to local data. Remote access uses your current Windows identity and depends on the target services, firewall, and permissions.

CPU figures are sampled observations, not lifetime guarantees. CPU percentage sampling is local-only; remote cumulative counters may be available but remote CPU percentage is left empty. Processes can exit and permissions can limit details while a query is running. Use `IncludeDetails=false` for a cheaper inventory and `MaximumRows` to bound materialized results.

## File, Source Code, Assembly, and Excel Inputs

### FileSystem

Returns file/directory paths, sizes, timestamps, attributes, and optional media metadata. Disable media extraction for faster general inventory:

```powershell
ulp --input FileSystem --from ".\samples\data\*" --table files `
    --i.FileSystem.Recurse 0 `
    --i.FileSystem.IncludeAllFiles true `
    --i.FileSystem.IncludeMediaProperties false `
    --query "SELECT Name, Extension, LengthInBytes, LastWriteTime FROM files ORDER BY LengthInBytes DESC"
```

Recursive enumeration and content hashing can be expensive. Filter with metadata and apply safe limits first.

### SourceCode

Parses supported languages into searchable symbols, document structure, comments, diagnostics, and exact source spans. Generated files and kinds/languages can be filtered. It is intended for code investigation and coding-agent workflows, not compilation or semantic proof.

C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown share a common row shape. Location and declaration fields include `Language`, `Kind`, `Name`, `FullName`, `ParentName`, `Namespace`, `SourcePath`, `StartLine`, `EndLine`, `Column`, signatures, modifiers, inheritance, documentation, and exact `FullRecord` source. Search/triage fields include `CalledMethods`, `UsedTypes`, statement/complexity counts, and `HasAwait`/`HasThrow`/`HasYield`/`HasLinq`/`HasSqlString`/`HasHttpCall`/`HasFileAccess`. These latter fields are parser hints, not compiler binding, runtime proof, or security findings.

The bundled Query library provides focused, bounded commands:

```powershell
ulp -c.code-symbol --from .\src\* --p.name QueryRunner --format JSON
ulp -c.code-context --from .\src\QueryRunner.cs --p.start_line 80 --p.end_line 140
ulp -c.code-comments --from .\src\* --p.text TODO --format JSON
ulp -c.code-imports --from .\src\* --p.name System.Data --format JSON
ulp -c.code-behavior --from .\src\* --p.behavior file --format JSON
ulp -c.code-public-api --from .\src\* --format Markdown
```

Other included recipes cover structured metadata without comment rows, exact text, calls, inheritance, documentation, syntax diagnostics, duplicate declaration bodies, inventories, and complexity hotspots. See the generated [SourceCode provider reference](reference/generated/provider-SourceCode.md) for every output field and option. The portable package also includes separate `ulp-repository-search` and `ulp-code-intelligence` agent skills under `skills`.

### DotNetAssembly

Inspects managed PE/CLR metadata without runtime-loading the target assembly. Views include assembly metadata, references, types, methods, P/Invokes, resources, and attributes. Presence of a strong-name or Authenticode structure is not proof of validation/trust.

### Excel

Reads `.xlsx`, `.xlsm`, and `.xls` without requiring Microsoft Office or ACE/OLE DB. It supports worksheet selection, multiple sheets, header options, typed values, hidden-sheet control, row limits, and source metadata. Inspect worksheet/schema before combining sheets with different columns.

## Generated and Extensible Inputs

### Numbers

```sql
CREATE VIRTUAL TABLE numbers
USING ParsingModule('', '-i:Numbers -From:1 -To:100');
```

Useful for ranges, tests, joins, and window examples.

### Dates

Generates calendar/date ranges for gap filling, planning, and time-based joins.

### CustomPlugin

Runs an explicitly selected custom .NET source plugin. Treat a plugin as code with the current user's permissions. Only load trusted code, use explicit paths/configuration, and understand its data/network behavior.

## Incremental Input and Checkpoints

Where supported, set `CheckpointFile` to process appended records after the first successful run:

```powershell
ulp --input TextLine --from "C:\Logs\*.log" --table logs `
    --i.TextLine.CheckpointFile "C:\ULP-State\logs.checkpoint" `
    --query "SELECT Text FROM logs" `
    --output file --format CSV --output-file .\new-records.csv
```

ULP commits staged positions only after query, output, and after-query success. Errors/cancellation keep the previous safe position. New files are read completely; deleted-file entries are removed after a complete scan; truncated/replaced files restart. An early `LIMIT` can intentionally cause safe replay rather than skipped records.

Checkpoints track input positions, not aggregate history. `COUNT(*)` on a checkpointed source counts rows in that execution.

# Output Formats

## Overview

`--output`/`--destination` selects where the result goes:

| Destination | Meaning |
| --- | --- |
| `console` | Standard output/terminal display |
| `file` | A file-capable writer and output path |
| `none` | Execute without rendering result content |
| `text-ui` | Open the interactive TUI dataset viewer/editor |

`--format` selects the writer. This separation is intentional:

```powershell
ulp --query "SELECT 1 AS value" --output file --format JSON --output-file .\result.json
```

Discover the current runtime:

```powershell
ulp --list-writers
ulp --help-writer JSON
```

## Choosing a Destination and Writer

Registered result writers in the documented runtime:

| Writer | Aliases | Typical destination | Purpose |
| --- | --- | --- | --- |
| `Terminal` | — | console | Colored bordered table; default interactive display |
| `TUI` | — | text-ui | Interactive dataset viewer and query editor |
| `None` | `Null` | none | Suppress rendering while collecting execution metrics |
| `TextTable` | `TXT` | console/file | Readable tabular text with headings |
| `TextList` | `TXTLIST` | console/file | Labeled fields grouped by record |
| `PlainText` | — | console/file | Minimal tab-delimited text |
| `CSV` | — | console/file | Comma-separated interchange |
| `TSV` | — | console/file | Tab-separated interchange |
| `JSON` | — | console/file | Structured JSON results |
| `TOON` | — | console/file | Token-oriented TOON 4.1 tabular output |
| `XML` | — | console/file | Structured XML results |
| `YAML` | `YML` | console/file | Human-readable YAML |
| `Markdown` | `MD` | console/file | Markdown result tables |
| `MarkdownChart` | — | file | Markdown chart from category/numeric columns |
| `HTML` | — | file | Standalone HTML tables |
| `SQLScript` | `SQL` | file | SQL `INSERT` script for recreating results |
| `Excel` | `XLSX` | file | Open XML workbook with one worksheet per result set |
| `Scriban` | `Template` | console/file/directory | Template rendering and safe multi-file generation |

Not every writer is suitable for every destination. Interactive destinations cannot participate as ordinary streaming file fan-out writers.

## Terminal and Text Output

### Terminal

Best for interactive reading. It can use colors, borders, paging, and terminal-aware formatting. Do not parse decorated terminal output in automation.

### TextTable

Readable fixed/tabular text for plain files and terminals where color is unnecessary.

### TextList

One labeled value per line, separated by record. Useful for narrow records with long values.

### PlainText

Minimal tab-delimited output with optional headers. Suitable for piping when CSV/TSV quoting is not required.

### None

Executes the query without rendering data:

```powershell
ulp --query "SELECT COUNT(*) FROM sqlite_master" --output none --expect-scalar 0
```

## Structured Data Output

### CSV and TSV

CSV quotes values when required and preserves null/trailing column positions according to writer options. TSV is convenient when data rarely contains tabs/newlines. Use generated writer help for exact null, header, encoding, and delimiter behavior.

### JSON

Best for broad interoperability and nested result metadata. Indentation is configurable.

### TOON

Compact tabular representation intended for token-sensitive contexts. Validate consumer compatibility; JSON remains the safer universal interchange default.

### XML and YAML

XML provides a structured document suitable for XML tooling. YAML is readable but whitespace-sensitive and can be interpreted differently by downstream parsers. Treat untrusted YAML according to the receiving library's safety guidance.

### SQLScript

Produces SQL statements that can recreate result rows. Review quoting, table naming, types, and target-database dialect before executing generated SQL.

## Documents, Workbooks, and Templates

### Markdown and MarkdownChart

Markdown creates GitHub/chat-friendly tables. MarkdownChart requires suitable category and numeric value columns. Very wide/large results remain difficult to read in Markdown; summarize first.

### HTML

Creates one valid encoded document for all result sets. Style modes include Tailwind, a built-in simple style, custom CSS, and clean HTML without CSS/classes. External CSS/network behavior depends on the selected mode; use Clean or BuiltIn for self-contained controlled output.

### Excel

Creates a standards-compliant `.xlsx` workbook without requiring Excel. Each result set becomes a worksheet. The minimal workbook layout is designed to open in Excel, LibreOffice, and compatible web viewers.

### Scriban

Renders data through one template, several templates, or a template directory. It can write stdout, one file, or safely generated subpaths inside an intended output root. Use it for SQL, source code, configuration, and documentation generation. Path traversal outside the output root is rejected, and overwrite behavior must be explicit.

Templates receive all result sets as `tables`, the first result as `table`, its `rows` and `columns`, plus `row_count` and `result_set_count`. Each table exposes its name, columns, rows, and row count. In per-row generation, `row` and zero-based `row_index` are also available; row members can be addressed using original, lowercase, or snake_case column names.

A template may declare a relative output and rendering mode in front matter:

```scriban
---
output: Models/{{ row.name }}.cs
mode: each-row
---
namespace Generated.Models;
public sealed class {{ row.name }} { }
```

`mode` is `once` by default or `each-row` for one render per first-result row. In directory/multi-template mode, `--output-file` is the output root. ULP rejects rooted/traversing paths and duplicate targets, creates safe subdirectories, stages output, and honors `--no-overwrite`. Exactly one of `InlineTemplate`, `TemplateFile`, `TemplateFiles`, or `TemplateDirectory` is selected; directory mode supports a search pattern and optional recursion. See the [generated Scriban reference](reference/generated/scriban-reference.md) for the exact runtime switches and model.

## Multiple Output Pipelines

Execute once and distribute the result:

```powershell
ulp --query "SELECT 1 AS id, 'example' AS name" `
    --output file --format CSV --output-file .\output\result.csv `
    --also-pipeline JSON=.\output\result.json `
    --also-pipeline Excel=.\output\result.xlsx
```

File-capable writers receive the same result data. Interactive-only destinations such as TUI and `None` are not ordinary additional files.

An empty result does not create/replace output when `--no-output-if-empty` is enabled. Fan-out failures produce an output failure rather than silently reporting complete success.

## Output Files and Overwrite Behavior

Use an explicit path:

```powershell
--output file --format JSON --output-file .\reports\events.json
```

Date/time tokens and `{n}` are supported in filenames:

```text
events-{yyyy-MM-dd}-{n}.json
```

`{n}` chooses the first free positive number. Use `--no-overwrite` to reject an existing target. Writers publish through safe temporary/replace behavior where supported so a failed write does not masquerade as a complete file.

Connection strings, passwords, archive passwords, and API keys must not be placed in output names. ULP masks recognized secrets in displayed/logged connection strings, but arbitrary result columns remain the user's responsibility.

# Format Compatibility Matrix

This matrix lists actual registered formats. “Streaming” describes the normal reader/writer behavior; SQL operations such as sorting, grouping, joins, window functions, TUI/web display, and multi-output buffering can still materialize results.

| Format/provider | Read | Write | Streaming | Notes |
| --- | ---: | ---: | ---: | --- |
| CSV | Yes | Yes | Yes | RFC-style quoted records; dynamic schema |
| TSV | Yes | Yes | Yes | Tab-delimited specialization |
| Delimiter | Yes | No dedicated writer | Yes | Use CSV/TSV/PlainText writer as appropriate |
| JSON | Yes | Yes | Provider-dependent | JSON input shape becomes rows; writer emits structured result sets |
| YAML | Yes | Yes | Provider-dependent | Human-readable structured data |
| TOON | Yes | Yes | Yes | TOON 4.1 tabular/keyed-tabular support |
| Excel | Yes | Yes | Reader/writer process workbook structures | Multiple worksheet support |
| Text lines | Yes | Via text writers | Yes | `TextLine` input; TextTable/TextList/PlainText output |
| Text words | Yes | Via text writers | Yes | Tokenized input only |
| RegEx/Grok | Yes | No dedicated writer | Yes | Parsed named fields can use any tabular writer |
| W3C | Yes | No dedicated writer | Yes | Input schema from W3C field directives |
| log4jXML | Yes | XML/general writers | Yes | Input parser and generic XML result writer are different roles |
| Windows events | Yes | Via all compatible writers | Provider streams | `EVT`, `EVTXECMD`, and `EVTXP` have different schemas |
| FileSystem | Yes | Via all compatible writers | Lazy enumeration | Optional media metadata can be expensive |
| SourceCode | Yes | Via all compatible writers | File-by-file | Supported language structures and exact spans |
| DotNetAssembly | Yes | Via all compatible writers | File-by-file | Static metadata inspection; no runtime loading |
| ADS | Yes | Via all compatible writers | Directory query | Windows/domain/network dependent |
| Processes/Threads | Yes | Via all compatible writers | Snapshot | Point-in-time observations |
| Numbers/Dates | Yes | Via all compatible writers | Generated sequence | No external file required |
| SQLScript | No input provider | Yes | Writer | Generated statements require review |
| Markdown | No dedicated input | Yes | Writer | Table output |
| MarkdownChart | No dedicated input | Yes | Writer | Requires suitable columns |
| HTML | No dedicated input | Yes | Writer | Tailwind/BuiltIn/Custom/Clean modes |
| Scriban templates | Template files configure writer | Yes | Dataset/template dependent | Single/multi-file generation with safe output root |
| Terminal | No | Yes | Display-oriented | Interactive decoration and pager |
| TUI | No | Yes | Materialized interactive display | Dataset viewer/editor |
| None | No | Suppresses content | N/A | Query still executes |

## Generated Format References

Exact fields, properties, aliases, categories, and defaults are generated from the registered runtime:

- [Generated provider index](reference/generated/README.md#data-providers)
- [Generated writer index](reference/generated/README.md#output-formats)
- run `ulp --list-providers` and `ulp --list-writers` for machine-friendly discovery;
- run `ulp --help-provider <name>` or `ulp --help-writer <name>` for one generated reference.

These pages are produced from the registered runtime by `ulp --docs` and carry their ULP version and generation method. Do not manually duplicate every property in this chapter.

## Related Documentation

- [Getting Started](getting-started.md)
- [ULP Tutorials](tutorials.md)
- [How-To Guide](how-to.md)
- [SQLite Guide](sqlite-guide.md)
- [ULP Reference](reference.md)
- [Generated configuration reference](reference/generated/configuration-reference.md)
- [Generated output-pipeline reference](reference/generated/output-pipelines-reference.md)
- [Incremental input and checkpoints](#incremental-input-and-checkpoints)
