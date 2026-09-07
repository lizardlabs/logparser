# Materialized codebase workflows

Materialization stores SourceCode rows in an ordinary SQLite table so an agent can ask many questions without reparsing the same files for every command. It is useful for repository mapping, repeated impact analysis, cross-language correlations, inventory reports, and before/after comparisons. It is unnecessary overhead for one symbol lookup.

## Choose the storage mode

| Mode | Use when | Lifetime |
| --- | --- | --- |
| Bundled `code-*` command | One focused question | One command |
| Temporary table in a multi-statement query | Several reports can run together | Current ULP process |
| Task-local SQLite analysis database | Many follow-up commands or agents need the same snapshot | Until the explicitly chosen database is removed |
| Retained project analysis database | The user wants a reusable, versioned artifact | User-controlled |

Materialization improves repeated-query speed. It does not add compiler binding, call-graph resolution, reachability, or runtime knowledge.

## Build a task-local code index

Choose a path that will not be committed accidentally. An agent should prefer an operating-system temporary directory or a clearly named ignored workspace cache. Report the selected path to the user.

```powershell
$codeDb = Join-Path ([IO.Path]::GetTempPath()) ('ulp-code-' + [Guid]::NewGuid().ToString('N') + '.sqlite')

ulp ingest '.\src\*' '.\tests\*' `
  --parser SourceCode `
  --db $codeDb `
  --table code_rows `
  --input.Recurse -1 `
  --input.IncludeComments ON `
  --input.IncludeDiagnostics ON `
  --input.IncludeSourceLines OFF `
  --input.MaximumFiles 10000 `
  --input.MaximumRowsPerFile 20000 `
  --index SourcePath,StartLine `
  --index Language,Kind `
  --index Kind,Name `
  --index FullName `
  --index Hash `
  --format json
```

The source expression is evaluated lazily and excludes common `bin`, `obj`, `.git`, `.vs`, `node_modules`, and `packages` segments by default. Add explicit language, filename, size, or content filters for very large repositories. Keep `IncludeSourceLines` off unless line-by-line SQL search is required; declaration `FullRecord` evidence remains enabled by default.

The index operation is transactional. Its summary reports the database, table, provider, rows, schema hash, and run ID. Inspect metadata when reproducibility matters:

```powershell
ulp db info $codeDb --format json --no-migrate
```

## Query the index repeatedly

Run ordinary SQLite queries in later ULP processes:

```powershell
ulp --database $codeDb `
  --query "SELECT Kind, FullName, SourcePath, StartLine, EndLine FROM code_rows WHERE Name=@name ORDER BY SourcePath, StartLine LIMIT 50" `
  --param name=QueryRunner --format JSON --no-pager
```

### Inventory by language and kind

```sql
SELECT Language, Kind, count(*) AS Rows,
       count(DISTINCT SourcePath) AS Files
FROM code_rows
GROUP BY Language, Kind
ORDER BY Language, Rows DESC, Kind;
```

### Ambiguous symbols and overload candidates

```sql
SELECT Language, Kind, Name, FullName, Parameters, ReturnType,
       SourcePath, StartLine, EndLine
FROM code_rows
WHERE Name = @name OR FullName = @name
ORDER BY FullName, Parameters, SourcePath, StartLine
LIMIT 100;
```

### Candidate callers

```sql
SELECT Language, Kind, FullName, CalledMethods,
       SourcePath, StartLine, EndLine
FROM code_rows
WHERE ',' || replace(coalesce(CalledMethods, ''), ' ', '') || ','
      LIKE '%,' || replace(@method, ' ', '') || ',%'
ORDER BY SourcePath, StartLine
LIMIT 200;
```

This is an extracted-name search, not an overload-resolved call graph. Confirm each candidate body.

### Inheritance and interface map

```sql
SELECT Language, Kind, FullName, BaseType, Interfaces,
       SourcePath, StartLine, EndLine
FROM code_rows
WHERE coalesce(BaseType, '') LIKE '%' || @type || '%'
   OR coalesce(Interfaces, '') LIKE '%' || @type || '%'
ORDER BY FullName
LIMIT 200;
```

### Public API and documentation gaps

```sql
SELECT Language, Kind, FullName, Parameters, ReturnType, Documentation,
       SourcePath, StartLine, EndLine
FROM code_rows
WHERE Accessibility IN ('Public', 'Protected')
  AND Kind IN ('Class', 'Struct', 'Interface', 'Record', 'Enum',
               'Delegate', 'Method', 'Property', 'Field', 'Event')
