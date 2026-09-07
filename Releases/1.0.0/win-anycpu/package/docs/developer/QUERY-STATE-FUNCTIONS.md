# Query-state compatibility functions

Microsoft Log Parser's `HASHSEQ`, `IN_ROW_NUMBER`, `OUT_ROW_NUMBER`, and `SEQUENCE` functions depend on query execution state. They must not be implemented as ordinary process-wide or connection-wide scalar counters.

## Required behavior

- `SEQUENCE()` starts at `0` for each call site and advances once per emitted row. `SEQUENCE(startValue)` starts at the supplied value. Multiple expressions in one query advance independently.
- `HASHSEQ(value)` assigns `1` to the first distinct non-null value, `2` to the next new value, and reuses the original number when a value repeats. Each call site has an independent map. SQL `NULL` remains `NULL`.
- `IN_ROW_NUMBER()` is the one-based source-row position before `WHERE`, grouping, ordering, projection, and output limits. Reusing it in the filter and projection must return the same input position.
- `OUT_ROW_NUMBER()` is the one-based final result-row position after filtering, grouping, and sorting. It resets for every result set.

## Execution model

The implementation needs one query-state scope per prepared statement and one result-state scope per result set. State is owned by the executing command, never by a static function instance or a shared SQLite connection.

The query engine will create a unique execution identifier immediately before statement execution and dispose it after every result set is consumed or cancelled. Foreground queries, background jobs, the SQL shell, TUI queries, saved-query execution, and MCP execution must all use the same boundary. A nested lifecycle hook receives a separate scope.

Each parsed function occurrence receives a stable call-site identifier. `SEQUENCE` counters and `HASHSEQ` maps are keyed by that identifier. State uses ordinal text comparison, is cleared on completion/failure/cancellation, and is never shared across concurrent commands.

`IN_ROW_NUMBER` must be supplied by the source-row pipeline before predicates are evaluated. `OUT_ROW_NUMBER` and `SEQUENCE` must be supplied by the result pipeline after final ordering. A plain SQLite scalar callback cannot provide these phases correctly: it may run more than once, be skipped by the optimizer, or run before `ORDER BY`. SQL-text substitution to `ROW_NUMBER()` is also insufficient because it cannot preserve input position in `WHERE` or independent call-site state in arbitrary nested queries.

## Integration approach

1. Extend normalized query metadata with call-site IDs without changing quoted strings, comments, or identifiers.
2. Add an execution-scoped state object to the shared query request and propagate it through every query host.
3. Expose the source position from ParsingModule cursors and from ordinary SQLite sources through a statement wrapper that materializes an input ordinal before filtering.
4. Wrap each final result set with an output ordinal after SQLite has completed sorting and grouping.
5. Evaluate sequence and distinct-value state at their required phase, then expose the values to the projected columns.
6. Keep all four names marked `Planned (query state)` until the complete pipeline is active; do not register partially correct scalar aliases.

## Acceptance tests

- Resets between sequential commands, statements, and result sets.
- Independent `SEQUENCE(10)`, `SEQUENCE(100)`, and repeated call sites in one projection.
- Stable `HASHSEQ` values for repeated, alternating, empty, case-distinct, and null values.
- `IN_ROW_NUMBER` values preserved through filters, joins, grouping, subqueries, and limits.
- `OUT_ROW_NUMBER` assigned after ascending and descending sorts and after grouping.
- Identical behavior with one writer, output fan-out, SQL shell, TUI, background jobs, and MCP.
- Parallel commands on separate connections never share counters or hash maps.
- Cancellation and errors release all state; retry starts cleanly.
- Golden comparison against Microsoft Log Parser 2.2 for supported query shapes.

This design intentionally favors correct phase-aware results over a quick scalar approximation.
