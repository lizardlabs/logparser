---
name: ulp-repository-search
description: Search local repositories with ULP using streaming literal or RegEx matching, bounded context, arbitrary text line ranges, file globs, exclusions, and structured source evidence. Apply when locating phrases or narrow file context; use deeper code intelligence for symbols, calls, APIs, diagnostics, or behavior analysis.
---

# ULP repository search

Use the cheapest ULP route that preserves the evidence the task needs:

1. Start with `ulp search` for literal/RegEx discovery. It streams without creating SQLite tables.
2. Use `ulp -c.text-lines` when the user requests an exact inclusive range from arbitrary text.
3. Use `ulp -c.code-context` for exact ranges in supported source/document files.
4. Switch to the `ulp-code-intelligence` skill or a structured `code-*` query when comments, symbols, calls, imports, types, or diagnostics must be distinguished.

Always bound repository-wide work with includes/excludes and a result limit. Preserve paths, 1-based line numbers, and match/context markers in the answer. Expand only around relevant hits.

```powershell
ulp search "retry policy" . --recursive --include "*.cs" --exclude "bin/**" --exclude "obj/**" --context 2 --limit 50
ulp search --regex "TODO|FIXME" . --recursive --include "*.cs" --include "*.vb" --include "*.ts" --format jsonl --limit 200
ulp -c.text-lines --from .\notes.txt --p.start_line 40 --p.end_line 65
ulp -c.code-context --from .\src\Parser.cs --p.start_line 120 --p.end_line 175
```

Read [references/text-search.md](references/text-search.md) when choosing between direct search, `TextLine`, and `SourceCode`, or when handling comments, stdin, archives, exclusions, machine-readable output, or large repositories.

Search is read-only. Do not execute discovered scripts or modify files unless the user separately requests that work.
