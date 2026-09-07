# Repository and text-search workflows

## Route by evidence needed

| Need | Best route | Why |
| --- | --- | --- |
| Fast literal or RegEx match | `ulp search` | Streams files/stdin without SQLite |
| Before/after context | `ulp search --context N` | Emits match and context rows with locations |
| Exact arbitrary text range | `ulp -c.text-lines` | Filters `TextLine` rows by inclusive line number |
| Exact supported-code range | `ulp -c.code-context` | Uses stable `SourcePath` and 1-based source spans |
| Search only comment rows | `ulp -c.code-comments` | Parses comments separately where supported |
| Search identifiers/signatures without comment rows | `ulp -c.code-structure` | Searches structured metadata rather than raw lines |
| Declarations, calls, types, APIs, diagnostics | `ulp-code-intelligence` | Uses the full `SourceCode` schema |

Direct search does not parse programming-language comments. Do not claim that it ignored comments. For a comment-only search, use `code-comments`. For a comment-independent symbol/type/call search, use `code-structure`. Arbitrary raw source text with comments removed is not currently a supported transformation.

## Direct streaming search

```powershell
ulp search timeout .\logs --ignore-case --include "*.log" --context 3 --limit 100
ulp search --regex "catch\s*\(" .\src --recursive --include "*.cs" --exclude "bin/**" --exclude "obj/**" --format jsonl --limit 250
Get-Content .\build.log | ulp search error --stdin --ignore-case --context 2
```

Use `--before-context N` or `--after-context N` when the context is asymmetric. Use `--require-match` for a CI condition and `--quiet-match` when only the exit status matters. Prefer JSONL for streaming agent consumption; ordinary text is easiest for a human.

## Exact line ranges

Arbitrary text:

```powershell
ulp -c.text-lines --from .\server.log --p.start_line 400 --p.end_line 460 --format JSON
```

Supported source/document input:

```powershell
ulp -c.code-context --from .\src\Worker.cs --p.start_line 75 --p.end_line 120 --format JSON
```

For several source files, add `--p.path Worker.cs` to narrow the returned path. Both recipes use inclusive 1-based line numbers and cap returned rows.

## Sources and exclusions

`ulp search` accepts files, directories, and stdin. Input providers also accept lazy glob sources, semicolon/comma-separated sources, negative patterns prefixed by `!`, and archive entry patterns such as `logs.zip|*.log`. Quote shell wildcards so ULP, not the shell, expands them.

Keep common generated/dependency trees excluded during code searches: `bin`, `obj`, `.git`, `.vs`, `node_modules`, and `packages`. The `SourceCode` provider excludes these path segments by default.

## Evidence discipline

- A text match proves only that the returned text occurred at that location.
- Context rows are nearby evidence, not additional matches.
- RegEx results depend on the supplied expression; report it when interpretation matters.
- A truncated/limited result is not an exhaustive repository claim.
- If a file could not be read or was classified as binary, report that limitation from the search summary.
