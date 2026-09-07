# Optional session initialization SQL

These files create reviewable, connection-local virtual tables through ULP's existing SQL lifecycle. Nothing in this directory runs automatically.

Load one or more files explicitly:

```powershell
ulp --session-init-file session-sql\numbers.sql --query "SELECT * FROM tNumber1 LIMIT 10"
ulp --session-init-file session-sql\current-files.sql --query "SELECT Path, Size FROM tFile1 LIMIT 20"
```

The supplied names follow the same provider-aware convention as unnamed CLI sources:

| File | Tables |
| --- | --- |
| `numbers.sql` | `tNumber1` |
| `calendar.sql` | `tDate1` |
| `current-files.sql` | `tFile1` |
| `event-logs.sql` | `tEvt1` (System) and `tEvt2` (Application) |

Each example drops only its own temporary table before recreating it, so loading the same file twice does not create duplicates. ULP creates no optional tables when Session initialization is empty. Explicit names in your own SQL remain supported and are often clearer for durable queries.

`event-logs.sql` may inspect large Windows event channels. `current-files.sql` uses the process working directory. Read and edit each file before using it in unattended jobs. A syntax or provider error in Session initialization stops the session and is reported as a Session initialization failure.
