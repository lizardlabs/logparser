# ULP use-case tutorials

Start with a job, not a list of SQL keywords. These walkthroughs use the fictional data supplied in `samples/data`. Run commands from the extracted ULP folder. In PowerShell, use `ulp` after adding it to PATH, or replace it with `.\ulp.exe`. Backticks continue a command onto the next line.

## Contents

- [Take the product tour](#take-the-product-tour)
- [Find the failure in an application log](#find-the-failure-in-an-application-log)
- [Summarize a spreadsheet export](#summarize-a-spreadsheet-export)
- [Combine employee and department data](#combine-employee-and-department-data)
- [Find failing web requests](#find-failing-web-requests)
- [Investigate files without opening each one](#investigate-files-without-opening-each-one)
- [Build a searchable code snapshot](#build-a-searchable-code-snapshot)
- [Turn logs into an indexed database for dashboards](#turn-logs-into-an-indexed-database-for-dashboards)
- [Build a development and CI evidence report](#build-a-development-and-ci-evidence-report)
- [Reuse a report with parameters](#reuse-a-report-with-parameters)
- [Publish the same result in different formats](#publish-the-same-result-in-different-formats)
- [Review an AI-assisted investigation](#review-an-ai-assisted-investigation)

## Take the product tour

**Goal:** see the most important ULP ideas work before configuring a real data source.

From the extracted ULP folder, start the guided tour:

```powershell
ulp --tour
```

The tour explains and previews every SQL statement before you decide whether to run it. Its chapters demonstrate:

1. querying a generated number table;
2. listing the current directory and producing extension/size statistics as two result sets;
3. reading several temporary text files through one wildcard and filtering warnings and errors;
4. rendering the same rows as CSV, JSON, and TOON;
5. reading five recent warning/error records from the local Windows System event channel, when available.

All work uses an isolated in-memory database. Directory reading is non-recursive, text fixtures are created under the operating-system temporary directory and removed afterward, the Event Log is read-only, and the tour makes no network requests.

To run the complete tour without prompts, which is useful for a presentation or smoke check:

```powershell
ulp --tour=auto
```

List or run individual chapters:

```powershell
ulp --tour=list
ulp --tour=text
ulp --tour=formats
```

The `events` chapter is optional. If the local System event channel is unavailable, ULP explains that skip and continues. Press Ctrl+C to cancel an active chapter. From `ulp --menu`, choose **LEARN · Product tour** for the same guided experience.

## Find the failure in an application log

**Goal:** extract the error and enough context to know where to investigate next.

The bundled `application.log` contains five timestamped lines. Read it as `TextLine`: no parsing expression is needed for a first pass.

```powershell
ulp --input TextLine --from samples/data/application.log --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%'" --format TextTable
```

Result:

```text
Text
2026-08-17T08:02:10Z ERROR worker retry-scheduled job=77 attempt=2
```

Search for `job=77` next to see both the retry and the completion. `LIKE '%...%'` searches anywhere in the line; `%` is the SQL wildcard. `LIMIT 50` bounds the number of returned matches, not necessarily the amount of input searched.

For multiple files, change the source to `'.\logs\*.log,!*.old.log'` and set `--input.Recurse -1`. Exclusions belong in the source expression, not in SQL. Quote the entire expression so the shell does not interpret it. Use an explicit root to avoid an expensive drive-wide search.

When you need fields such as date, level, and message repeatedly, use the bundled `samples/parsingmodule/08-regex.sql` recipe and inspect its expression before adapting it.

**Try it:** return warning lines too, using `WHERE Text LIKE '%ERROR%' OR Text LIKE '%WARN%'`. See [wildcards and exclusions](how-to.md#how-to-use-wildcards).

## Summarize a spreadsheet export

**Goal:** produce a headcount and salary summary from CSV without opening a spreadsheet.

First inspect the schema:

```powershell
ulp --input CSV --from samples/data/employees.csv --table employees --list-columns employees
```

Then calculate totals. Explicit numeric casts make the intended treatment of CSV text clear.

```powershell
ulp --input CSV --from samples/data/employees.csv --table employees `
    --query "SELECT department_id, COUNT(*) AS people, SUM(CAST(salary AS INTEGER)) AS salary_total FROM employees GROUP BY department_id ORDER BY department_id" `
    --format TextTable
```

| department_id | people | salary_total |
| --- | --- | --- |
| 10 | 3 | 353000 |
| 20 | 2 | 204000 |
| 30 | 2 | 247000 |
| 40 | 1 | 88000 |

This includes all eight employees. Add `WHERE active = 'true'` before `GROUP BY` to report only active employees. Empty salaries need a deliberate policy: reject, exclude, or substitute a value; blindly casting invalid text to a number can hide data-quality problems.

**Try it:** replace `SUM` with `ROUND(AVG(CAST(salary AS REAL)), 2)` and compare the department averages.

## Combine employee and department data

**Goal:** replace numeric department IDs with names and rank salaries inside each department.

The supplied script creates its input tables, copies the streaming inputs into reusable temporary tables, and runs the join and window calculation:

```powershell
ulp --query-file samples/parsingmodule/05-csv-join-and-window.sql --format TextTable
```

For a smaller report, use this self-contained query:

```sql
CREATE VIRTUAL TABLE employee_input USING ParsingModule(
  'samples/data/employees.csv', '-i:CSV');
CREATE VIRTUAL TABLE department_input USING ParsingModule(
  'samples/data/departments.csv', '-i:CSV');
CREATE TEMP TABLE employees AS SELECT * FROM employee_input;
CREATE TEMP TABLE departments AS SELECT * FROM department_input;

SELECT d.department_name, COUNT(*) AS people
FROM employees e
JOIN departments d ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY d.department_name;
```

Save it as `department-report.sql`, then run `ulp --query-file department-report.sql --format TextTable`.

| department_name | people |
| --- | --- |
| Engineering | 3 |
| Operations | 2 |
| Security | 2 |
| Support | 1 |

Materialization reads each input once and gives SQLite ordinary tables it can rescan. For a one-pass filter it is usually unnecessary. Use `LEFT JOIN` when employees without a matching department must remain visible; their department name will be NULL.

**Try it:** find unmatched departments with `LEFT JOIN ... WHERE d.department_id IS NULL`. Review [joins](sqlite-guide.md#joins) before applying this to production data.

## Find failing web requests

**Goal:** distinguish missing pages from server errors in a tab-separated request export.

```powershell
ulp --input TSV --from samples/data/requests.tsv --table requests `
    --query "SELECT status, path FROM requests WHERE CAST(status AS INTEGER) >= 400 ORDER BY CAST(status AS INTEGER) DESC" `
    --format TextTable
```

| status | path |
| --- | --- |
| 500 | /api/orders |
| 404 | /missing |

The 500 response suggests a server-side failure; the 404 means the requested resource was not found. Neither row alone proves the cause. Group by `path` and `status` to find repeated failures, then correlate timestamps with application logs.

For a numeric latency field, calculate a percentile instead of relying only on the average:

```sql
WITH requests(duration_ms) AS (VALUES (10), (20), (30), (100))
SELECT AVG(duration_ms) AS mean_ms,
       MEDIAN(duration_ms) AS median_ms,
       ROUND(PERCENTILE_CONT(duration_ms, 0.95), 2) AS p95_ms
FROM requests;
```

This illustrative four-row set returns `40`, `25`, and `89.5`. The continuous percentile interpolates between observations; it need not equal an observed duration. See [aggregate functions](functions.md#aggregate-functions).

## Investigate files without opening each one

**Goal:** use the saved `dir` query as a reusable command.

```powershell
ulp --command dir --from samples/data --p.extension .csv --format TextTable
```

The result depends on your files. Use `ulp --help` and the Query library to inspect available command recipes. For recursive size analysis, open **Query library > Files** in `ulp --menu`: it includes directory sizes, recursive statistics, and duplicate candidates.

Keep raw byte counts for sorting and aggregation; apply `HUMANIZE_BYTES` only in the final projection. Sorting formatted strings such as `900 B` and `2 MB` does not sort by actual size. A same-size duplicate candidate is not proof of identical content; hash candidate files when you need stronger evidence.

**Try it:** point the command at a small test folder before querying a large directory tree.

## Build a searchable code snapshot

**Goal:** inspect declarations repeatedly without reparsing the repository for every question.

Start with the deterministic sample:

```powershell
ulp --input SourceCode --from samples/data/source-code-agent-sample.cs --table code `
    --query "SELECT Kind, Name, SourcePath, StartLine, EndLine FROM code ORDER BY StartLine LIMIT 30" `
    --format TextTable
```

The path and line-span fields let you return to the original file. Discover additional fields with `--list-columns code`; do not assume every language exposes the same semantic information.

For repeated repository analysis, save this as `code-snapshot.sql`, adjust the source, and choose a new output database:

```sql
CREATE VIRTUAL TABLE code_input USING ParsingModule(
  'C:/Work/Example/src/*.cs', '-i:SourceCode -Recurse:-1');
CREATE TABLE code_snapshot AS SELECT * FROM code_input;
CREATE INDEX code_kind_name ON code_snapshot(Kind, Name);
SELECT Kind, COUNT(*) AS records FROM code_snapshot GROUP BY Kind ORDER BY records DESC;
```

```powershell
ulp --database code-review.sqlite --query-file code-snapshot.sql --format TextTable
ulp --database code-review.sqlite --query "SELECT Name, SourcePath, StartLine, EndLine FROM code_snapshot WHERE Kind='Method' AND Name LIKE '%Parse%' LIMIT 40" --format JSON
```

This deliberately uses `CREATE TABLE`, not replacement: rerunning against the same database reports that the snapshot already exists. Choose a fresh database when refreshing, or explicitly decide what to remove. Do not silently treat a saved snapshot as the current checkout after files change.

For plain text or an unsupported language, use `TextLine` and inspect its schema. Phrase searching and line-range extraction complement structural analysis; they do not prove call relationships. For C#, VB.NET, Razor, HTML, JavaScript, TypeScript, Python, Java, and Markdown, inspect `SourceCode` options for comments, diagnostics, imports, calls, generated files, and bounded parsing.

**Try it:** ask an agent to inventory a bounded subtree, materialize it once, return concise matches with paths and spans, then read only the selected source sections. See [agent workflows](ai.md#use-ulp-directly-from-an-agent).

## Turn logs into an indexed database for dashboards

**Goal:** read logs once, save an ordinary SQLite database, index useful filters, and give the resulting data to a visualization tool without requiring that tool to understand ULP input formats.

This walkthrough starts with a small normalized request log. In a real job, use RegEx, W3C, JSON, EVT, or another appropriate input to produce the same selected fields. Keep the exported schema narrow: UTC time, a sanitized route label, numeric status, and duration in milliseconds. Do not export raw messages, credentials, query strings, or user identifiers merely because they are available.

The [runnable tutorial bundle](assets/outputs/workflow-tutorials.zip) contains a `tutorials` folder. Extract it into your ULP `samples` directory, or use the `samples/tutorials` files supplied with the package. Run the commands from the ULP folder. Use new database/output names for each exercise; the scripts deliberately refuse to replace existing tables.

### Materialize once, then close the input

```powershell
ulp --no-config --no-env --database log-dashboard.sqlite `
    --query-file samples/tutorials/materialize-logs.sql --format TextTable
```

The script uses a transaction to:

1. Open the CSV as a **temporary virtual table**.
2. Insert its six rows into the ordinary `log_requests` table with explicit types and basic constraints.
3. Create a route/time index for repeated filters.
4. Materialize `log_hourly`, including counts, totals, and a precomputed percentile.
5. Store creation time and row count in `snapshot_info`, close the temporary input, and commit.

The key distinction is:

```sql
-- A virtual table reads external input; it is not the portable dataset.
CREATE VIRTUAL TABLE temp.request_input USING ParsingModule(
  'samples/tutorials/log-requests.csv', '-i:CSV');

-- This copies the result into an ordinary persistent table.
CREATE TABLE example_snapshot AS SELECT * FROM request_input;
CREATE INDEX ix_example_route_time ON example_snapshot(route, timestamp_utc);
```

That is the short form; use the bundled script for explicit numeric types, constraints, the hourly report, and transaction handling. `CREATE TEMP TABLE` would disappear at connection close, so it is not appropriate for the result you intend to hand over. `CREATE TABLE ... AS SELECT` does not automatically copy indexes or primary-key constraints.

Expected hourly report:

| hour_utc | route | requests | errors | mean_ms | p95_ms |
| --- | --- | --- | --- | --- | --- |
| 2026-08-19T10:00:00Z | /api/orders | 3 | 2 | 173.33 | 290 |
| 2026-08-19T10:00:00Z | /health | 1 | 0 | 5 | 5 |
| 2026-08-19T11:00:00Z | /api/orders | 1 | 0 | 40 | 40 |
| 2026-08-19T11:00:00Z | /health | 1 | 0 | 10 | 10 |

Here an error means HTTP status 500 or higher. Change the definition deliberately if your report counts 4xx failures too. The sample input is already normalized; for production, quarantine invalid timestamps and nonnumeric status/duration values **before** casting. SQLite casts can turn malformed numeric text into zero; basic numeric constraints alone do not prove source-data quality.

### Reopen, query, and inspect the index

Start a second ULP process without `--input`, `--from`, or access to the original logs:

```powershell
ulp --no-config --no-env --database log-dashboard.sqlite `
    --query "SELECT COUNT(*) AS requests FROM log_requests" --format TextTable

ulp --no-config --no-env --database log-dashboard.sqlite `
    --query "SELECT timestamp_utc, status, duration_ms FROM log_requests WHERE route='/api/orders' AND timestamp_utc >= '2026-08-19T10:00:00Z' ORDER BY timestamp_utc" `
    --format TextTable

ulp --no-config --no-env --database log-dashboard.sqlite `
    --query "EXPLAIN QUERY PLAN SELECT status FROM log_requests WHERE route='/api/orders' AND timestamp_utc >= '2026-08-19T10:00:00Z'" `
    --format TextTable
```

The count is `6`. The index `(route, timestamp_utc)` suits an equality filter on route followed by a time range; it is not equally useful for every possible filter. The optimizer may choose a scan for this tiny fixture even though the index exists. Inspect the plan on representative data rather than forcing an index or adding one to every column. Indexes consume space and slow writes; they mainly help repeated selective reads. The script runs `ANALYZE` after loading.

Only ordinary tables/indexes are persistent. The stored percentile is a number, not a view that requires `PERCENTILE_CONT` in another application. This matters when another SQLite reader lacks ULP's functions. You can inspect `sqlite_master` to confirm that no persistent object references `ParsingModule`.

### Create a safe handoff copy

Close the writer before handing over the database. Check it with `PRAGMA integrity_check` and record `snapshot_info`. Use a new filename for refreshes; do not overwrite a database while a BI tool is reading it.

For an existing active database, do not copy only its main file and ignore a possible WAL/journal. A SQLite-aware backup or `VACUUM INTO` produces a consistent snapshot. The destination must be a new file; run outside a transaction. See [SQLite's backup guidance](https://sqlite.org/backup.html) and [VACUUM INTO](https://sqlite.org/lang_vacuum.html).

```powershell
ulp --no-config --no-env --database log-dashboard.sqlite `
    --query "VACUUM INTO 'log-dashboard-share.sqlite'" --output none
```

A private SQLite file is still private data. Limit access, keep build/source identifiers out of public downloads, and obtain permission before sending it to a cloud service. This tutorial creates local artifacts only.

### Choose the visualization connection

| Route | What you hand over | What else is needed |
| --- | --- | --- |
| Desktop BI through ODBC | The closed `.sqlite` snapshot | A compatible, separately installed SQLite ODBC driver and a configured DSN; ULP does not supply one |
| CSV/Excel import | Selected rows exported from `log_hourly` | The BI tool's file connector; no SQLite driver needed |
| Cloud dashboard with local data | Published BI model/extract plus a supported refresh route | Gateway/Bridge and compatible driver/file access where supported; not just a SQLite upload |
| Cloud database/warehouse | Ordinary report tables transferred through an approved ingestion process | A separately provisioned supported service, credentials, schema mapping, and refresh process |

For a first visualization, CSV is the simplest fallback:

```powershell
ulp --no-config --no-env --database log-dashboard.sqlite `
    --query "SELECT * FROM log_hourly ORDER BY hour_utc, route" `
    --output file --format CSV --output-file log-hourly.csv --no-overwrite
```

Use `--format Excel --output-file log-hourly.xlsx` for a workbook. Neither export preserves SQLite indexes; that is expected because the receiving tool imports the rows into its own model.

**Power BI Desktop:** configure an approved SQLite ODBC driver with the architecture required by your BI installation and a DSN such as `ULPLogs` pointing to the snapshot. Choose **Get data > ODBC**, select the DSN, and import `log_hourly`. Alternatively import the CSV through **Text/CSV**. Confirm timestamps and numeric types after import. Power Query documents ODBC Import and an online gateway route; this is not a promise of SQLite DirectQuery support. See the [Power Query ODBC connector](https://learn.microsoft.com/en-us/power-query/connectors/odbc).

**Tableau Desktop:** choose **Other Databases (ODBC)**, select your SQLite DSN, and choose `log_hourly`, or use the text-file connector for CSV. Tableau warns that generic ODBC feature compatibility is not guaranteed; validate your driver before relying on it. Driver/DSN configuration must also exist where published data will be read. See [Tableau's ODBC guidance](https://help.tableau.com/current/pro/desktop/en-us/examples_otherdatabases.htm).

**Cloud refresh:** a local path on your laptop is not a reachable cloud data source. Power BI's gateway host needs the appropriate connector configuration, driver, and permission to read the snapshot. For Tableau Cloud, Bridge supports private-network data, but ODBC support is limited; verify your exact connection or use a supported file/extract route. See the [Tableau Bridge FAQ](https://help.tableau.com/current/online/en-us/to_bridge_faq.htm). Uploading a `.sqlite` file to object storage does not turn it into a network database endpoint. For unattended operation, first produce and validate a closed snapshot, then publish/import it through an approved workflow and test one refresh end to end.

The SQL and local exports here are tested; an actual Power BI/Tableau tenant, driver installation, and scheduled cloud refresh require your own environment and acceptance test.

### Build the log dashboard

Try a line chart of `requests` by `hour_utc`, a bar chart of `errors` by `route`, and an error-rate card calculated as total errors divided by total requests. Use a numeric duration axis for latency. Keep UTC explicit or apply one deliberate display-zone conversion.

Do not sum or average the hourly `p95_ms` values to obtain an overall p95. Recompute it from the request rows in ULP and materialize the desired reporting grain. Similarly, combine averages using `SUM(total_duration_ms) / SUM(requests)`, not an unweighted average of hourly means. For recurring loads, define a stable event identity and deduplication strategy before appending; repeatedly inserting the same logs will inflate every chart.

## Build a development and CI evidence report

**Goal:** turn build/test artifacts, source snapshots, and assembly metadata into a repeatable report, then fail a CI step when an explicit policy is violated. This complements the compiler, test runner, package audit, and security tools; it does not replace them.

The `samples/tutorials` bundle is fictional and intentionally includes one compiler error, one failed test, and one unapproved assembly reference. Its short hash labels are placeholders for explaining a join, not real SHA-256 values. Run it in a fresh database:

```powershell
ulp --no-config --no-env --database development-report.sqlite `
    --query-file samples/tutorials/development-report.sql --format TextTable
```

| compiler_errors | failed_tests | unexpected_references |
| --- | --- | --- |
| 1 | 1 | 1 |

### Inspect compiler diagnostics and test statistics

The SQL first materializes TextLine input, then filters and extracts diagnostics from ordinary SQLite rows. Keep that staging step: it supports repeatable analysis and avoids applying this regex filter directly to a streaming input in the current build. The pattern accepts the sample's `file(line,column): warning/error CODE:` form; it does not cover every compiler, locale, build-node prefix, multiline diagnostic, or binary log. Unsupported output is **not** evidence of a clean build.

`[ ]` in these expressions explicitly matches a literal space. Exact repeated diagnostic lines in the build summary are deduplicated; this counts unique diagnostics, not occurrences or failing projects.

```powershell
ulp --database development-report.sqlite `
    --query "SELECT severity, code, COUNT(*) AS diagnostics FROM compiler_diagnostics GROUP BY severity, code ORDER BY severity, code" `
    --format TextTable

ulp --database development-report.sqlite `
    --query "SELECT outcome, COUNT(*) AS tests, SUM(duration_ms) AS total_ms FROM test_results GROUP BY outcome ORDER BY outcome" `
    --format TextTable
```

Expected diagnostics: one `CS1002` error, one `CS0168` warning, and one `CS0219` warning. Expected tests: one Failed (`8 ms`), two Passed (`17 ms` total), and one Skipped (`0 ms`). Test durations are not total pipeline wall-clock time, particularly with parallel execution.

For actual test output, convert TRX files to the same normalized columns with the supplied helper:

```powershell
.\samples\tutorials\Convert-TrxToCsv.ps1 `
    -InputPath .\samples\tutorials\test-results.trx `
    -OutputFile .\normalized-tests.csv
```

The helper refuses to overwrite an existing CSV, rejects DTDs, converts durations to milliseconds, and maps `NotExecuted` to `Skipped`. Other outcome names are preserved; review them instead of silently counting every non-`Failed` row as passed. For real runs, include all relevant TRX files and retain project/framework/run identity when names can repeat. Update a copy of `development-report.sql` to point `tests_input` at your normalized file. Keep the original TRX as evidence.

### Inspect source-code hotspots

```powershell
ulp --no-config --no-env --input SourceCode `
    --from samples/data/source-code-agent-sample.cs --input.IncludedKinds Method `
    --table code --query "SELECT Name, StartLine, EndLine, CyclomaticHint FROM code ORDER BY StartLine" `
    --format TextTable
```

| Name | StartLine | EndLine | CyclomaticHint |
| --- | --- | --- | --- |
| .ctor | 15 | 18 | 1 |
| LoadAsync | 21 | 31 | 2 |
| Parse | 33 | 36 | 1 |
| Parse | 38 | 41 | 1 |
| Classify | 44 | 51 | 4 |

Constructors are included in this view. The sample deliberately contains a syntax error, demonstrating that partial structure can still be useful for navigation. It does not mean the sample compiles. `CyclomaticHint` is a ranking hint, not a formal complexity certification; overlapping declaration spans must not be summed as physical file line counts.

For your own repository, materialize the bounded source tree using [the code snapshot workflow](#build-a-searchable-code-snapshot). Exclude generated/vendor code consistently across runs. Report method counts, largest spans, branch hints, imports, or syntax diagnostics, and keep file paths/line spans so a developer can inspect the finding. A snapshot needs the commit/build identity: stale or partial snapshots must not masquerade as the current checkout. Source parsing does not perform full semantic compilation or prove which code will execute.

### Report changed files

The bundled before/after manifests produce:

| path | change |
| --- | --- |
| src/New.cs | Added |
| src/Orders.cs | Modified |
| src/Retired.cs | Deleted |

`changed_files` uses a left join for added/modified paths and `UNION ALL` with a reverse anti-join for deletions. In real manifests, use stable repository-relative paths and actual content hashes. Use the same root, exclusions, path casing, and hash algorithm on both sides; capture both snapshots at known revisions. A rename appears as delete/add in this simple comparison, and an unchanged path with a changed hash is Modified. Git's own diff remains the authoritative route for version-control rename/staging information.

Create a manifest for a **small, explicitly selected** source tree in PowerShell; choose a new output file:

```powershell
$sourceRoot = (Resolve-Path .\src).Path.TrimEnd('\')
if (Test-Path .\files-current.csv) { throw 'Choose a new manifest filename.' }
Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Filter *.cs |
    Where-Object { $_.FullName -notmatch '[\\/](bin|obj)[\\/]' } |
    ForEach-Object {
        [pscustomobject]@{
            path = $_.FullName.Substring($sourceRoot.Length + 1).Replace('\', '/')
            sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    } | Export-Csv .\files-current.csv -NoTypeInformation -Encoding UTF8
```

Hashing reads every selected file. Record the chosen root (`src` here) alongside each manifest; do not compare it directly with a manifest rooted at the whole repository. For a PR report, join the changed paths to the source snapshot and show only changed-file hotspots. Deleted files will not have current source rows.

### Compare assembly references with an allowlist

Inspect a real managed build output without executing its code:

```powershell
ulp --input DotNetAssembly --from 'C:/Work/Demo/publish/Demo.dll' --table assemblies `
    --query "SELECT AssemblyName, AssemblyVersion, TargetFramework, TypeCount, MethodCount, ReferencedAssemblyCount, SHA256 FROM assemblies" `
    --output file --format CSV --output-file assembly-summary.csv --no-overwrite

ulp --input DotNetAssembly --from 'C:/Work/Demo/publish/Demo.dll' `
    --input.View References --table refs `
    --query "SELECT ParentFile, AssemblyName, Version, PublicKeyToken FROM refs" `
    --output file --format CSV --output-file actual-references.csv --no-overwrite
```

Replace the example path with your selected output. To inspect multiple managed DLLs, use a bounded wildcard source and explicit recursion. Mixed publish folders may contain native DLLs: the default reports invalid input rather than silently omitting it. If you deliberately enable `IgnoreInvalidFiles`, document the resulting coverage gap and inventory native files separately.

The sample compares the tuple `(AssemblyName, Version, PublicKeyToken)` with `allowed-assemblies.csv` using `NOT EXISTS`. It reports `Unexpected.Library` as unapproved. Use exact approved versions unless your policy explicitly defines another rule; do not compare dotted versions as ordinary text ranges or approve every version of a name accidentally. Restrict who can edit the allowlist; automatically accepting the current report defeats the check.

**Assembly reference is not NuGet package identity.** A manifest reference does not prove a matching DLL was shipped, loaded, or exercised by tests. A public-key token is not signature verification. Package identity/version can differ from assembly identity/version; dynamic loading, native libraries, trimming, single-file publishing, and embedded resources require additional evidence.

For a package allowlist, also obtain the resolved direct/transitive package report for your own project. With .NET 10, for example:

```powershell
dotnet package list --project .\Demo.sln --include-transitive --no-restore `
    --format json --output-version 1 > packages.json
if ($LASTEXITCODE -ne 0) { throw 'Package inventory failed.' }
```

Older SDKs use the verb-first `dotnet list ... package` form; consult [the SDK package-list reference](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-package-list). Normalize that report into package ID, resolved version, project, and target framework before an equivalent allowlist anti-join. Compare those results with the actual publish-file inventory/hashes; do not relabel the assembly CSV as a package inventory or a license/vulnerability audit.

### Make the report a CI check

An informative SELECT normally exits successfully even if it returns bad findings. Add an explicit assertion:

```powershell
ulp --no-config --no-env --database development-report.sqlite `
    --query "SELECT compiler_errors + failed_tests + unexpected_references FROM gate_summary" `
    --output none --expect-scalar 0
$policyExit = $LASTEXITCODE
```

The fixture returns exit **4**, with `condition not met: first value was '3'; expected '0'`. A matching assertion returns zero. In a real check, reject missing/empty artifacts and unknown outcomes too; zero parsed diagnostics must not override a failed compiler or test-runner exit code.

For a VSTest-based .NET project, capture output like this in your own build workspace, using a new evidence folder per run:

```powershell
$evidenceDir = '.\build-evidence-' + [guid]::NewGuid().ToString('N')
New-Item -ItemType Directory -Path $evidenceDir | Out-Null
dotnet build .\Demo.sln --configuration Release --nologo --verbosity minimal `
    *> (Join-Path $evidenceDir 'compiler-output.txt')
$buildExit = $LASTEXITCODE
$testExit = 0
if ($buildExit -eq 0) {
    dotnet test .\Demo.sln --configuration Release --no-build `
        --logger 'trx;LogFilePrefix=tests' --results-directory $evidenceDir
    $testExit = $LASTEXITCODE
}
# Normalize artifacts and run YOUR adapted ULP report/gates here.
# Save each native exit code immediately, before another command replaces it.
# Upload sanitized evidence using your CI system's always/finally step.
if ($buildExit -ne 0) { exit $buildExit }
if ($testExit -ne 0) { exit $testExit }
```

The capture fragment is not a complete policy script: insert the adapted report/normalization and propagate its nonzero exit code too. Never execute the fictional sample as the production gate. VSTest's TRX logger and Microsoft's newer Testing Platform have different options; use the [VSTest command reference](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-test-vstest) or [Testing Platform guidance](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-dotnet-test) for your runner. Check console-file encoding when adapting TextLine options, especially between Windows PowerShell and PowerShell 7.

Retain the commit, SDK/ULP versions, original logs/TRX, selected file hashes, report database, and exported CSV/HTML with a retention policy. Build logs can contain secrets and internal paths: sanitize before uploading and do not expose artifacts from untrusted pull requests with privileged credentials. Build failure, test failure, data-ingestion failure, and policy failure are separate signals; preserve all of them.

**Try it:** copy the fixtures, remove the intentional error, change the failed test to Passed, and explicitly approve the fictional dependency. Use a fresh database and verify the assertion succeeds. Then introduce one new finding and confirm CI fails again before trusting the gate in a real pipeline.

## Reuse a report with parameters

**Goal:** change a filter without editing SQL or concatenating values into it.

Save a query in the Query library with declared parameters:

```sql
-- title: Employees above a salary threshold
-- command: high-salary
-- provider: CSV
-- source: samples/data/employees.csv
-- table: employees
-- parameter: minimum=120000
SELECT employee_name, salary
FROM employees
WHERE CAST(salary AS INTEGER) >= :minimum
ORDER BY CAST(salary AS INTEGER) DESC;
```

```powershell
ulp --command high-salary --p.minimum 120000 --format TextTable
```

| employee_name | salary |
| --- | --- |
| Margaret | 132000 |
| Grace | 126000 |

The parameter is a value, not SQL syntax. It cannot safely substitute a table name, column name, or whole WHERE clause. Use `--queries-dir` to select a different library. In MCP, discover and load the saved recipe for review before executing it in your task's session.

## Publish the same result in different formats

**Goal:** share a report with a person, spreadsheet, or another program.

```powershell
ulp --input CSV --from samples/data/employees.csv --table employees `
    --query "SELECT employee_name, salary FROM employees WHERE CAST(salary AS INTEGER) >= 120000 ORDER BY CAST(salary AS INTEGER) DESC" `
    --output file --format CSV --output-file salary-report.csv
```

Change `--format CSV` and the extension to try `JSON`, `Markdown`, `HTML`, or `Excel`. A file extension alone does not select the writer. Consult writer help for HTML styling, JSON metadata, and workbook options.

For simultaneous destinations, use the documented [output pipelines](reference/generated/output-pipelines-reference.md). File formats share the same result; interactive TUI output is not a file writer. See the [output examples](samples.md#export-examples) for side-by-side representations.

## Review an AI-assisted investigation

**Goal:** use an agent for investigation while keeping queries grounded in actual data.

1. Connect ULP through MCP and call `GetRuntimeInfo`.
2. Create a named session for the task and use its `sessionId` consistently.
3. Ask the agent to inspect providers, saved recipes, and actual schemas.
4. Request a small query with explicit columns and a limit.
5. Check the result against the source and expand only when necessary.
6. Close the session after exporting anything you need to retain.

Example prompt: “Inspect the code provider and the Code recipes. Analyze only the `src` subtree. Materialize once for repeated queries. Find parsing methods and their diagnostics; return file paths and exact line spans. Do not claim a call graph from text matches.”

ULP's optional web and SQL-shell AI chat is experimental and separate from external coding agents using MCP. It must be explicitly configured, sends information to the chosen provider, and requires reviewing generated SQL. Read [AI configuration and privacy](ai.md) before enabling it.
