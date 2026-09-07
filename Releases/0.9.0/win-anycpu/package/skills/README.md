# Optional AI-agent skills

These folders contain reusable instructions that teach compatible coding and AI agents to operate ULP through its documented public CLI. They are not executable plugins, do not enable AI inside ULP, and do not grant an agent permission to read files, contact services, or change data.

## Included skills

| Skill | Use case |
| --- | --- |
| `ulp-repository-search` | Streaming text/RegEx search, exact context, line ranges, globs, and exclusions. |
| `ulp-code-intelligence` | Live or materialized SourceCode analysis: symbols, calls, imports, APIs, diagnostics, metrics, behavior hints, duplicates, exact spans, and document structure. |
| `ulp-data-investigation` | Inspect supported data sources and build reviewable SQLite queries. |
| `ulp-query-automation` | Run saved recipes, parameters, lifecycle SQL, conditions, and output pipelines safely. |

For Codex, copy the desired complete skill folder into the user or project skill directory supported by your installation, then restart or refresh skill discovery. Other agents can use the `SKILL.md` as project instructions when they support compatible Markdown skill packages.

Keep the folder intact and review its instructions before enabling it. The examples assume `ulp` is on `PATH`; use the full path to `ulp.exe` otherwise.
