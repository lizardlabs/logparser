# ULP Query library

ULP discovers `*.sql` files recursively. Folders are categories in the interactive Query library; filenames and folder depth are otherwise unrestricted.

The optional header below makes a query available as a short CLI command:

```sql
-- title: Directory listing
-- description: List files like dir.
-- command: dir
-- provider: FileSystem
-- source: .\*
-- table: dir_files
-- input-options: -Recurse:0 -IncludeAllFiles:ON
-- default-format: Terminal
-- default-destination: console
-- parameter: extension=
SELECT * FROM dir_files WHERE :extension = '';
```

Run it with `ulp -c.dir`. Use `--from "C:\logs\*"` to override the source and `--param extension=.log` (or `--p.extension .log`) to bind a SQLite parameter. Explicit output options override the query defaults.

Metadata is read only from leading SQL comments. SQL parameters are bound natively; ULP never performs query-text replacement.

Bundled short commands include file reports (`dir`), system snapshots (`ps`, `threads`), arbitrary text ranges (`text-lines`), and structured source/document exploration across registered C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown readers. Code recipes cover symbols, structured fields, exact text/context, comments, calls, imports, inheritance, documentation, diagnostics, behavior hints, public APIs, duplicate bodies, inventory, and complexity hotspots. Browse them in the interactive Query library or inspect the leading metadata in these SQL files; every recipe's source, parameters, output format, and destination can be overridden from the command line.
