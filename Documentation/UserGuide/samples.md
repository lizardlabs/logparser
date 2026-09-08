# ULP Samples

This catalog connects the checked-in sample data, SQL scripts, Query library recipes, templates, and automation scripts. The sample data is fictional. Run commands from the `PortableLogParser` project directory unless a command says otherwise.

## Contents

- [Using the Sample Data](#using-the-sample-data)
- [Basic Queries](#basic-queries)
- [Filtering](#filtering)
- [Sorting](#sorting)
- [Aggregation](#aggregation)
- [Text Analysis](#text-analysis)
- [Date and Time Analysis](#date-and-time-analysis)
- [CSV Examples](#csv-examples)
- [JSON, YAML, and TOON Examples](#json-yaml-and-toon-examples)
- [Log Examples](#log-examples)
- [Web Log Examples](#web-log-examples)
- [Security Analysis Examples](#security-analysis-examples)
- [Multiple-File Examples](#multiple-file-examples)
- [Export Examples](#export-examples)
- [PowerShell Examples](#powershell-examples)
- [Pipeline Examples](#pipeline-examples)
- [AI Examples](#ai-examples)
- [Advanced Examples](#advanced-examples)
- [Sample Inventory](#sample-inventory)

## Using the Sample Data

Verify ULP and inspect the catalog:

```powershell
ulp --version
ulp --list-providers
ulp --list-writers
```

The main sample areas are:

| Location | Purpose |
| --- | --- |
| `samples/data` | Fictional CSV, TSV, JSON, YAML, TOON, logs, and source code |
| `samples/parsingmodule` | Self-contained SQL that creates virtual tables |
| `samples/sql` | Ordered SQL over CLI-created `employees` and `departments` tables |
| `samples/actions` | Harmless post-action context display |
| `samples/templates` | Single and multi-file Scriban generation |
| `queries` | Recursive installed Query library with command-tagged recipes |

Paths are relative to the current directory. If running the packaged application elsewhere, use absolute paths or copy the sample folder intact.

## Basic Queries

### Select everything

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees"
```

### Select columns

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name, department_id, salary FROM employees"
```

### Limit results

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees LIMIT 3"
```

### Use the automatic builder

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --select "employee_name, department_id, salary" --limit 5
```

## Filtering

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name, salary FROM employees WHERE CAST(salary AS REAL) >= 70000"
```

Find active employees with a bound parameter:

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees WHERE lower(active)=lower(@active)" `
    --param active=true
```

Search raw files without SQLite:

```powershell
ulp search error .\samples\data --ignore-case --include "*.log"
```

## Sorting

```sql
SELECT employee_name,
       CAST(salary AS REAL) AS salary
FROM employees
ORDER BY salary DESC, employee_name;
```

Run it inline:

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name, CAST(salary AS REAL) AS salary FROM employees ORDER BY salary DESC, employee_name"
```

## Aggregation

The self-contained ParsingModule sample creates the CSV table and summarizes it:

```powershell
ulp --query-file .\samples\parsingmodule\04-csv-aggregation.sql
```

Equivalent core query:

```sql
SELECT CAST(department_id AS INTEGER) AS DepartmentId,
       COUNT(*) AS Employees,
       AVG(CAST(salary AS REAL)) AS AverageSalary
FROM employees
GROUP BY CAST(department_id AS INTEGER)
ORDER BY Employees DESC, DepartmentId;
```

## Text Analysis

Analyze bounded text statistics:

```powershell
ulp analyze .\samples\data\application.log --top 10
ulp analyze .\samples\data\service.log --format json --normalize-lines log-template
```

Query one line per row:

```powershell
ulp -i TextLine --from .\samples\data\application.log --table lines `
    --query "SELECT RecordNumber, Text FROM lines WHERE Text LIKE '%ERROR%' LIMIT 20"
```

Use the checked-in script:

```powershell
ulp --query-file .\samples\parsingmodule\03-textline-errors.sql
```

## Date and Time Analysis

Generate a calendar without an input file:

```powershell
ulp --query-file '.\queries\Generated Data\calendar-next-30-days.sql'
```

Extract daily log counts when a timestamp column is present:

```sql
SELECT date(TimeCreated) AS EventDate,
       COUNT(*) AS Events
FROM logs
GROUP BY date(TimeCreated)
ORDER BY EventDate;
```

Use [SQL Function Reference](functions.md#date-and-time-functions) for Unix time, UTC, timezone, and day-of-week helpers available in the documented runtime.

## CSV Examples

### Direct CSV

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees"
```

### Join two CSV files

```powershell
ulp --input CSV --table employees --from .\samples\data\employees.csv `
    --input CSV --table departments --from .\samples\data\departments.csv `
    --query-file '.\samples\sql\00-materialize-sources.sql' `
    --query-file '.\samples\sql\10-joins.sql'
```

The materialization script copies forward-only virtual-table streams into connection-local temporary tables before repeated scans, joins, and windows.

### Complete ordered SQL suite

```powershell
ulp --input CSV --table employees --from .\samples\data\employees.csv `
    --input CSV --table departments --from .\samples\data\departments.csv `
    --query-file '.\samples\sql\*.sql' --verbose
```

Wildcard query files run in case-insensitive lexical order.

## JSON, YAML, and TOON Examples

The same conceptual structured records are available in three formats:

```powershell
ulp -i JSON --from .\samples\data\structured-sample.json --table records --query "SELECT * FROM records"
ulp -i YAML --from .\samples\data\structured-sample.yaml --table records --query "SELECT * FROM records"
ulp -i TOON --from .\samples\data\structured-sample.toon --table records --query "SELECT * FROM records"
```

Inspect provider-specific fields/options before assuming that nested values flatten identically:

```powershell
ulp --help-provider JSON
ulp --help-provider YAML
ulp --help-provider TOON
```

The ordered SQL suite includes `samples/sql/60-json.sql`, which demonstrates SQLite JSON functions over materialized data.

## Log Examples

### Regular-expression parsing

```powershell
ulp --query-file .\samples\parsingmodule\08-regex.sql
```

The sample creates named `Date`, `Level`, and `Message` fields from fictional log lines.

### Windows Event Log

```powershell
ulp --query-file .\samples\parsingmodule\01-evt-system.sql
ulp --query-file .\samples\parsingmodule\02-evt-error-summary.sql
```

These examples depend on Windows Event Log access and actual local records. Results vary by machine and permissions.

## Web Log Examples

`samples/data/requests.tsv` contains HTTP-style request data:

```powershell
ulp --query-file .\samples\parsingmodule\07-tsv-filter.sql
```

Or query it directly:

```powershell
ulp -i TSV --from .\samples\data\requests.tsv --table requests `
    --query "SELECT * FROM requests WHERE CAST(status AS INTEGER) >= 400 ORDER BY status"
```

For real W3C web logs, use the `W3C` provider and inspect its generated schema:

```powershell
ulp --help-provider W3C
```

## Security Analysis Examples

Count recent event errors by provider:

```powershell
ulp -i EVT --from System --table events `
    --query "SELECT SourceName, COUNT(*) AS ErrorCount FROM events WHERE EventTypeName='Error' GROUP BY SourceName ORDER BY ErrorCount DESC LIMIT 20"
```

Find repeated error intervals with the installed recipe:

```powershell
ulp --query-file '.\queries\Events\error-interval-statistics.sql'
```

Find duplicate-file candidates. This recipe narrows by size before hashing and deliberately bounds content hashing:

```powershell
ulp --query-file '.\queries\Files\Recursive\duplicate-file-candidates.sql'
```

These are analysis starting points, not intrusion-detection verdicts. Validate source completeness, timestamps, retention, permissions, and false positives.

## Multiple-File Examples

Preview text recursively:

```powershell
ulp --query-file '.\queries\Text\recursive-text-file-preview.sql'
```

Use lazy inclusion/exclusion directly:

```powershell
ulp -i TextLine --from '.\logs\*;!*.bak;!*.tmp' --input.Recurse -1 `
    --query "SELECT StreamName, RecordNumber, Text FROM tText1 LIMIT 100"
```

Inventory files recursively:

```powershell
ulp --query-file '.\queries\Files\Recursive\file-inventory.sql'
ulp --query-file '.\queries\Files\Recursive\folder-subtree-sizes.sql'
```

## Export Examples

### One query, different representations

Use this bounded query for the following examples:

```sql
SELECT employee_id, employee_name, department_id
FROM employees
WHERE lower(active)='true'
ORDER BY employee_id
LIMIT 3;
```

With `--format Markdown`, the result is easy to paste into an issue or document:

| employee_id | employee_name | department_id |
| ---: | --- | ---: |
| 1 | Ada | 10 |
| 2 | Grace | 10 |
| 3 | Linus | 20 |

With `--format CSV`, the same rows are compact and spreadsheet-friendly:

```csv
employee_id,employee_name,department_id
1,Ada,10
2,Grace,10
3,Linus,20
```

With `--format JSON`, ULP includes a `Metadata` object describing column types/positions and a `Data` array containing the rows. This is the best general default for an agent or script that must preserve column names and result-set boundaries.

### Download the generated output showcase

These are actual ULP exports of the query above, using the bundled fictional employee data:

- [CSV result](assets/outputs/employees.csv)
- [JSON result with column metadata](assets/outputs/employees.json)
- [Download all showcase formats](assets/outputs/ulp-output-showcase.zip): CSV, JSON, TOON, Markdown, standalone HTML, the SQL, and a separate two-worksheet Excel example.

Unzip the showcase and open `employees.html` in a browser or `two-sheets.xlsx` in your spreadsheet application. The two-sheet example runs `SELECT 1 AS id, 'first' AS name; SELECT 2 AS id, 'second' AS name;`; each result set has its own worksheet.

For comparison, the actual TOON result is:

```text
Table0[3]{employee_id,employee_name,department_id}:
  "1",Ada,"10"
  "2",Grace,"10"
  "3",Linus,"20"
```

The ID values are strings because these CSV columns were read as text. JSON also preserves that distinction; a spreadsheet may infer numbers when opening CSV. Cast columns in SQL if you need a numeric contract.

This small sample produces 75-byte CSV, 101-byte TOON, and 667-byte default pretty-printed JSON files. These are **file sizes, not token counts**. JSON includes metadata that TOON does not, so this is not an equal-content compression benchmark. Model tokenizers, compact JSON settings, row shapes, and repeated names all affect token cost. Prefer JSON for reliable interoperability; measure TOON with the actual agent/model and check that it preserves the required data before switching. See [AI format guidance](ai.md#json-or-toon-for-agent-results).

For a source checkout, regenerate the evidence into an empty directory with `powershell -File PortableLogParser/Tests/Build-ManualShowcase.ps1 -Configuration Release -OutputDirectory C:/Temp/ulp-showcase`. The script refuses to replace existing files. The larger build output gallery additionally exercises other writers and input scenarios.

Writers do not change the SQL or rerun the source. Select a primary writer with `--format`, then add `--also-pipeline FORMAT=PATH` for each additional artifact.

### CSV

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees" `
    --output file --format CSV --output-file .\output\employees.csv
```

### JSON

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees" `
    --output file --format JSON --output-file .\output\employees.json
```

### Excel and HTML

```powershell
ulp --query "SELECT 1 AS id, 'first' AS name; SELECT 2 AS id, 'second' AS name;" `
    --output file --format Excel --output-file .\output\multi-sheet.xlsx `
    --also-pipeline HTML=.\output\multi-result.html
```

Each result set becomes a worksheet/section where supported.

### Markdown, YAML, TOON, and SQL

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_id, employee_name, department_id FROM employees ORDER BY employee_id" `
    --output file --format Markdown --output-file .\output\employees.md `
    --also-pipeline YAML=.\output\employees.yaml `
    --also-pipeline TOON=.\output\employees.toon `
    --also-pipeline SQLScript=.\output\employees.sql
```

Use JSON for broad interoperability, CSV/TSV for simple tabular exchange, Excel for human review and multiple result sets, HTML/Markdown for reports, SQLScript for replayable inserts, and Scriban when the output is generated text or a directory of files. TOON can be useful for uniform tabular data in token-sensitive workflows, but JSON remains the safer default when ecosystem compatibility matters.

## PowerShell Examples

Use a query as a batch gate:

```powershell
ulp --query "SELECT COUNT(*) FROM sqlite_master" --output none --expect-scalar 0 --stats
if ($LASTEXITCODE -ne 0) { throw "ULP gate failed: $LASTEXITCODE" }
```

Run the harmless post-action sample:

```powershell
ulp --query "SELECT 7" --output none `
    --after powershell.exe `
    --after-arg=-NoProfile `
    --after-arg=-ExecutionPolicy --after-arg Bypass `
    --after-arg=-File --after-arg .\samples\actions\show-context.ps1
```

Post-actions start directly, without an implicit shell.

## Pipeline Examples

Send the same result to several writers:

```powershell
ulp -i CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT * FROM employees" `
    --output file --format CSV --output-file .\output\employees.csv `
    --also-pipeline JSON=.\output\employees.json `
    --also-pipeline Excel=.\output\employees.xlsx
```

Use `--no-output-if-empty` to leave existing targets untouched for an empty result, and `--no-overwrite` to reject any existing target.

## AI Examples

Experimental web AI SQL Chat can use the loaded schemas. A safe example request is:

```text
Using employees, count employees by department_id, calculate average salary,
order by employee count descending, and limit the result to 20.
```

Generated SQL is displayed for review and is never executed automatically. See [AI Features](ai.md#example-prompts).

## Advanced Examples

### Windows and joins

```powershell
ulp --query-file .\samples\parsingmodule\05-csv-join-and-window.sql
```

### Recursive CTE and calendar

```powershell
ulp --input CSV --table employees --from .\samples\data\employees.csv `
    --input CSV --table departments --from .\samples\data\departments.csv `
    --query-file .\samples\sql\00-materialize-sources.sql `
    --query-file .\samples\sql\40-cte-and-calendar.sql
```

### Source-code inventory for coding agents

```powershell
ulp -i SourceCode --from '.\samples\data\source-code-*' --table code `
    --query "SELECT FileName, Kind, Name, StartLine, EndLine FROM code ORDER BY FileName, StartLine"
```

Installed code recipes include `code-inventory.sql`, `complexity-hotspots.sql`, `find-symbol.sql`, `find-calls.sql`, and `find-text.sql` under `queries/Code`.

### Scriban generation

```powershell
ulp --query "SELECT 'Customer' AS name, 'Entity' AS kind UNION ALL SELECT 'Order', 'Entity'" `
    --format Scriban --output file --output-file .\generated `
    --output.TemplateDirectory .\samples\templates\codegen
```

Review [Scriban templates](inputs-and-outputs.md#scriban) for the dynamic output-path convention and overwrite safety.

## Sample Inventory

| Group | Checked-in examples |
| --- | --- |
| ParsingModule | EVT, TextLine, CSV, join/window, provider config, TSV, RegEx, Numbers |
| SQL | Materialization, joins, aggregates, windows, recursive CTE/calendar, views, JSON, query plan |
| Structured data | JSON, YAML, TOON |
| Source code | C#, VB, Razor, HTML, JavaScript, TypeScript, Markdown |
| Query library | Code, Events, Files, recursive disk statistics, generated data, System, Text |
| Templates | Single summary plus multi-file C# and Markdown generation |
| Automation | Post-action context display |

## Related Documentation

- [Tutorials](tutorials.md)
- [How-To Guide](how-to.md)
- [Input and Output Formats](inputs-and-outputs.md)
- [SQLite Guide](sqlite-guide.md)
- [ULP Reference](reference.md)
- [Executable sample README](../../Samples/README.md)
