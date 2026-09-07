# Universal Log Parser

> **INTERNAL REVIEW ONLY â€” DO NOT PUBLISH.** The approved ULP product license and one or more material redistribution/provenance approvals are unresolved. See `legal\PRODUCT-LICENSE-REQUIRED.txt` and `legal\dependency-inventory.csv`.

This is the portable ULP package for `win-anycpu`.

## Start

```powershell
.\ulp.exe --help
.\ulp.exe --query "SELECT sqlite_version() AS SQLiteVersion;" --output console --format Terminal
.\ulp.exe --menu
```

The root `ulp.exe` is a small launcher. The application and its required assemblies are under `runtime`; keep that directory with the launcher.

## Package layout

| Directory | Contents |
|---|---|
| `config` | Editable application/provider/writer defaults |
| `docs` | User manual and generated reference from the separate user-guide repository |
| `legal` | Product terms, notices, provenance, source information, checksums, and expanded third-party license texts |
| `patterns` | Installed Grok and reusable regular-expression definitions |
| `queries` | Installed recursive Query library |
| `runtime` | ULP application, managed dependencies, native SQLite files, and web assets |
| `samples` | Sample data, SQL, scripts, and templates |
| `session-sql` | Optional explicit connection-initialization SQL examples |
| `skills` | Optional instructions for compatible coding and AI agents |
| `web` | Editable, fully local browser application assets |

ULP uses `queries` in this package by default. The default configuration directory remains `config` under the current working directory; override it with `--config-dir` or `ULP_CONFIG_DIR`.

See `docs\README.md` for the complete manual. File hashes are recorded in `legal\package-files.sha256`. The ZIP checksum is distributed beside the archive.
