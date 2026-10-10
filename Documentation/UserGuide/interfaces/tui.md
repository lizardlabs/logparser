# Full-screen terminal editor

The TUI combines a SQL editor and table viewer in a terminal window. Start it directly:

```powershell
ulp --tui
ulp --tui --query "SELECT 42 AS answer"
ulp --tui --query-file samples/parsingmodule/05-csv-join-and-window.sql
ulp --tui --command dir --from samples/data
```

Preloaded SQL is displayed for review; it is not run merely by opening the editor. Select **Run** or press **F2** to execute it, and press **F5** to run it again. Use **File > Open Query** (**Ctrl+O**), **Save Query** (**Ctrl+S**), or **Save Query As** to work with SQL files. The result title identifies the active table, result number, row and column counts, and query file. Use **Edit > Copy Selection** or **Ctrl+C** to copy selected cells as tab-separated text. Press **F1** for the built-in keyboard and navigation guide. Errors remain available in the editor so you can correct the query.

Run this in an interactive terminal with no input/output redirection. Use the CLI for automation and pipelines. `--tui` cannot be combined with another interface selector such as `--shell` or `--web`.

<!-- Screenshot placeholder: full-screen SQL editor above a result table. -->

See [all TUI workflows](../user-interface.md) and [SQL examples](../tutorials.md).
