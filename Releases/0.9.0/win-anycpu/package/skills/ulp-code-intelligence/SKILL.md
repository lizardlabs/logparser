---
name: ulp-code-intelligence
description: Analyze or materialize C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown with ULP's SourceCode input. Apply when a coding agent needs repeatable codebase queries over symbols, exact spans, calls, imports, inheritance, public APIs, documentation, diagnostics, complexity, behavior hints, comments, duplicates, or document structure without executing the repository.
---

# ULP code intelligence

Use ULP as a bounded structural-evidence tool before reading many files manually. Choose the least expensive mode that answers the task:

- use a bundled `code-*` command for one focused question;
- materialize a temporary table inside one query script when several reports need the same scan;
- ingest the codebase into a task-local SQLite database when an agent will ask many follow-up questions or correlate multiple source roots.

```powershell
ulp -c.code-symbol --from .\src\* --p.name QueryRunner --format JSON
ulp -c.code-calls --from .\src\* --p.method Execute --format JSON
ulp -c.code-behavior --from .\src\* --p.behavior http --format JSON
ulp -c.code-context --from .\src\QueryRunner.cs --p.start_line 80 --p.end_line 150
```

For a reusable code index:

```powershell
ulp ingest '.\src\*' --parser SourceCode --db .\code-index.sqlite --table code_rows `
  --input.Recurse -1 --input.IncludeComments ON --input.IncludeDiagnostics ON `
  --index SourcePath,StartLine --index Kind,Name
ulp --database .\code-index.sqlite --query "SELECT Kind, FullName, SourcePath, StartLine, EndLine FROM code_rows WHERE Name=@name LIMIT 50" --param name=QueryRunner --format JSON
```

Do not silently leave an index in the user's repository. Prefer a task-specific temporary path, report any database you create, use `--replace` for a deliberate full refresh, and remove only an index created solely for the current task when normal permissions allow it.

Default repository scans exclude common build, dependency, and VCS folders. Still set a narrow `--from`, file limit, or language/kind filter whenever possible. Treat `SourcePath`, one-based `StartLine`/`EndLine`, and returned `FullRecord` as inspectable evidence. Treat calls, used types, complexity, statement counts, and `Has*` values as parser hints—not compiler binding, runtime behavior, reachability, or security findings.

Read only the reference needed for the task:

- [references/query-recipes.md](references/query-recipes.md) for command selection and copy-ready workflows.
- [references/materialized-codebase.md](references/materialized-codebase.md) before creating a temporary or persistent code index, choosing indexes, refreshing snapshots, or running repeated analysis.
- [references/source-code-schema.md](references/source-code-schema.md) when choosing fields, row kinds, languages, filters, or interpreting confidence.

ULP does not build a compiler semantic model, restore packages, execute code, or prove that a call target resolves to a particular overload. Materialization makes repeated SQL faster; it does not make heuristic fields more authoritative. Retrieve the smallest exact source span needed to verify each conclusion, and report parser diagnostics or unsupported languages instead of upgrading hints into facts.
