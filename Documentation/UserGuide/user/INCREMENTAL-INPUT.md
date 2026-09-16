## Incremental Input and Checkpoints

Where supported, set `CheckpointFile` to process appended records after the first successful run:

```powershell
ulp --input TextLine --from "C:\Logs\*.log" --table logs `
    --i.TextLine.CheckpointFile "C:\ULP-State\logs.checkpoint" `
    --query "SELECT Text FROM logs" `
    --output file --format CSV --output-file .\new-records.csv
```

ULP commits staged positions only after query, output, and after-query success. Errors/cancellation keep the previous safe position. New files are read completely; deleted-file entries are removed after a complete scan; truncated/replaced files restart. An early `LIMIT` can intentionally cause safe replay rather than skipped records.

Checkpoints track input positions, not aggregate history. `COUNT(*)` on a checkpointed source counts rows in that execution.

Text inputs also expose `CheckpointCompleteLinesOnly`. When enabled, ULP stops at the last newline and leaves an unfinished final line for the next successful read. `CheckpointStartAtEnd` skips existing complete records when a checkpoint has no saved position. The attached `--tail` command configures both properties automatically with a process-memory checkpoint:

```powershell
ulp --input TextLine --from 'C:\Logs\application.log' --table logs `
    --query "SELECT Text FROM logs WHERE Text LIKE '%ERROR%'" `
    --tail --every 1s
```

Unlike a checkpoint file, a `memory:<name>` checkpoint is shared only inside the current ULP process and disappears at exit. It is intended for live polling, not durable scheduled imports. See [How to follow a growing log](../how-to.md#how-to-follow-a-growing-log).

# Output Formats
