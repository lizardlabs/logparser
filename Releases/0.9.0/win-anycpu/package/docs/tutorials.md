# ULP Tutorials

These tutorials form a progressive introduction to Universal Log Parser. They use the fictional files under `samples/data` so that the commands are safe, repeatable, and easy to compare. Run them from the ULP installation or project directory so the relative paths resolve correctly.

The examples use PowerShell line continuation. In Command Prompt, place the command on one line and remove the backticks.

## Contents

- [Tutorial 1 — Your First Query](#tutorial-1--your-first-query)
- [Tutorial 2 — Selecting Columns](#tutorial-2--selecting-columns)
- [Tutorial 3 — Filtering Data](#tutorial-3--filtering-data)
- [Tutorial 4 — Sorting Results](#tutorial-4--sorting-results)
- [Tutorial 5 — Counting and Aggregation](#tutorial-5--counting-and-aggregation)
- [Tutorial 6 — Grouping](#tutorial-6--grouping)
- [Tutorial 7 — Working With Text](#tutorial-7--working-with-text)
- [Tutorial 8 — Dates and Times](#tutorial-8--dates-and-times)
- [Tutorial 9 — Querying Multiple Files](#tutorial-9--querying-multiple-files)
- [Tutorial 10 — Exporting Results](#tutorial-10--exporting-results)
- [Tutorial 11 — Using the ULP User Interface](#tutorial-11--using-the-ulp-user-interface)
- [Tutorial 12 — AI-Assisted Querying](#tutorial-12--ai-assisted-querying)
- [Tutorial 13 — Real-World Log Analysis](#tutorial-13--real-world-log-analysis)
- [Continue Learning](#continue-learning)

## Tutorial 1 — Your First Query

### Goal

Read a CSV file as a table and display its first five rows.

### Input

`samples/data/employees.csv` contains fictional employee data with this header:

```text
employee_id,employee_name,department_id,salary,hired_on,active
```

### Query

```sql
SELECT *
FROM employees
LIMIT 5;
```

### Run It

```powershell
ulp --input CSV `
    --from .\samples\data\employees.csv `
    --table employees `
    --query "SELECT * FROM employees LIMIT 5" `
    --output console --format Terminal
```

### Output

The result begins with Ada, Grace, Linus, Margaret, and Ken. The exact borders and colors depend on the terminal, but the columns come from the CSV header.

### Explanation

- `--input CSV` selects the CSV provider.
- `--from` identifies the source file.
- `--table employees` gives the source a SQL table name.
- `--query` supplies SQLite SQL.
- `--output console --format Terminal` displays a formatted table.
- `LIMIT 5` keeps the first exploration bounded.

ULP streams provider records through a ParsingModule virtual table. You can usually start with a CLI source block as shown here; ULP prepares the corresponding table before it runs your query.

### Try It Yourself

- Change `LIMIT 5` to `LIMIT 2`.
- Replace `SELECT *` with `SELECT employee_name`.
- Run `ulp --list-providers` to see other available inputs.

## Tutorial 2 — Selecting Columns

### Goal

Return only useful columns and give calculated expressions clear names.

### Input

Continue using `samples/data/employees.csv` as the `employees` table.

### Query

```sql
SELECT employee_name AS Name,
       CAST(salary AS INTEGER) AS Salary,
       hired_on AS HiredOn
FROM employees
LIMIT 5;
```

### Run It

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name AS Name, CAST(salary AS INTEGER) AS Salary, hired_on AS HiredOn FROM employees LIMIT 5" `
    --output console --format Terminal
```

### Output

| Name | Salary | HiredOn |
| --- | ---: | --- |
| Ada | 118000 | 2019-04-15 |
| Grace | 126000 | 2018-09-03 |
| Linus | 99000 | 2021-01-11 |
| Margaret | 132000 | 2017-06-20 |
| Ken | 115000 | 2020-11-02 |

### Explanation

The `SELECT` list controls the result shape. `AS` supplies readable output names. `CAST(salary AS INTEGER)` makes numeric sorting and arithmetic explicit when values originate in a text-oriented source.

ULP does not require every source column to appear in the result. Selecting only needed fields makes wide log and event results easier to read and cheaper to export.

### Try It Yourself

- Add `department_id AS Department`.
- Calculate an annual amount in thousands with `ROUND(CAST(salary AS REAL) / 1000, 1)`.
- Rearrange the expressions and observe the output column order.

## Tutorial 3 — Filtering Data

### Goal

Return only active employees whose salary is at least 110,000.

### Input

`samples/data/employees.csv` contains an `active` text field and a numeric-looking `salary` field.

### Query

```sql
SELECT employee_name,
       department_id,
       CAST(salary AS INTEGER) AS salary
FROM employees
WHERE lower(active) = 'true'
  AND CAST(salary AS INTEGER) >= 110000
ORDER BY employee_name;
```

### Run It

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name, department_id, CAST(salary AS INTEGER) AS salary FROM employees WHERE lower(active)='true' AND CAST(salary AS INTEGER)>=110000 ORDER BY employee_name" `
    --output console --format Terminal
```

### Output

| employee_name | department_id | salary |
| --- | ---: | ---: |
| Ada | 10 | 118000 |
| Grace | 10 | 126000 |
| Margaret | 30 | 132000 |

### Explanation

`WHERE` removes rows that do not meet the condition. `AND` requires both conditions to be true. `lower(active) = 'true'` avoids a case-sensitive comparison, while the numeric cast prevents a text comparison such as `"99000" > "110000"`.

Use `IS NULL` and `IS NOT NULL` for missing SQL values. Do not compare a nullable column with `= NULL`.

### Try It Yourself

- Change `AND` to `OR` and compare the result.
- Filter one department with `department_id = '30'`.
- Find inactive rows with `lower(active) = 'false'`.

## Tutorial 4 — Sorting Results

### Goal

Show the five highest salaries in descending order.

### Input

Continue using the employee CSV.

### Query

```sql
SELECT employee_name,
       CAST(salary AS INTEGER) AS salary
FROM employees
ORDER BY salary DESC, employee_name
LIMIT 5;
```

### Run It

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_name, CAST(salary AS INTEGER) AS salary FROM employees ORDER BY salary DESC, employee_name LIMIT 5" `
    --output console --format Terminal
```

### Output

| employee_name | salary |
| --- | ---: |
| Margaret | 132000 |
| Grace | 126000 |
| Ada | 118000 |
| Ken | 115000 |
| Alan | 109000 |

### Explanation

`DESC` sorts from the largest value to the smallest. The second expression, `employee_name`, provides deterministic ordering if two employees have the same salary. `LIMIT` is applied after ordering, so the result is the top five rather than five arbitrary rows sorted afterward.

### Try It Yourself

- Use `ASC` to show the lowest salaries.
- Sort by department first and salary second.
- Add `OFFSET 2` to skip the first two rows.

## Tutorial 5 — Counting and Aggregation

### Goal

Calculate one summary row for the employee file.

### Input

The employee sample contains eight records with salary and active-status values.

### Query

```sql
SELECT COUNT(*) AS employees,
       SUM(CASE WHEN lower(active) = 'true' THEN 1 ELSE 0 END) AS active_employees,
       MIN(CAST(salary AS INTEGER)) AS minimum_salary,
       ROUND(AVG(CAST(salary AS REAL)), 2) AS average_salary,
       MAX(CAST(salary AS INTEGER)) AS maximum_salary
FROM employees;
```

### Run It

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT COUNT(*) AS employees, SUM(CASE WHEN lower(active)='true' THEN 1 ELSE 0 END) AS active_employees, MIN(CAST(salary AS INTEGER)) AS minimum_salary, ROUND(AVG(CAST(salary AS REAL)),2) AS average_salary, MAX(CAST(salary AS INTEGER)) AS maximum_salary FROM employees" `
    --output console --format Terminal
```

### Output

The query returns one row. `employees` is `8`, `active_employees` is `7`, the minimum is `88000`, and the maximum is `132000`.

### Explanation

Aggregate functions summarize many input rows. `COUNT(*)` counts rows. `MIN`, `AVG`, and `MAX` operate on the numeric salary expression. The `CASE` expression turns each active row into `1` and each inactive row into `0`, which makes the `SUM` an active-record count.

### Try It Yourself

- Add `SUM(CAST(salary AS INTEGER)) AS total_salary`.
- Add `WHERE lower(active) = 'true'` before the final semicolon.
- Compare `COUNT(*)` with `COUNT(salary)` after introducing a null value in a temporary copy of the sample.

## Tutorial 6 — Grouping

### Goal

Calculate employee count and average salary for each department ID.

### Input

The employee CSV contains four department IDs.

### Query

```sql
SELECT CAST(department_id AS INTEGER) AS department_id,
       COUNT(*) AS employees,
       ROUND(AVG(CAST(salary AS REAL)), 2) AS average_salary
FROM employees
GROUP BY CAST(department_id AS INTEGER)
ORDER BY department_id;
```

### Run It

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT CAST(department_id AS INTEGER) AS department_id, COUNT(*) AS employees, ROUND(AVG(CAST(salary AS REAL)),2) AS average_salary FROM employees GROUP BY CAST(department_id AS INTEGER) ORDER BY department_id" `
    --output console --format Terminal
```

### Output

| department_id | employees | average_salary |
| ---: | ---: | ---: |
| 10 | 3 | 117666.67 |
| 20 | 2 | 102000.00 |
| 30 | 2 | 123500.00 |
| 40 | 1 | 88000.00 |

### Explanation

`GROUP BY` produces one aggregate group for each distinct department ID. Every selected expression must either describe the group or be calculated with an aggregate function. `HAVING` can filter completed groups, for example `HAVING COUNT(*) >= 2`.

### Try It Yourself

- Add `HAVING COUNT(*) >= 2`.
- Group by `lower(active)` instead.
- Run the checked-in `samples/parsingmodule/04-csv-aggregation.sql` query file.

## Tutorial 7 — Working With Text

### Goal

Find error records in an ordinary text log.

### Input

`samples/data/application.log` contains one log record per line:

```text
2026-08-17T08:02:10Z ERROR worker retry-scheduled job=77 attempt=2
```

### Query

```sql
SELECT Text
FROM logs
WHERE upper(Text) LIKE '%ERROR%';
```

### Run It

```powershell
ulp --input TextLine `
    --from .\samples\data\application.log `
    --table logs `
    --query "SELECT Text FROM logs WHERE upper(Text) LIKE '%ERROR%'" `
    --output console --format Terminal
```

### Output

The sample returns the single `ERROR worker retry-scheduled` line.

### Explanation

The `TextLine` provider exposes each line through the `Text` column. `upper` normalizes case and `LIKE '%ERROR%'` searches anywhere in the value. This is useful for exploration, although the direct search command is shorter when SQL is unnecessary:

```powershell
ulp search ERROR .\samples\data\application.log --ignore-case
```

Use a structured provider such as `RegEx`, `CSV`, `TSV`, `JSON`, or `W3C` when you need fields instead of whole-line matches.

### Try It Yourself

- Search for `WARN`.
- Select `length(Text) AS characters` with the text.
- Use `substr(Text, 1, 20)` to project the timestamp prefix.

## Tutorial 8 — Dates and Times

### Goal

Group employees by hire year with SQLite date functions.

### Input

The `hired_on` CSV field uses ISO dates such as `2019-04-15`.

### Query

```sql
SELECT strftime('%Y', hired_on) AS hire_year,
       COUNT(*) AS employees
FROM employees
GROUP BY strftime('%Y', hired_on)
ORDER BY hire_year;
```

### Run It

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT strftime('%Y', hired_on) AS hire_year, COUNT(*) AS employees FROM employees GROUP BY strftime('%Y', hired_on) ORDER BY hire_year" `
    --output console --format Terminal
```

### Output

The sample has one hire in each year from 2016 through 2023.

### Explanation

SQLite's `strftime` extracts a formatted portion of a recognized date/time value. ISO-8601 values are the most predictable input. ULP also registers additional date/time helpers for Unix timestamps, UTC, timezones, weekdays, weekends, and ISO weeks; use `ulp --list-functions` to inspect the current runtime.

When filtering by a date range, prefer an inclusive lower bound and exclusive upper bound:

```sql
WHERE hired_on >= '2020-01-01'
  AND hired_on <  '2022-01-01'
```

### Try It Yourself

- Select `date(hired_on)` to normalize the date.
- Group by `strftime('%m', hired_on)` for month number.
- Filter hires from 2020 onward.

## Tutorial 9 — Querying Multiple Files

### Goal

Inventory all files directly under the sample-data directory and summarize them by extension.

### Input

`samples/data` contains CSV, JSON, YAML, TOON, TSV, log, and source-code samples.

### Query

```sql
SELECT lower(Extension) AS extension,
       COUNT(*) AS files,
       SUM(LengthInBytes) AS bytes
FROM files
GROUP BY lower(Extension)
ORDER BY files DESC, extension;
```

### Run It

```powershell
ulp --input FileSystem `
    --from ".\samples\data\*" `
    --table files `
    --i.FileSystem.Recurse 0 `
    --i.FileSystem.IncludeAllFiles true `
    --i.FileSystem.IncludeMediaProperties false `
    --query "SELECT lower(Extension) AS extension, COUNT(*) AS files, SUM(LengthInBytes) AS bytes FROM files GROUP BY lower(Extension) ORDER BY files DESC, extension" `
    --output console --format Terminal
```

### Output

The exact byte totals can change when samples are edited. The result contains one row per extension; in the current sample set, C# and CSV have multiple files.

### Explanation

`--from` accepts wildcards and multiple comma/semicolon-separated sources. Stream/file providers expand them lazily. Prefix an exclusion with `!`, for example:

```text
.\logs\*;!*.bak;!archive-*.log
```

When every source is negative, ULP implicitly starts from `*`. Use `!!name` for a literal source beginning with `!`. Archive-entry selectors use `archive.zip|*.log`.

The installed Query library includes a tagged directory recipe, so this shorter command lists only C# files:

```powershell
ulp -c.dir --from ".\samples\data\*" --p.extension .cs --format Terminal
```

### Try It Yourself

- Change `Recurse` to `-1` and run against a small test directory.
- Add `HUMANIZE_BYTES(SUM(LengthInBytes)) AS readable_size`.
- Run `ulp -c.dir --p.extension .json`.

## Tutorial 10 — Exporting Results

### Goal

Write one query result to JSON, CSV, and Excel without executing the source query three times.

### Input

Use the active employees from the CSV sample.

### Query

```sql
SELECT employee_id,
       employee_name,
       CAST(salary AS INTEGER) AS salary
FROM employees
WHERE lower(active) = 'true'
ORDER BY employee_id;
```

### Run It

```powershell
ulp --input CSV --from .\samples\data\employees.csv --table employees `
    --query "SELECT employee_id, employee_name, CAST(salary AS INTEGER) AS salary FROM employees WHERE lower(active)='true' ORDER BY employee_id" `
    --output file --format JSON --output-file .\output\active-employees.json `
    --also-pipeline CSV=.\output\active-employees.csv `
    --also-pipeline Excel=.\output\active-employees.xlsx
```

Create the `output` directory first if it does not exist.

### Output

The command creates three files containing the same seven active employee rows. JSON preserves a structured representation, CSV is convenient for text interchange, and Excel creates an `.xlsx` workbook.

### Explanation

`--output` selects a destination and `--format` selects a writer. `--also-pipeline` fans the already executed result out to another file-capable writer. Interactive writers such as the TUI are not file pipelines.

Use `--no-output-if-empty` when an empty query should leave targets untouched. Use `--no-overwrite` when replacing an existing file is not allowed. Output filenames can contain documented date/time tokens and `{n}` for the first free positive sequence number.

### Try It Yourself

- Add `--also-pipeline Markdown=.\output\active-employees.md`.
- Use `--format TOON` for a compact tabular representation.
- Add `--no-output-if-empty` and filter for a nonexistent employee.

## Tutorial 11 — Using the ULP User Interface

### Goal

Run a saved query through a guided interface instead of composing the full command line.

### Input

Use the installed Query library and its `Directory listing` recipe.

### Query

The recipe is stored under `queries/Files/dir.sql`. It declares a FileSystem source, a default terminal output, and an optional `extension` parameter.

### Run It

Open the beginner menu:

```powershell
ulp --menu
```

Then:

1. choose **Query library**;
2. open the **Files** folder;
3. choose **Directory listing**;
4. review the description, source, parameter, and SQL;
5. optionally set `extension` to `.log`;
6. preview the query;
7. execute or return without running it.

The equivalent direct command is:

```powershell
ulp -c.dir --from ".\samples\data\*" --p.extension .log
```

### Output

The terminal result lists matching names, extensions, readable sizes, byte sizes, timestamps, and full paths. The query is limited to 200 rows.

### Explanation

The menu, Query Builder, SQL shell, TUI, and optional local web interface are different ways to work with the same SQLite/provider concepts. Query execution uses a common preview-and-run workflow where applicable.

The browser interface starts with:

```powershell
ulp --web
```

Its guided setup asks for bind address, port, HTTPS or explicit HTTP, authentication, permission mode, Query library, and web application directory. HTTPS is the default. A sanitized review lets you start, go back, or cancel without displaying passwords. The web Query library supports direct query tabs, parameters, filtering, sorting, virtual grid scrolling, export, and a full-window result view.

### Try It Yourself

- Open `ulp --menu --advanced-menu` and compare the additional tools.
- Open a Query library recipe in a new browser tab.
- Use the grid's search, filter, column chooser, and expand action.

## Tutorial 12 — AI-Assisted Querying

### Goal

Understand the safe review workflow for the experimental web AI Chat without treating it as a supported CLI feature.

### Input

AI Chat can receive a bounded schema description, your prompt, and conversation context. That information may leave the computer and be processed by the configured external API provider.

### Query

There is no starting SQL query. A suitable prompt is:

```text
Write a bounded SQLite query that counts warnings and errors by SourceName,
sorts the largest count first, and returns at most 20 groups.
Do not execute it.
```

### Run It

AI Chat is experimental, disabled by default, and available only when explicitly configured for the optional web interface. Store the API key outside the command line, then reference the environment variable:

```powershell
ulp --web --web-ai --web-ai-key '@env:ULP_AI_API_KEY'
```

Prefer a secure secret source appropriate for your environment, and clear temporary environment variables when they are no longer needed. Do not paste an actual key into documentation, shell history, source control, or a shared command line.

### Output

The assistant returns proposed SQL for review. ULP does not execute generated SQL automatically. Inspect table names, columns, filters, limits, joins, and any data-changing statements before choosing to run it.

### Explanation

AI output can be incomplete, incorrect, expensive, or unsafe. Schema names can also reveal sensitive operational details. Confirm that you are authorized to send the schema, prompt, and conversation to the provider and review its privacy, retention, and security terms.

AI-assisted SQL is in development and is not available as a supported command-line or SQL-shell feature. Its configuration and behavior may change.

### Try It Yourself

- Ask for an explanation of generated SQL before running it.
- Ask the assistant to add an explicit `LIMIT`.
- Compare the proposed columns with `PRAGMA table_info(table_name)`.
- Disable the endpoint with `--web-no-ai` when it is not needed.

## Tutorial 13 — Real-World Log Analysis

### Goal

Summarize HTTP-like request records, identify errors, and calculate an error percentage.

### Input

`samples/data/requests.tsv` contains three fictional tab-separated request records:

| timestamp | method | status | path |
| --- | --- | ---: | --- |
| 2026-08-19T10:00:00Z | GET | 200 | `/` |
| 2026-08-19T10:01:00Z | POST | 500 | `/api/orders` |
| 2026-08-19T10:02:00Z | GET | 404 | `/missing` |

### Query

```sql
SELECT COUNT(*) AS total_requests,
       SUM(CASE WHEN CAST(status AS INTEGER) >= 400 THEN 1 ELSE 0 END) AS failed_requests,
       ROUND(
           100.0 * SUM(CASE WHEN CAST(status AS INTEGER) >= 400 THEN 1 ELSE 0 END)
           / NULLIF(COUNT(*), 0),
           2
       ) AS failure_percent
FROM requests;

SELECT status,
       COUNT(*) AS requests
FROM requests
GROUP BY status
ORDER BY CAST(status AS INTEGER);
```

### Run It

Save the two statements in `request-analysis.sql`, then run:

```powershell
ulp --input TSV `
    --from .\samples\data\requests.tsv `
    --table requests `
    --query-file .\request-analysis.sql `
    --output console --format Terminal
```

For a single-statement command, summarize by status directly:

```powershell
ulp --input TSV --from .\samples\data\requests.tsv --table requests `
    --query "SELECT status, COUNT(*) AS requests FROM requests GROUP BY status ORDER BY CAST(status AS INTEGER)" `
    --output console --format Terminal
```

### Output

The sample contains three requests, two status codes at or above 400, and a failure percentage of `66.67`. The second result set contains one row each for status `200`, `404`, and `500`.

### Explanation

This pattern combines parsing, classification, aggregation, safe division, multiple result sets, and deterministic sorting. `NULLIF(COUNT(*), 0)` prevents division by zero for an empty source. In a larger investigation you might group by hour, path, method, server, client address, or status family.

For Windows event logs, the checked-in `samples/parsingmodule/02-evt-error-summary.sql` applies the same idea to `System` and `Application` warnings/errors. Event availability and permissions vary by computer, so the TSV example remains deterministic.

### Try It Yourself

- Group by `method`.
- Extract a status family with `CAST(status AS INTEGER) / 100`.
- Filter to `CAST(status AS INTEGER) >= 500`.
- Export both result sets to Excel, where each result set becomes a worksheet.

## Continue Learning

- [Getting Started](getting-started.md) summarizes the core ULP workflow.
- [Installing ULP](installation.md) covers supported installation and verification.
- [SQLite and ParsingModule](sqlite-guide.md) explains SQL, virtual tables, functions, and database information.
- [Sample catalog](samples.md) describes the checked-in Query library and sample SQL files.
- [Input providers and output writers](inputs-and-outputs.md) links to generated property and field reference pages.
- [ULP Reference](reference.md) lists current ULP commands and options.
- [Optional local web interface](user-interface.md#work-in-the-browser) covers HTTPS, authentication, permission modes, Shell, AI Chat, and the result grid.
