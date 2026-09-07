# Input and output format catalogs

The catalogs are the single registration points used by factories, CLI menus, MCP discovery, and generated documentation. Canonical names are preferred in commands; listed aliases are intentional shorthand in the 1.0 command surface.

## Input providers

| Canonical name | Category | Aliases | Description |
| --- | --- | --- | --- |
| `EVT` | Windows events | `WindowsEventLog` | Windows Event Log channels and .evtx files using the modern Windows event API |
| `EVTXECMD` | Windows events | - | Forensic Windows .evtx parsing with EvtxECmd-compatible fields |
| `RegEx` | Text and logs | `Grok` | Multi-line text records parsed with regular expressions or Grok patterns |
| `CSV` | Structured text | - | Comma-separated records with configurable headers, quoting, and escaping |
| `TSV` | Structured text | - | Tab-separated records with configurable headers, quoting, and escaping |
| `W3C` | Structured text | - | W3C extended logs such as IIS, FTP, SMTP, Exchange, and Windows Firewall logs |
| `TextLine` | Text and logs | `Lines` | Text files and streams exposed as one record per line |
| `TextWord` | Text and logs | `Words` | Text files and streams tokenized into individual words |
| `log4jXML` | Structured text | - | Log4j and log4net XML event records |
| `JSON` | Structured text | - | JSON objects and arrays from files or streams |
| `YAML` | Structured text | `YML` | YAML documents, mappings, and sequences from files or streams |
| `TOON` | Structured text | - | TOON 4.1 tabular and keyed-tabular data from files or streams |
| `Numbers` | Generated data | - | Generated numeric series for joins, ranges, and test data |
| `FileSystem` | File system | `FS` | Files and directories with paths, sizes, timestamps, and optional media metadata |
| `Delimiter` | Structured text | `Delimited` | Records separated by a configurable delimiter, quote, and escape syntax |
| `Dates` | Generated data | - | Generated date series for calendar joins, ranges, and test data |
| `CustomPlugin` | Extensibility | `DotNetPlugin` | Records produced by a custom .NET source-code plugin |
| `EVTXP` | Windows event logs | - | Classic Windows Event Log reader using the Win32 API |
| `SourceCode` | Source code | `CSharp`, `CS` | C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown files parsed into searchable symbols, document structure, comments, diagnostics, and exact source spans |
| `Excel` | Structured data | `XLSX`, `XLS` | Excel workbooks and worksheets without Office or database drivers |
| `ADS` | Directory services | `ActiveDirectory`, `LDAP` | Active Directory objects and properties with Microsoft Log Parser 2.2-compatible modes |
| `Processes` | System snapshots | `Process`, `PROC` | Point-in-time local process metrics including memory, CPU, handles, threads, and executable details |
| `Threads` | System snapshots | `ProcessThreads`, `THR` | Point-in-time operating-system thread state, priority, and CPU metrics for selected processes |
| `DotNetAssembly` | Software artifacts | `Assembly`, `DotNet` | Static PE and CLR metadata for managed .NET DLL and EXE files |

## Result writers

| Canonical name | Category | Aliases | Extension | Streaming | Description |
| --- | --- | --- | --- | --- | --- |
| `TextTable` | Text | `TXT` | .txt | Yes | Readable tabular text with table and row headings |
| `TextList` | Text | `TXTLIST` | .txt | Yes | One labeled field per line, grouped by record |
| `PlainText` | Text | - | .txt | Yes | Minimal tab-delimited text with optional column headers |
| `CSV` | Delimited | - | .csv | Yes | Comma-separated values for spreadsheets and data interchange |
| `TSV` | Delimited | - | .tsv | Yes | Tab-separated values for lossless plain-text interchange |
| `JSON` | Structured | - | .json | Yes | Structured JSON output |
| `TOON` | Structured | - | .toon | No | TOON 4.1 token-oriented tabular output for LLM contexts |
| `XML` | Structured | - | .xml | Yes | Structured XML output |
| `YAML` | Structured | `YML` | .yaml | Yes | Human-readable YAML output |
| `Markdown` | Document | `MD` | .md | No | Markdown tables suitable for documentation and chat |
| `MarkdownChart` | Document | - | .md | No | Markdown chart generated from category and numeric value columns |
| `HTML` | Document | - | .html | Yes | Standalone HTML table document |
| `SQLScript` | Database | `SQL` | .sql | Yes | SQL INSERT script for recreating query results |
| `Excel` | Spreadsheet | `XLSX` | .xlsx | No | Microsoft Excel Open XML workbook (.xlsx) |
| `Scriban` | Generation | `Template` | .txt | No | Scriban template rendering and safe multi-file generation |
| `None` | Control | `Null` | - | Yes | Suppress rendering while still executing the query and collecting metrics |

## Adding or removing a format

1. Add or remove one registration in `ParsingReaderFactory.InputFormats` or `ResultWriterFactory.OutputFormats`.
2. Add an alias only when it is an intentional, documented shorthand for the current command surface.
3. Add a factory/catalog test and one representative execution test.
4. Regenerate docs with `ulp --docs .\docs --no-env`.

Provider implementations continue to implement `ILogParserInputContext`; no ParsingModule interface change is required. File and network capable readers may continue to use the universal `StreamFactory`.

## Proposed input providers

These are design candidates, not registered formats:

- **JSONLines** — a dedicated streaming JSONL/NDJSON provider with one object per record, recovery from malformed lines, and bounded schema inference. Highest-value short-term addition.
- **Syslog** — RFC 3164/RFC 5424 files and streams with structured facility, severity, host, application, process, and message fields.
- **ArchiveEntries** — enumerate ZIP/TAR/GZip contents and metadata, with optional streaming of matching entries through the existing StreamFactory.
- **Parquet** — columnar analytics input with projection and row-group filtering; valuable but adds a substantial dependency and type-mapping work.
- **WindowsRegistry** — bounded registry-key/value enumeration for diagnostics and forensic queries.
- **ETL** — Windows ETW trace files with provider/event filtering; keep separate from EVT because its schema and runtime dependencies differ.
- **HttpJson** — paginated HTTP JSON APIs with explicit authentication references, rate-limit handling, and a strict maximum-page/record budget.
