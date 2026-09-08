# Full-screen terminal editor

The TUI combines a SQL editor and table viewer in a terminal window. Start it directly:

```powershell
ulp --tui
ulp --tui --query "SELECT 42 AS answer"
ulp --tui --query-file samples/parsingmodule/05-csv-join-and-window.sql
ulp --tui --command dir --from samples/data
```

Preloaded SQL is displayed for review; it is not run merely by opening the editor. Select **Run** to execute it. Use **File > Open Query**, **Save Query**, or **Save Query As** to work with SQL files. Errors remain available in the editor so you can correct the query.

Run this in an interactive terminal with no input/output redirection. Use the CLI for automation and pipelines. `--tui` cannot be combined with another interface selector such as `--shell` or `--web`.

<!-- Screenshot placeholder: full-screen SQL editor above a result table. -->

See [all TUI workflows](../user-interface.md) and [SQL examples](../tutorials.md).
