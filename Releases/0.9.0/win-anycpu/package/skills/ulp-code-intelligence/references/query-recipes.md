# Code-intelligence query recipes

Use these recipes to reduce broad file reading to a small set of inspectable source spans. Start with the bundled command that most closely matches the question. Materialize the source only when repeated scans would cost more than creating an index.

## Choose a workflow

| Question | Start with | Follow with |
| --- | --- | --- |
| Where is a symbol declared? | `code-symbol` | `code-context` for the returned span |
| Where is a name used in actual source text? | `code-find` | `code-context`; remember that raw lines include comments |
| Which declarations mention a type or concept? | `code-structure` | inspect `Kind`, `FullName`, and `FullRecord` |
| Which members appear to call a method? | `code-calls` | verify each returned body; calls are name hints |
| What implements or derives from a type? | `code-inheritance` | inspect declarations and project context |
| What is the public surface? | `code-public-api` | compare signatures and documentation |
| Which members deserve review first? | `code-hotspots` or `code-behavior` | inspect exact bodies; do not report hints as defects |
| Are there parser/syntax problems? | `code-diagnostics` | open the exact source line and, when needed, run the real build |
| Is code duplicated? | `code-duplicates` | compare returned bodies and context before proposing consolidation |
| Will I ask many questions of the same tree? | SourceCode `ingest` | read `materialized-codebase.md` |

## Bundled commands

| Command | Purpose | Parameters |
| --- | --- | --- |
| `code-symbol` | Find declarations by name/full name and optional kind | `name`, `kind` |
| `code-structure` | Search names, signatures, types, calls, and inheritance without comment rows | `text` |
| `code-find` | Search exact source lines | `text` |
| `code-context` | Return an inclusive source line range | `start_line`, `end_line`, `path` |
| `code-comments` | Search ordinary/XML-documentation comment rows | `text` |
| `code-calls` | Find members whose extracted call list contains a name | `method` |
| `code-imports` | Find using/import directives | `name` |
| `code-inheritance` | Find declared base types or interfaces | `type` |
| `code-docs` | Find declaration documentation | `text` |
| `code-diagnostics` | List recoverable syntax/parser diagnostics | `text` |
| `code-behavior` | Find await/throw/yield/LINQ/SQL/HTTP/file hints | `behavior` |
| `code-public-api` | Review public/protected declarations and signatures | `name` |
| `code-duplicates` | Group identical declaration-body hashes | `minimum_lines` |
| `code-inventory` | Count declarations by kind | none |
| `code-hotspots` | Rank methods by complexity/size hints | `minimum_complexity` |

Browse the installed Query library through `ulp --menu`, or inspect the leading comments in the relevant file under `queries\Code` before automating it. Those comments declare the command, provider, source, parameters, and output defaults.

Override a recipe's source with `--from`. Pass values with `--p.name value` or `--param name=value`; ULP binds them as SQLite parameters rather than replacing query text.

## Map an unfamiliar subsystem

Begin with an inventory, then narrow by namespace, type, or feature term:

```powershell
ulp -c.code-inventory --from '.\src\*' --format JSON
ulp -c.code-structure --from '.\src\*' --p.text QueryRunner --format JSON
ulp -c.code-imports --from '.\src\*' --p.name System.Data --format JSON
ulp -c.code-inheritance --from '.\src\*' --p.type IDataReader --format JSON
```

Use the results to form a small candidate set. Read the containing type, key public members, construction paths, and call hints before claiming an architecture. Imports show availability, not actual use; inheritance is declared syntax, not proof that a runtime object takes a particular path.

## Find a definition, then retrieve evidence

```powershell
ulp -c.code-symbol --from '.\src\*' --p.name MultiFileReader --format JSON
ulp -c.code-context --from '.\src\MultiFileReader.vb' --p.start_line 110 --p.end_line 190 --format JSON
```

Use the first result's exact `SourcePath`, `StartLine`, and `EndLine` to choose the second range. Include a small amount of surrounding context for fields, attributes, and callers. Do not fetch every file when one declaration answers the question.

## Plan a change and estimate impact

Find the declaration, its inheritance relationships, call-name hints, and documentation separately:

```powershell
ulp -c.code-symbol --from '.\*' --p.name ExecuteSaved --format JSON
ulp -c.code-calls --from '.\*' --p.method ExecuteSaved --format JSON
ulp -c.code-inheritance --from '.\*' --p.type WebQueryService --format JSON
ulp -c.code-docs --from '.\*' --p.text ExecuteSaved --format JSON
```

