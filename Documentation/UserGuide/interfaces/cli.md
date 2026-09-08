# Command line

Use the CLI for one-off analysis, scripts, pipelines, and coding agents. It prints help when started without an action; it does not open a menu unexpectedly.

```powershell
ulp --help
ulp --query "SELECT 42 AS answer" --format TextTable
ulp --input TextLine --from samples/data/application.log --table logs --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%'" --format JSON
```

Choose `--format` for representation and `--output file --output-file report.csv` for a file destination. Keep status and result data separate when piping to another program. Ctrl+C is the normal way to cancel a running CLI query.

<!-- Screenshot placeholder: terminal showing one command and its result. -->

Start with the [use-case tutorials](../tutorials.md). Look up [commands and configuration](../reference.md), [all switches](../reference/generated/cli-reference.md), and [formats](../inputs-and-outputs.md).
