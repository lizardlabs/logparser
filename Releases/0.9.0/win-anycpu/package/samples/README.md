# Universal Log Parser samples

The sample data is fictional and the SQL is read-only apart from connection-local `TEMP` objects. Run these commands from the `PortableLogParser` project directory so relative data paths resolve consistently.

The primary `parsingmodule` recipes explicitly create Universal Log Parser virtual tables:

```powershell
ulp --query-file samples\parsingmodule\01-evt-system.sql --output Console
ulp --query-file samples\parsingmodule\03-textline-errors.sql --output console --format JSON
ulp --query-file samples\parsingmodule\04-csv-aggregation.sql --output Console
ulp --query-file samples\parsingmodule\05-csv-join-and-window.sql --output Console
```

The first example is equivalent to:

```sql
DROP TABLE IF EXISTS [logs];
CREATE VIRTUAL TABLE [logs] USING ParsingModule('System', '-i:EVT');
SELECT * FROM [logs] ORDER BY [TimeCreated] DESC LIMIT 1000;
```

The additional `sql` recipes operate on virtual tables created by CLI source blocks. Run them in deterministic filename order; the first file materializes the streaming tables so SQLite can safely rescan them for joins and windows:

```powershell
ulp --input CSV --table employees --from samples\data\employees.csv `
    --input CSV --table departments --from samples\data\departments.csv `
    --query-file "samples\sql\*.sql" --output Console --verbose
```

Read a plain-text application log:

```powershell
ulp --input TextLine --from samples\data\application.log `
    --select "RecordNumber, Text" --where "Text LIKE '%ERROR%'" --limit 20
```

Use a result as a batch gate without printing it:

```powershell
ulp --query "SELECT COUNT(*) FROM sqlite_master" --output None `
    --expect-scalar 0 --stats
```

Create a file only when rows exist, then run an explicit program:

```powershell
ulp --input CSV --table employees --from samples\data\employees.csv `
    --query "SELECT * FROM employees WHERE lower(active)='true'" `
    --output file --format JSON --output-file active.json --no-output-if-empty `
    --after notify.exe --after-arg active.json --after-when file
```

Post-actions are never passed to an implicit command shell. To run a script, specify its interpreter explicitly, for example `--after pwsh --after-arg=-File --after-arg script.ps1`.

Run the harmless context-display action included in this directory:

```powershell
ulp --query "SELECT 7" --output None `
    --after powershell.exe `
    --after-arg=-NoProfile `
    --after-arg=-ExecutionPolicy --after-arg Bypass `
    --after-arg=-File --after-arg samples\actions\show-context.ps1
```

Use `--after-arg=<value>` when an argument begins with `-`, so it cannot be mistaken for a ULP option.
