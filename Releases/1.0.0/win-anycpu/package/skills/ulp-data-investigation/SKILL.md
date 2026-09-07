---
name: ulp-data-investigation
description: Investigate logs, files, events, JSON, YAML, CSV, SQLite, and other supported ULP sources with reviewable bounded queries. Apply when an agent should inspect or summarize data without inventing schemas or silently exporting it.
---

# ULP data investigation

Discover capabilities before querying unfamiliar input:

```powershell
ulp --list-providers
ulp --help-provider CSV
ulp --list-functions
```

Prefer a small exploratory query with an explicit `LIMIT`, then inspect exact column names before aggregating, joining, or exporting. Use named `--param` values rather than replacing SQL strings. Materialize a forward-only virtual table before a query plan that must scan it repeatedly.

When a matching saved recipe exists, inspect and reuse it rather than rebuilding its source configuration. For ad-hoc work, keep the sequence reviewable: select provider and source, create the table, inspect a bounded sample/schema, prepare SQL, then execute.

Treat remote databases, URLs, Active Directory, event channels, and AI endpoints as external or privileged sources. Do not send data, expose credentials, or write output outside the requested location without user authorization. Mask secrets in connection strings and diagnostics. Clearly distinguish an empty result from a failed query.
