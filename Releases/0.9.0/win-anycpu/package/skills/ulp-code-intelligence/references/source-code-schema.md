# SourceCode evidence schema

The `SourceCode` provider emits a common row model across C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown. A field may be empty when it is not meaningful for a language or row kind.

## Identity and location

| Fields | Meaning |
| --- | --- |
| `Language` | Selected language reader (`CSharp`, `VisualBasic`, `Razor`, `Html`, `JavaScript`, `TypeScript`, `Markdown`) |
| `SourceId`, `ProjectPath` | Optional caller-supplied source/project identity |
| `SourcePath` | Source file path |
| `StartLine`, `EndLine`, `Column` | One-based source span reported by the reader |
| `SymbolId` | Reader-generated structural identity within a source |
| `Hash` | Hash of the exact source text represented by the row |
| `FullRecord` | Exact source lines covered by the row when enabled |

## Declaration and document structure

| Fields | Meaning |
| --- | --- |
| `Kind` | Language/document row category |
| `Name`, `ParentName`, `FullName`, `Namespace` | Parsed names and hierarchy |
| `Modifiers`, `Accessibility`, `Attributes` | Declaration syntax when available |
| `DataType`, `ReturnType`, `Parameters` | Parsed type/signature text |
| `BaseType`, `Interfaces` | Declared inheritance/interface text |
| `GenericArguments`, `GenericConstraints` | Generic syntax |
| `Documentation`, `Comments` | Documentation or associated comment text |

Representative kinds include `Namespace`, `Class`, `Struct`, `Interface`, `Record`, `Enum`, `Delegate`, `Method`, `Property`, `Field`, `Event`, `Using`, `Import`, `Comment`, `XmlDocTrivia`, `Diagnostic`, and `SourceLine`. Document readers also emit structural kinds such as Razor `Directive`/`Component`/`Expression`/`CodeBlock`, HTML `Element`/`Attribute`/`TemplateExpression`/`StyleBlock`/`ScriptBlock`, TypeScript `TypeAlias`, and Markdown `Heading`/`Paragraph`/`Link`/`Image`/`ListItem`/`Table`/`CodeFence`/`FrontMatter`.

Kinds vary by language and syntax. Discover them for the actual source instead of assuming every reader emits every kind:

```sql
SELECT Language, Kind, count(*) AS Rows
FROM code_rows
GROUP BY Language, Kind
ORDER BY Language, Rows DESC, Kind;
```

## Syntax flags

The following are string-valued `True`/`False` fields in SQLite results:

`IsStatic`, `IsAsync`, `IsVirtual`, `IsOverride`, `IsAbstract`, `IsSealed`, `IsPartial`, `IsGeneric`, `IsNullable`, `IsObsolete`, `IsExtensionMethod`, `IsConstructor`, `IsPrimaryConstructor`, `IsRecord`, `IsInitOnly`, `IsRequired`, `HasGetter`, and `HasSetter`.

These normally reflect parsed syntax, not runtime reflection or whole-solution semantic binding.

## Extracted behavior and metrics

| Fields | Interpretation |
| --- | --- |
| `CalledMethods` | Extracted called-method/name list; not overload or target resolution |
| `UsedTypes` | Extracted type-name clues; not a complete dependency graph |
| `ParameterCount`, `AttributeCount` | Parsed counts for the represented row |
| `StatementCount` | Reader estimate/count useful for comparison |
| `CyclomaticHint` | Branch-oriented ranking hint, not a formal complexity guarantee |
| `HasAwait`, `HasThrow`, `HasYield`, `HasLinq` | Syntax/pattern hints |
| `HasSqlString`, `HasHttpCall`, `HasFileAccess` | Pattern-based side-effect clues for triage |

Never present these fields alone as proof of a vulnerability, actual I/O, a reachable call path, or runtime behavior. Retrieve `FullRecord`/source context and inspect it.

## Diagnostics

With `IncludeDiagnostics:ON`, recoverable parser findings appear as `Kind='Diagnostic'`. `Name` is the reader's diagnostic identifier, `Documentation` is its message, and the source span/evidence identify the location. These are syntax/parser diagnostics; ULP does not perform a full project build or semantic compilation.

## Source lines and comment handling

Set `IncludeSourceLines:ON` and `IncludedKinds:SourceLine` for one row per physical source line. Search `FullRecord` for exact grep-like evidence. This raw line mode includes comment text.

Set `IncludeComments:ON` with `IncludedKinds:Comment` to select ordinary parsed comment rows. Add `IncludeXmlDocumentationTrivia:ON` and `XmlDocTrivia` for separate XML-doc trivia. Declaration `Documentation` can be populated even when separate XML trivia rows are disabled.

## Provider bounds and filters

| Option | Use |
| --- | --- |
| `IncludedLanguages` | Parse only selected registered languages |
| `IncludedKinds` | Return only selected row kinds |
| `FileNamePattern` | Prefilter filenames |
| `FileContainsText` | Fast file-content prefilter before parsing |
| `Recurse` | `0` current folder, `-1` unlimited depth |
| `ExcludedPathSegments` | Skip named directory segments |
| `IncludeGeneratedFiles` | Opt into generated source |
| `MaximumFiles` | Bound file count |
| `MaximumFileSizeBytes` | Bound individual file size |
| `MaximumRowsPerFile` | Bound emitted rows per file |

Repository-wide defaults exclude `bin`, `obj`, `.git`, `.vs`, `node_modules`, and `packages`, skip generated files, cap an individual file at 16 MiB, and leave file/row counts otherwise configurable. Skills and bundled recipes apply explicit file/row limits so agent requests remain bounded.
