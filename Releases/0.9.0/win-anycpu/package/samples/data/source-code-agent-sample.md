---
title: Agent Guide
category: documentation
---

# Agent Guide

Use [`ulp --menu`](https://log-parser.com "Home") with ![ULP logo](logo.png).

## Setup

- [x] Install the release
- [ ] Configure a data source
1. Run a saved query

> Queries are ordinary SQLite.
> Results can use multiple writers.

| Command | Purpose |
| --- | --- |
| `ulp -c.dir` | List files |
| `ulp -c.code-find` | Search source |

```sql
SELECT Kind, Name FROM code_rows;
```

Reference
---------

<!-- internal documentation note -->

### Broken example

```json
{"ok": true}
