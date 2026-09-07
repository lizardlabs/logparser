# Code-intelligence query recipes

## Bundled commands

| Command | Purpose | Parameters |
| --- | --- | --- |
| `code-symbol` | Find declarations by name/full name and optional kind | `name`, `kind` |
| `code-structure` | Search names, signatures, types, calls, and inheritance without comment rows | `text` |
| `code-find` | Grep exact source lines | `text` |
| `code-context` | Return an inclusive source line range | `start_line`, `end_line`, `path` |
| `code-comments` | Search ordinary/XML-documentation comment rows | `text` |
| `code-calls` | Find members whose extracted call list contains a name | `method` |
| `code-imports` | Find using/import directives | `name` |
| `code-inheritance` | Find base types or interfaces | `type` |
| `code-docs` | Find declaration documentation | `text` |
| `code-diagnostics` | List recoverable syntax/parser diagnostics | `text` |
| `code-behavior` | Find await/throw/yield/LINQ/SQL/HTTP/file hints | `behavior` |
| `code-public-api` | Review public/protected declarations and signatures | `name` |
| `code-duplicates` | Group identical declaration-body hashes | `minimum_lines` |
| `code-inventory` | Count declarations by kind | none |
| `code-hotspots` | Rank methods by complexity/size hints | `minimum_complexity` |

Browse the installed Query library through `ulp --menu`, or inspect the leading comments in the relevant file under the installed `queries\Code` directory before automating it. Those comments declare the command, provider, source, parameters, and output defaults.

Override a recipe's default source with `--from`. Pass parameters with `--p.name value` or `--param name=value`; ULP binds them as SQLite parameters rather than replacing query text.

## Find a definition, then retrieve evidence

```powershell
ulp -c.code-symbol --from .\src\* --p.name MultiFileReader --format JSON
ulp -c.code-context --from .\src\MultiFileReader.vb --p.start_line 110 --p.end_line 190 --format JSON
```

Use the first result's exact `SourcePath`, `StartLine`, and `EndLine` to choose the second range. Do not fetch every file when one declaration answers the question.

## Search code without confusing comments for code

For an identifier, type, signature, extracted call, or inheritance name, search structured metadata:

```powershell
ulp -c.code-structure --from .\src\* --p.text HttpClient --format JSON
```

For comment-only work:

```powershell
ulp -c.code-comments --from .\src\* --p.text TODO --format JSON
```

`code-find` searches exact source lines and therefore can match comments. ULP does not currently provide arbitrary raw source text with comments lexically removed.

## Architecture and dependency clues

```powershell
ulp -c.code-imports --from .\src\* --p.name System.Data --format JSON
ulp -c.code-inheritance --from .\src\* --p.type IDisposable --format JSON
ulp -c.code-calls --from .\src\* --p.method ExecuteReader --format JSON
```

Imports and declared base/interface names are syntax-derived. `CalledMethods` is an extracted name list and does not resolve overloads or dynamic dispatch.

## API and documentation review

```powershell
ulp -c.code-public-api --from .\src\* --p.name Parser --format Markdown
ulp -c.code-docs --from .\src\* --p.text cancellation --format JSON
```

Use missing/empty documentation as review evidence only when the language reader exposes declaration documentation for that row kind.

## Risk-oriented triage

```powershell
ulp -c.code-behavior --from .\src\* --p.behavior file --format JSON
ulp -c.code-hotspots --from .\src\* --p.minimum_complexity 8 --format JSON
ulp -c.code-diagnostics --from .\src\* --format JSON
```

These commands prioritize code for inspection. They are not security, correctness, or performance verdicts. Open the returned span and verify the implementation.

## Custom SQL when a recipe is not enough

```powershell
ulp --input SourceCode --table code_rows --from .\src\* `
  --input.Recurse -1 --input.IncludeComments OFF --input.IncludeDiagnostics OFF `
  --query "SELECT Kind, FullName, SourcePath, StartLine, EndLine FROM code_rows WHERE IsAsync='True' AND Accessibility='Public' ORDER BY SourcePath, StartLine LIMIT 200" `
  --output console --format JSON
```

Keep a `LIMIT`, select only useful fields, and use named `--param` values for user-provided filters. Materialize only when a query must scan the forward-only source repeatedly.
