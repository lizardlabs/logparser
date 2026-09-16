# Optional local web server

ULP can host a browser interface over the same external Query library and SQLite query behavior used by the command line. The frontend and its DevExpress grid assets are packaged with ULP and do not load scripts, styles, fonts, or icons from the internet.

## Guided start

```powershell
ulp --web
```

In an interactive terminal, bare `ulp --web` opens a guided setup that asks who may connect, the bind address or DNS name, port, HTTPS or HTTP, certificate, username/password, access level, Query library, and web application directory. HTTPS remains the recommended default; HTTP is an explicit choice followed by a warning. The setup otherwise defaults to localhost, authentication, full workspace access, and the installed paths. The password is confirmed, hidden while typed, and kept only for this server process. Before listening, ULP displays a sanitized review with no passwords or certificate secrets; choose Back to revise it or Cancel to leave without starting the server.

The quick HTTPS choice generates a temporary self-signed certificate for this process. Traffic is encrypted, but browsers cannot trust that certificate automatically and will show a warning. Choose a trusted PFX or certificate-store thumbprint for routine network use.

## Explicit and automated start

Supplying any web-server setting bypasses the guided questions, so scripts and services remain non-interactive:

```powershell
ulp --web --web-port 8090 --web-mode read-only
ulp --web --web-user analyst --web-password @env:ULP_WEB_PASSWORD
ulp --web --web-http --web-bind localhost --web-port 8088
```

Explicit startup defaults to HTTPS. Use `--web-http` only when an unencrypted listener is deliberately required. If HTTPS has no explicit certificate, ULP creates a temporary self-signed certificate. Press Ctrl+C in the starting terminal to stop the server. Passwords are never printed. Prefer an `@env:`, `@file:`, or Windows Credential Manager secret reference instead of writing a password directly in a command line.

## Permission modes

| Mode | Saved query list/run | Query source | Ad-hoc SQL | Create/edit/delete |
|---|---:|---:|---:|---:|
| `full` | Yes | Yes | Yes | Yes |
| `query-runner` | Yes | No | No | No |
| `read-only` | Yes | Yes | No | No |
| `no-source` | Yes | No | No | No |

Use `--web-no-query-source`, `--web-no-adhoc`, and `--web-no-edit` to reduce a mode further. These restrictions are checked by the server for every request; hiding a browser control is never the security boundary. Query-runner and no-source responses do not return the SQL file contents.

The Query library is grouped by its complete folder hierarchy, and folders, navigation, query panels, parameters, server information, and results can be collapsed. **Open in new tab** opens the selected saved query directly in another browser tab without running it. Saved and ad-hoc modes are labelled explicitly; saved SQL can be reloaded or reset, and overwriting/deleting a library file requires confirmation. Saved and ad-hoc parameters use normal fields; Advanced JSON remains available for bulk editing. While a query or Shell request is running, **Stop** sends a correlated cancellation request to SQLite and then closes the browser request. The DevExpress result grid shows all returned rows through virtual scrolling without a separate pager, and supports filtering, sorting, resizing, selection, export, column choice, and a full-window workspace.

## Shell and experimental AI Chat

The Shell runs SQLite SQL and a small set of ULP commands such as `.tables`, `.schema NAME`, `.info`, and `.run QUERY_ID`. It never starts operating-system commands. Shell history is stored only in that browser tab/session. Disable the endpoint with `--web-no-shell`; server permissions are checked for every request.

AI Chat is visible as experimental and is never enabled merely by opening the web UI. Configure it with `--web-ai --web-ai-key @env:ULP_AI_API_KEY`, and optionally `--web-ai-base-url`, `--web-ai-model`, and `--web-ai-timeout`. The server sends a bounded schema description and conversation context to the configured OpenAI-compatible Chat Completions endpoint. Generated SQL is displayed for review and is never executed automatically. The browser receives only availability and model information, never the API key or secret headers. Use `--web-no-ai` to forbid the endpoint.

## Network exposure and authentication

ULP defaults to localhost. A non-loopback bind without authentication is rejected unless `--web-allow-insecure-remote` explicitly accepts that risk. Example LAN configuration:

```powershell
ulp --web --web-bind 192.168.1.20 --web-port 8443 --web-https `
  --web-certificate C:\Certificates\ulp.pfx --web-certificate-password @env:ULP_CERT_PASSWORD `
  --web-user analyst --web-password @env:ULP_WEB_PASSWORD --web-mode query-runner
```

Basic authentication does not encrypt credentials or results. For any LAN or remote use, use HTTPS and an appropriate firewall. ULP never enables an all-interface public listener by default.

## HTTPS on Windows

`--web-https` creates only an HTTPS listener; it does not silently retain HTTP. `--web-http` explicitly selects unencrypted HTTP and conflicts with `--web-https`. HTTP is available for controlled local scenarios but is never the recommended guided default. Without a certificate option, HTTPS generates a process-local self-signed certificate. For a browser-trusted identity, supply a PFX containing a private key with `--web-certificate` and, when needed, `--web-certificate-password`, or select a private-key certificate from the Current User or Local Machine personal certificate store with `--web-certificate-thumbprint`. Invalid certificate configuration produces a startup error instead of falling back to HTTP.

## Query Library behavior

The web interface uses the directory selected by `--queries-dir`, `ULP_QUERIES_DIR`, or the installed default. SQL files remain authoritative, and web changes are visible to the CLI immediately. File IDs are relative paths inside that directory; rooted and traversal paths are rejected. Saved-query parameter overrides must match parameters declared in the query metadata and are bound as SQLite parameters, not substituted into SQL text.

Each request receives its own SQLite connection. Command-line data-source blocks and session-initialization SQL are recreated for those connections, and Query library recipes continue to create their declared `ParsingModule` sources. `--web-max-rows` limits the rows returned to the browser; use bounded SQL as well when a source itself is expensive.

## Local assets and web root

The default `web` directory beside `ulp.exe` contains the complete application. `--web-root <directory>` is intended for controlled customization. Static requests are constrained to that root, and API responses do not include passwords, connection strings, API keys, server filesystem paths, stack traces, or hidden query source.