The returned call list does not resolve overloads, aliases, reflection, dependency injection, delegates, or dynamic dispatch. Treat it as a candidate list. Confirm real references with exact source search and the language's build/test tools before changing a public contract.

## Search code without confusing comments for code

For an identifier, type, signature, extracted call, or inheritance name, search structured metadata:

```powershell
ulp -c.code-structure --from '.\src\*' --p.text HttpClient --format JSON
```

For comment-only work:

```powershell
ulp -c.code-comments --from '.\src\*' --p.text TODO --format JSON
```

`code-find` searches exact source lines and can match comments, strings, and documentation. ULP does not currently offer arbitrary raw source text with all comments lexically removed. Use structured declarations for comment-independent discovery, then inspect the source.

## Review public APIs and missing documentation

```powershell
ulp -c.code-public-api --from '.\src\*' --p.name Parser --format Markdown
ulp -c.code-docs --from '.\src\*' --p.text cancellation --format JSON
```

For a reusable index, find undocumented public declarations with:

```sql
SELECT Language, Kind, FullName, SourcePath, StartLine, EndLine
FROM code_rows
WHERE Accessibility IN ('Public', 'Protected')
  AND Kind IN ('Class', 'Struct', 'Interface', 'Record', 'Method', 'Property', 'Event')
  AND coalesce(trim(Documentation), '') = ''
ORDER BY SourcePath, StartLine
LIMIT 200;
```

An empty documentation field is meaningful only for languages and row kinds whose reader associates documentation with declarations.

## Trace asynchronous, error, and side-effect clues

```powershell
ulp -c.code-behavior --from '.\src\*' --p.behavior http --format JSON
ulp -c.code-behavior --from '.\src\*' --p.behavior file --format JSON
ulp -c.code-structure --from '.\src\*' --p.text CancellationToken --format JSON
ulp -c.code-hotspots --from '.\src\*' --p.minimum_complexity 8 --format JSON
```

Use this to prioritize review of boundaries such as network requests, file access, SQL construction, exceptions, cancellation, or large branchy methods. `HasHttpCall`, `HasFileAccess`, `HasSqlString`, `HasThrow`, and complexity values are parser hints. They do not prove reachability, vulnerability, missing cancellation, or bad performance.

## Find duplicate declaration bodies

```powershell
ulp -c.code-duplicates --from '.\src\*' --p.minimum_lines 5 --format JSON
```

Hash matches identify identical emitted declaration text. Inspect each location before consolidating: generated code, platform variants, tests, and intentionally duplicated protocol definitions may be valid.

## Inspect syntax and parser diagnostics

```powershell
ulp -c.code-diagnostics --from '.\src\*' --format JSON
```

Diagnostics can expose malformed or partially understood source while allowing other rows to remain queryable. They are not a replacement for restoring and compiling the solution. Report both the diagnostic and the exact source span; distinguish parser limitations from compiler errors.

## Analyze mixed web and source projects

The SourceCode provider can put C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown into one table. Compare language-specific structure without pretending every field is universal:

```sql
SELECT Language, Kind, count(*) AS Rows
FROM code_rows
GROUP BY Language, Kind
ORDER BY Language, Rows DESC, Kind;
```

Useful correlations include Razor component names with C# backing types, HTML/JavaScript identifiers with server endpoints, Markdown command examples with CLI symbols, and TypeScript calls with C# route names. These remain name/text correlations; verify the actual binding and runtime route.

## Custom live SQL when a recipe is not enough

```powershell
ulp --input SourceCode --table code_rows --from '.\src\*' `
  --input.Recurse -1 --input.IncludeComments OFF --input.IncludeDiagnostics OFF `
  --input.MaximumFiles 5000 --input.MaximumRowsPerFile 10000 `
  --query "SELECT Kind, FullName, SourcePath, StartLine, EndLine FROM code_rows WHERE IsAsync='True' AND Accessibility='Public' ORDER BY SourcePath, StartLine LIMIT 200" `
  --output console --format JSON --no-pager
```

Keep a `LIMIT`, select only useful fields, and use named `--param` values for user-provided filters. If several queries will rescan the same tree, switch to the materialized workflow rather than repeatedly reparsing every file.

## Evidence checklist

Before presenting a conclusion or editing code:

1. retain the exact `SourcePath` and one-based span;
2. inspect `FullRecord` or retrieve a bounded line range;
3. distinguish parsed declarations from raw text matches;
4. distinguish syntax hints from semantic/runtime facts;
5. note excluded directories, file/language/kind filters, limits, and diagnostics;
6. use the project's compiler/tests when the conclusion depends on binding or behavior.
