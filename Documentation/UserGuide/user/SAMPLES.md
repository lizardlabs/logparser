# ParsingModule SQL and automation samples

The primary examples under `samples/parsingmodule` show the feature that makes ULP different from a generic SQLite shell: logs, event channels, CSV, text, URLs, and other providers become SQLite virtual tables.

## Installed Query library

Choose **QUERY · Query library** directly from the top-level interactive menu. ULP discovers external `*.sql` files recursively, and subfolders become browsable categories, so the library can be reviewed, reorganized, edited, or replaced without rebuilding the application. The supplied recipes cover recent Windows errors and warnings, current-directory and recursive file inventories, extension percentiles, largest files, direct and cumulative folder sizes, folder depth, file age, SHA-256 duplicate candidates, recursive text previews, a multi-result disk report, a 30-day calendar, and generated-number window functions. They demonstrate virtual tables, temporary materialization, insertion, aggregation, percentiles, recursive CTEs, hashing, and window functions.

The default directory is `queries` beside `ulp.exe`. Override it with `--queries-dir <directory>`, `ULP_QUERIES_DIR`, or **Options → Choose Query library directory**. Every interactively selected query still uses the common preview/edit/copy/execute workflow before it runs.

```powershell
ulp --query-file "queries\Generated Data\number-window-report.sql" --output console --format Terminal
ulp --query-file queries\Files\Recursive\folder-subtree-sizes.sql --output console --format Terminal
ulp -c.dir
ulp -c.dir --from "C:\logs\*" --p.extension .log --format JSON
```

File recipes keep byte columns for correct numeric sorting and add `HUMANIZE_BYTES` columns for display. Recursive recipes use `FileSystem -Recurse:-1` and bounded output. The duplicate candidate recipe first narrows by equal size and hashes at most 500 candidates because SHA-256 reads file contents. Run expensive recursive recipes from the directory you intend to inspect.

## Windows System event log

```sql
-- Initialize
DROP TABLE IF EXISTS [logs];
CREATE VIRTUAL TABLE [logs]
USING ParsingModule('System', '-i:EVT');

-- TABLE: Windows System Events
SELECT * FROM [logs]
ORDER BY [TimeCreated] DESC
LIMIT 1000;
```

Run the checked-in form with `ulp --query-file samples\parsingmodule\01-evt-system.sql`.

## Equivalent command-line table construction

```powershell
ulp --input EVT --table logs --from System `
    --input.Direction BACKWARD `
    --query.Select "TimeCreated, EventTypeName, SourceName, Message" `
    --query.FilterLevel "Warning, Error" `
    --query.FilterDate Last24Hours `
    --query.OrderBy "TimeCreated DESC" --query.Limit 200
```

An explicit `--query` or `--query-file` takes precedence when full SQL is needed.

## Parse and aggregate CSV directly

```sql
CREATE VIRTUAL TABLE [employees]
USING ParsingModule('samples\data\employees.csv', '-i:CSV');

SELECT CAST([department_id] AS INTEGER) AS [DepartmentId],
       COUNT(*) AS [Employees],
       AVG(CAST([salary] AS REAL)) AS [AverageSalary]
FROM [employees]
GROUP BY CAST([department_id] AS INTEGER);
```

## Join and window over parser sources

ParsingModule tables are forward-only streams. For joins, repeated scans, and window plans, materialize each stream into a connection-local `TEMP` table first. `samples\parsingmodule\05-csv-join-and-window.sql` demonstrates two modules, temporary materialization, a join, and `DENSE_RANK()`.

```powershell
ulp --query-file samples\parsingmodule\05-csv-join-and-window.sql `
    --output console --format Terminal --verbose
```

The additional `samples/sql` recipes perform aggregates, recursive CTEs, JSON, views, query plans, ranking, and running totals over tables that the CLI created with ParsingModule.

## Text, TSV, regular-expression, and generated-number sources

The checked-in samples are concise, executable starting points:

- `03-textline-errors.sql` reads ordinary text with `-i:TextLine`, projects text fields, filters errors, sorts, and limits output.
- `07-tsv-filter.sql` reads a header-bearing tab-separated file with `-i:TSV` and filters HTTP-style status values.
- `08-regex.sql` uses `-i:RegEx` with named capture groups to create `Date`, `Level`, and `Message` fields.
- `09-numbers.sql` uses `-i:Numbers` without an input file, then projects and filters generated numeric fields.
- `01-evt-system.sql` and `02-evt-error-summary.sql` demonstrate Windows Event Log (`EVT`).
- `04-csv-aggregation.sql` and `05-csv-join-and-window.sql` demonstrate CSV, aggregation, joins, and windows.

```sql
CREATE VIRTUAL TABLE numbers
USING ParsingModule('', '-i:Numbers -From:1 -To:100');
SELECT Number, Hex FROM numbers WHERE IsEven = 1 LIMIT 20;
```

## Batch gate and conditional file

```powershell
ulp --input EVT --table logs --from System `
    --query "SELECT * FROM logs WHERE EventTypeName='Error' LIMIT 100" `
    --output file --format JSON --output-file errors.json --no-output-if-empty `
    --after notify.exe --after-arg errors.json --after-when file
```

Post-actions are opt-in and are started directly, not through an implicit shell. Use an explicit interpreter executable when the action is a script.
