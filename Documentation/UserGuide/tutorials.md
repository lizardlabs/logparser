# ULP use-case tutorials

Start with a job, not a list of SQL keywords. These walkthroughs use the fictional data supplied in `samples/data`. Run commands from the extracted ULP folder. In PowerShell, use `ulp` after adding it to PATH, or replace it with `.\ulp.exe`. Backticks continue a command onto the next line.

## Contents

- [Find the failure in an application log](#find-the-failure-in-an-application-log)
- [Summarize a spreadsheet export](#summarize-a-spreadsheet-export)
- [Combine employee and department data](#combine-employee-and-department-data)
- [Find failing web requests](#find-failing-web-requests)
- [Investigate files without opening each one](#investigate-files-without-opening-each-one)
- [Build a searchable code snapshot](#build-a-searchable-code-snapshot)
- [Reuse a report with parameters](#reuse-a-report-with-parameters)
- [Publish the same result in different formats](#publish-the-same-result-in-different-formats)
- [Review an AI-assisted investigation](#review-an-ai-assisted-investigation)

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

For plain text or an unsupported language, use `TextLine` and inspect its schema. Phrase searching and line-range extraction complement structural analysis; they do not prove call relationships. For C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown, inspect `SourceCode` options for comments, diagnostics, imports, calls, generated files, and bounded parsing.

**Try it:** ask an agent to inventory a bounded subtree, materialize it once, return concise matches with paths and spans, then read only the selected source sections. See [agent workflows](ai.md#use-ulp-directly-from-an-agent).

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
