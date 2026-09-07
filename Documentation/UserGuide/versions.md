# ULP Versions and Release History

This chapter explains how to identify an installed ULP build, evaluate an upgrade, and read release information. The executable and downloadable artifact are the authoritative version sources; the documentation avoids duplicating a number that can become stale.

## Contents

- [Find the Installed Version](#find-the-installed-version)
- [Find the Current Download](#find-the-current-download)
- [Current Release Capabilities](#current-release-capabilities)
- [Upgrade Safely](#upgrade-safely)
- [Compatibility](#compatibility)
- [Release Notes](#release-notes)
- [Release History](#release-history)
- [Planned Work](#planned-work)

## Find the Installed Version

Run:

```powershell
ulp --version
```

When running from an extracted folder:

```powershell
.\ulp.exe --version
```

The portable archive also carries the version in its filename and top-level folder:

```text
ulp-<version>-win-anycpu.zip
└── ulp-<version>-win-anycpu\
```

If a copied document disagrees with the executable, use the executable/package value and obtain matching documentation from that release.

## Find the Current Download

Start at [log-parser.com](https://log-parser.com) and follow the official download path. Verify the archive as described in [Installing ULP](installation.md#verify-a-download).

Do not infer that a similarly named package in a public registry is an official ULP release.

## Current Release Capabilities

The current manual documents these major workflows:

- query files, logs, structured data, Windows/system data, source code, assemblies, and databases through SQLite;
- stream text search and analysis without writing a full SQL query;
- join and aggregate multiple registered tables;
- run reusable saved queries with parameters and command aliases;
- export one result to terminal, CSV, JSON, Excel, HTML, SQL, templates, and multiple output pipelines;
- use guided menus, the terminal UI, built-in web interface, and SQL shell;
- invoke ULP through MCP from compatible AI/coding tools;
- render Scriban templates for code, configuration, documentation, and other generated text;
- resume applicable large inputs with checkpoints;
- execute direct ADO.NET queries for supported connection providers;
- optionally request AI-assisted SQL in the web interface after explicit configuration.

The detailed provider, writer, and function lists are generated from the actual runtime. See [Input and Output Formats](inputs-and-outputs.md), [SQL Function Reference](functions.md), and [ULP Reference](reference.md).

## Upgrade Safely

Portable releases are designed for side-by-side installation.

1. Download and verify the new ZIP.
2. Extract it into its own folder.
3. Keep the previous folder available for rollback.
4. Compare configuration defaults instead of overwriting them blindly.
5. Validate custom Query library entries and templates.
6. Run `--version`, basic help, and representative input/output workflows.
7. Update `PATH`, shortcuts, scheduled tasks, or launchers only after validation.

Keep mutable configuration, custom queries, logs, checkpoints, persistent databases, and generated output outside the application folder when practical. Never combine DLLs or native components from different releases.

## Compatibility

The desktop/CLI package targets Windows and .NET Framework 4.8.1. Successful operation can also depend on:

- packaged x86/x64 native SQLite components;
- Windows services and permissions required by a selected input;
- database drivers and server compatibility for external connections;
- the runtime's registered provider, writer, and function catalogs;
- Query library and template syntax;
- custom configuration and extension binary compatibility.

Use runtime discovery and a representative smoke suite when upgrading. Do not assume that two independently copied builds expose identical catalogs.

## Release Notes

A useful release note should state:

- what changed for users;
- fixed defects and affected workflows;
- security-relevant changes;
- breaking behavior or configuration changes;
- migration steps;
- known limitations;
- supported platform/runtime changes;
- the immutable release artifact and checksum.

The concise developer change record remains in the repository `CHANGELOG.md`. This chapter should summarize only verified user-visible releases.

## Release History

### Current preview release

The current build is being stabilized before publication. Its implemented workflows are summarized under [Current Release Capabilities](#current-release-capabilities).

Before it is described as publishable, maintainers must complete the package, clean-machine, security, documentation, and legal gates in [Deployment and Packaging](deployment.md#release-checklist).

Publication date, final highlights, known issues, and immutable checksums must be added from the approved release evidence. They are not invented in advance.

### Earlier releases

No verified public release chronology is recorded in this manual yet. Add an entry only when the publisher can supply the corresponding artifact, date, changes, and support status.

## Planned Work

Repository TODO files are implementation planning records, not release commitments. Planned work can move, change, or be removed as testing and product decisions evolve.

Before every future publication:

1. update the developer changelog;
2. add verified user-facing release notes here;
3. document migration steps and known issues;
4. regenerate runtime reference files;
5. rebuild and validate the exact package inventory and manifest;
6. complete security and legal review;
7. publish the archive, checksum, and notes together.

## Related Documentation

- [Installing ULP](installation.md)
- [Deployment and Packaging](deployment.md)
- [Troubleshooting](troubleshooting.md)
- [Security](security.md)
