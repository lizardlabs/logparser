# ULP Security

This chapter explains how to obtain, deploy, configure, and use ULP safely. It is user and administrator guidance; the root `SECURITY.md` is the vulnerability-reporting policy.

## Contents

- [Security Model](#security-model)
- [Downloading ULP Safely](#downloading-ulp-safely)
- [Official Distribution Sources](#official-distribution-sources)
- [Package Integrity](#package-integrity)
- [SHA256 Verification](#sha256-verification)
- [Digital Signatures](#digital-signatures)
- [Antivirus and Reputation](#antivirus-and-reputation)
- [Dependencies](#dependencies)
- [Processing Untrusted Data](#processing-untrusted-data)
- [SQL and Query Safety](#sql-and-query-safety)
- [File and Output Safety](#file-and-output-safety)
- [Credentials and Connection Strings](#credentials-and-connection-strings)
- [AI Security Considerations](#ai-security-considerations)
- [API-Key Security](#api-key-security)
- [Web Interface Security](#web-interface-security)
- [MCP Security](#mcp-security)
- [Network Activity](#network-activity)
- [Logs, Checkpoints, and History](#logs-checkpoints-and-history)
- [Reporting Security Problems](#reporting-security-problems)

## Security Model

ULP runs with the permissions of the current process/account. It can read files, logs, directories, archives, databases, directory services, and system information; execute SQL; write outputs; run explicitly configured post-actions; host an optional local web interface; and contact a user-configured AI endpoint.

ULP is not a security sandbox. Provider and writer restrictions reduce accidental misuse but do not replace operating-system permissions, database permissions, network controls, or human review.

Use least privilege:

- run as a dedicated ordinary account for automation where practical;
- grant only required input and output access;
- keep the application and centrally managed Query library read-only to untrusted users;
- use read-only database credentials for analysis;
- avoid elevated execution unless the selected provider truly requires it;
- separate untrusted input from sensitive output and credentials.

## Downloading ULP Safely

Start with the project home: [https://log-parser.com](https://log-parser.com). Follow the current publisher-provided download path for the exact release.

Do not trust a package only because its filename, registry ID, or search-result title contains “ULP” or “Universal Log Parser.” Only install from a distribution channel identified by the publisher.

Keep the complete archive. Copying only `ulp.exe` can omit native/runtime dependencies and can encourage DLL search/loading from unintended locations.

## Official Distribution Sources

A correctly named ZIP does not prove who published a binary. For each release, confirm:

- the link originates from the publisher-controlled site/channel;
- the version and filename match the release announcement;
- any hash/signature is obtained through a trusted channel;
- the package has not been silently replaced;
- the complete dependency/legal notices are present.

**Owner-review requirement:** the publisher must document the exact official repository/download URLs and signing identity before the manual can name them as authoritative.

## Package Integrity

Verify before extraction/execution, then verify the extracted structure. A current portable package should include the executable, runtime DLLs, both native SQLite architecture folders, documentation, samples, Query library/web/config assets intended by the release, and legal notices.

Unexpected executable/DLL files, a missing legal inventory, obsolete executable names, or debug/test artifacts should stop deployment until the package is explained.

## SHA256 Verification

Calculate a package hash:

```powershell
$actual = (Get-FileHash .\ulp-<version>-win-anycpu.zip -Algorithm SHA256).Hash
$actual
```

Compare it with the exact expected hash published through a separately trusted channel. A locally calculated hash alone proves only that you can identify the same bytes later.

Do not put a sample hash in automation. Hashes are release-specific.

## Digital Signatures

Inspect an Authenticode signature only when the release claims one:

```powershell
Get-AuthenticodeSignature .\ulp.exe |
    Format-List Status,StatusMessage,SignerCertificate,TimeStamperCertificate
```

Confirm the signer against publisher documentation. A valid signature from an unexpected entity is not sufficient. This manual does not invent or assume the production signing certificate.

## Antivirus and Reputation

Scan according to organizational policy. Antivirus reputation can differ for new or uncommon binaries and can change after publication. A clean scan is one signal, not proof of safety; a detection requires investigation rather than automatic dismissal or automatic guilt.

No VirusTotal report URL or detection count is asserted here because no verified report for a specific immutable release is provided here.

## Dependencies

The release contains third-party and locally sourced dependencies. Review:

- [`legal/THIRD-PARTY-NOTICES.md`](legal/THIRD-PARTY-NOTICES.md);
- [`legal/dependency-inventory.csv`](legal/dependency-inventory.csv);
- the license texts under `docs/legal/licenses`;
- release-specific provenance and vulnerability scanning.

The current engineering notice identifies components requiring review, including locally modified/prebuilt or restrictively/proprietarily licensed binaries. A release must not bypass unresolved inventory status merely to create an archive.

Dependency license review and vulnerability review are different activities; perform both.

## Processing Untrusted Data

Untrusted files can be huge, malformed, compressed, deeply nested, intentionally ambiguous, or designed to consume CPU/memory/disk.

Controls:

- start with a small `LIMIT` and constrained source path;
- retain default directory exclusions unless needed;
- set regex timeouts and bounded line lengths;
- avoid archive bombs and recursively nested archives;
- restrict output and temporary disk capacity;
- avoid media metadata/content hashing unless required;
- use a disposable low-privilege account/environment for hostile samples;
- cancel with Ctrl+C when resource use is unexpected;
- do not open generated HTML/Excel/SQL in privileged applications automatically.

CSV/Excel formula injection is a downstream spreadsheet risk. Treat cells beginning with formula control characters as untrusted when opening an export in spreadsheet software.

## SQL and Query Safety

ULP intentionally supports SQL that can create, update, insert, delete, attach, materialize, invoke registered functions, and write through configured mechanisms. Only run SQL you trust and understand.

Before running shared/generated SQL:

- inspect all statements, not only the final `SELECT`;
- check lifecycle hooks and Query library metadata;
- inspect file/network/process-capable functions;
- check attached database paths and output writers;
- bind values through parameters rather than concatenation;
- keep identifiers under explicit validation;
- use read-only credentials and filesystem permissions where possible.

AI-generated SQL and downloaded saved queries require the same review. A statement beginning with a read-oriented keyword is not a formal proof of harmlessness.

## File and Output Safety

Use explicit output roots. `--no-overwrite` rejects existing targets; `{n}` chooses a free name; `--no-output-if-empty` preserves an existing target when no rows exist. Writers use staged publication where supported, but backups and access controls remain your responsibility.

Scriban dynamic output paths are constrained to the selected root and traversal is rejected. Still review templates because they determine generated content and filenames.

Do not use a world-writable application, config, Query library, template, or output directory for privileged automation.

## Credentials and Connection Strings

Prefer whole-value secret references:

- `@env:NAME`;
- `@file:path`;
- `@wincred:target`.

Avoid literal credentials in commands, SQL, config, filenames, logs, screenshots, saved queries, source control, or process arguments. Restrict the referenced source and rotate exposed values.

ULP masks recognized secrets in displayed connection strings/errors. Masking is defense in depth, not a guarantee for arbitrary text. A selected result column or custom error message can still contain sensitive values.

## AI Security Considerations

Experimental web AI is disabled by default and must remain disabled when external processing is not approved.

When enabled, a remote provider receives the prompt, bounded recent conversation, schema table/view/column names and types, model identifier, authentication, and network metadata. ULP does not intentionally send result rows or input-file contents by default, but anything typed into a prompt is transmitted.

Schema names can themselves reveal sensitive projects/customers. Review provider retention, account settings, residency, contracts, and organizational approval. See [What Data May Leave Your Computer](ai.md#what-data-may-leave-your-computer).

## API-Key Security

- scope the key to the minimum provider/project permissions;
- store it in a protected secret source;
- never return it to browser JavaScript or query results;
- avoid shared long-lived keys;
- rotate on role/account change or suspected exposure;
- review provider usage for anomalies;
- do not use HTTP to a remote AI endpoint.

ULP does not persist the web AI key in its ordinary settings file or return it in web server information.

## Web Interface Security

The optional web server defaults to localhost and HTTPS. Bare interactive startup guides through transport/authentication. Explicit HTTP is available only through `--web-http` and is not recommended.

For remote/LAN access:

- use a trusted HTTPS certificate;
- require both username and password;
- restrict firewall/listener scope;
- choose `query-runner`, `read-only`, or `no-source` where possible;
- disable ad-hoc SQL, editing, Shell, source display, and AI when unnecessary;
- protect the Query library and web root from untrusted modification;
- stop the server when finished.

Basic authentication protects access but relies on HTTPS for confidentiality. A non-loopback bind without authentication is blocked unless `--web-allow-insecure-remote` explicitly accepts the risk.

## MCP Security

MCP runs over stdio with the permissions of the client-launched ULP process. The client can request discovery and query operations exposed by ULP. Configure an absolute executable, controlled working/config/query directories, and least-privilege account.

Treat MCP client prompts/model actions as external control of the allowed ULP tools. Review the client's approval model and logs. Keep stdout reserved for protocol messages; diagnostics belong on stderr/logs.

## Network Activity

ULP performs network activity when the user configures or selects it, including:

- HTTP/URL/archive/cloud-capable inputs;
- SQL Server/OleDb/other remote database connections;
- Active Directory/domain access;
- optional web-server listener;
- experimental AI API requests;
- network file shares;
- any explicitly configured post-action program.

The current user-facing configuration does not document a publisher telemetry/analytics endpoint enabled by default. This is an engineering observation, not a substitute for an approved privacy statement. Monitor network behavior in the target environment and review each release.

## Logs, Checkpoints, and History

Logs may contain SQL, paths, schema names, timing, errors, and sanitized context. Checkpoints reveal source identities/progress. Browser session history may contain SQL prompts or generated statements. Query libraries and shell history reveal analyst intent.

Store these under suitable ACLs, define retention, and sanitize before sharing. Do not delete operational state during uninstall unless the data owner authorizes it.

## Reporting Security Problems

The publisher must provide an approved private vulnerability-reporting address and response policy. Until then, use the product website to request a private reporting channel; do not publish exploit details in a public issue.

Until then, use the current contact path published at [log-parser.com](https://log-parser.com) and ask for a private security channel without initially sending exploit details, secrets, or sensitive data. Do not open a public issue containing a working exploit.

**Owner input required:** private reporting address/form, supported versions, acknowledgement/triage targets, disclosure policy, encryption key, and safe-harbor language.

## Related Documentation

- [Installing ULP](installation.md)
- [Deployment and Packaging](deployment.md)
- [AI Features](ai.md)
- [Troubleshooting](troubleshooting.md)
- [Legal, Licensing, Privacy, and Disclaimers](legal.md)
