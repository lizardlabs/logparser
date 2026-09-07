---
name: ulp-code-intelligence
description: Analyze C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown with ULP's SourceCode input and saved code queries. Apply when a coding agent needs symbols, exact spans, calls, imports, inheritance, public APIs, documentation, diagnostics, complexity, behavior hints, comments, or document structure without executing the repository.
---

# ULP code intelligence

Use ULP as a bounded, read-only structural evidence tool. Prefer a bundled `code-*` query, then inspect exact source context before making a conclusion or edit.

```powershell
ulp -c.code-symbol --from .\src\* --p.name QueryRunner --format JSON
ulp -c.code-calls --from .\src\* --p.method Execute --format JSON
ulp -c.code-behavior --from .\src\* --p.behavior http --format JSON
ulp -c.code-context --from .\src\QueryRunner.cs --p.start_line 80 --p.end_line 150
```

Default repository scans exclude common build, dependency, and VCS folders. Still set a narrow `--from` whenever possible. Treat `StartLine`/`EndLine` and returned source as evidence. Treat calls, used types, complexity, statement counts, and `Has*` values as parser hints—not compiler binding, runtime behavior, or security findings.

Read only the reference needed for the task:

- [references/query-recipes.md](references/query-recipes.md) for command selection and copy-ready workflows.
- [references/source-code-schema.md](references/source-code-schema.md) when choosing fields, row kinds, languages, filters, or interpreting confidence.

ULP does not build a cross-project semantic index, execute code, or prove that a call target resolves to a particular overload. Report parser diagnostics and limitations rather than upgrading hints into facts.