ORDER BY Namespace, FullName, StartLine
LIMIT 500;
```

Add `AND coalesce(trim(Documentation), '') = ''` for documentation-gap candidates.

### Complexity and behavior triage

```sql
SELECT Language, FullName, CyclomaticHint, StatementCount,
       HasAwait, HasThrow, HasSqlString, HasHttpCall, HasFileAccess,
       SourcePath, StartLine, EndLine
FROM code_rows
WHERE Kind IN ('Method', 'Function', 'Constructor')
  AND (CyclomaticHint >= @minimum_complexity
       OR HasSqlString='True' OR HasHttpCall='True' OR HasFileAccess='True')
ORDER BY CyclomaticHint DESC, StatementCount DESC, SourcePath, StartLine
LIMIT 200;
```

These values prioritize inspection; they are not defect or vulnerability findings.

### Duplicate declaration bodies

```sql
SELECT Kind, Hash, count(*) AS Copies,
       min(FullName) AS Example,
       group_concat(SourcePath || ':' || StartLine, '; ') AS Locations
FROM code_rows
WHERE coalesce(Hash, '') <> '' AND EndLine - StartLine + 1 >= @minimum_lines
GROUP BY Kind, Hash
HAVING count(*) > 1
ORDER BY Copies DESC, Kind
LIMIT 100;
```

### Parser diagnostics

```sql
SELECT Language, Name AS Diagnostic, Documentation AS Message,
       SourcePath, StartLine, EndLine, FullRecord
FROM code_rows
WHERE Kind='Diagnostic'
ORDER BY SourcePath, StartLine
LIMIT 200;
```

## Use a temporary table in one process

When several result sets can be produced together, avoid creating a persistent file:

```powershell
ulp --input SourceCode --from '.\src\*' --table source_rows `
  --query "CREATE TEMP TABLE code_index AS SELECT * FROM source_rows;
           CREATE INDEX temp.ix_code_symbol ON code_index(Kind, Name);
           SELECT Language, Kind, count(*) AS Rows FROM code_index GROUP BY Language, Kind;
           SELECT FullName, SourcePath, StartLine, EndLine FROM code_index WHERE CyclomaticHint >= 8 ORDER BY CyclomaticHint DESC LIMIT 100;" `
  --format JSON --no-pager
```

The temporary table exists only for that ULP connection. A later command cannot reopen it.

## Refresh without accumulating stale rows

Use a transactional full replacement when files may have changed, moved, or been deleted:

```powershell
ulp ingest '.\src\*' '.\tests\*' `
  --parser SourceCode --db $codeDb --table code_rows --replace `
  --input.Recurse -1 --input.IncludeComments ON --input.IncludeDiagnostics ON `
  --index SourcePath,StartLine --index Language,Kind --index Kind,Name --index FullName --index Hash
```

Do not append the same source tree merely to refresh it; `--append` preserves existing rows and can create duplicate snapshots. Append is appropriate only when adding a distinct source set with a compatible schema and when `SourcePath` keeps the origins distinguishable.

## Compare two snapshots

For a deliberate before/after comparison, ingest into separate `code_before` and `code_after` tables. Compare stable structural keys plus hashes:

```sql
SELECT a.Kind, a.FullName, a.SourcePath, a.StartLine,
       b.Hash AS BeforeHash, a.Hash AS AfterHash
FROM code_after AS a
LEFT JOIN code_before AS b
  ON b.Language=a.Language AND b.Kind=a.Kind
 AND b.FullName=a.FullName AND b.SourcePath=a.SourcePath
WHERE b.FullName IS NULL OR coalesce(b.Hash, '') <> coalesce(a.Hash, '')
ORDER BY a.SourcePath, a.StartLine;
```

Renames and moved files appear as removals/additions unless another stable key is available. Preserve both tables only when the comparison is part of the requested deliverable.

## Evidence, cost, and cleanup

- Select a small field set and use `LIMIT` during exploration.
- Return exact paths and one-based spans with conclusions.
- Retrieve `FullRecord` only for candidates that need verification.
- State the source roots, exclusions, filters, bounds, and snapshot time.
- Use the real compiler and tests for semantic or runtime conclusions.
- Report the database path and whether it is temporary or retained.
- Remove only a database created solely for the current task; never delete an existing user database or repository file without authorization.
