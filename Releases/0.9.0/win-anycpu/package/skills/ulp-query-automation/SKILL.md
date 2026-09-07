---
name: ulp-query-automation
description: Build reliable Universal Log Parser commands using saved SQL recipes, parameters, lifecycle SQL, conditions, and one or more output files. Apply to scripts and CI-style checks; do not schedule, publish, or overwrite artifacts without authorization.
---

# ULP query automation

Prefer checked-in Query library recipes for repeated work. Inspect the SQL and metadata before execution, pass values through native named parameters, and use explicit output and condition options.

```powershell
ulp -c.errors --param minimum_level=3 --output file --format JSON --output-file reports\errors.json --require-rows
ulp --query-file queries\daily.sql --output file --format CSV --output-file reports\daily.csv --also-pipeline Excel=reports\daily.xlsx --no-overwrite
ulp --session-init-file session-sql\numbers.sql --query "SELECT COUNT(*) FROM tNumber1" --output none --expect-scalar 10000
```

Use `--no-env` for a hermetic run when inherited ULP settings are not intended. Use `--no-output-if-empty` when an empty query must leave an existing artifact untouched. Keep `--after` actions explicit and review their executable, arguments, trigger, and timeout.

Never place passwords or API keys directly in commands or committed configuration. Use supported secret references. Do not enable network inputs, delete Query library files, overwrite outputs, publish releases, or change scheduled jobs unless the user explicitly requests that action.
