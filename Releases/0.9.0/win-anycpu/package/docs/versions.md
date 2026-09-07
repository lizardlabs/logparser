# ULP Versions and Release History

This chapter records user-facing version information that is supported by repository evidence. It does not invent release dates, download URLs, package IDs, or historical changes that have not been supplied by the publisher.

## Contents

- [Current Version](#current-version)
- [Download Current Version](#download-current-version)
- [What's New](#whats-new)
- [Upgrade Notes](#upgrade-notes)
- [Version Compatibility](#version-compatibility)
- [Versioning Policy](#versioning-policy)
- [Release History](#release-history)
- [Unreleased and Planned Changes](#unreleased-and-planned-changes)

## Current Version

Treat the executable and its release artifact as the authoritative version sources:

```powershell
ulp --version
```

Runtime/package version wins over this document if they differ. The release ZIP generator reads its three-part version from `ulp.exe` and creates `ulp-<version>-win-anycpu.zip`.

**Owner input required:** official release date, release status (preview/stable), support window, and immutable release identifier.

## Download Current Version

Start from [https://log-parser.com](https://log-parser.com) and follow the current official download path. This repository does not contain an approved public archive URL, Chocolatey/WinGet ID, MSI product code, or public NuGet package ID.

Verify every downloaded artifact as described in [Installing ULP](installation.md#verifying-downloads).

## What's New

The current source documents these major capabilities:

- SQLite-first queries over registered data providers through ParsingModule;
- direct streaming `search` and `analyze` commands;
- persistent SQLite ingestion;
- direct ADO.NET queries for SQLite, SQL Server, and OleDb;
- guided Beginner/Advanced menus, SQL shell, TUI, and optional web interface;
- recursive saved Query library with command aliases and bound parameters;
- CSV/TSV/delimited, JSON, YAML, TOON, Excel, events, filesystem, source-code, assembly, directory/system, and generated inputs;
- terminal, structured, document/workbook, SQL, and Scriban writers;
- multiple output pipelines and atomic/staged file behavior;
- checkpoints for applicable high-volume inputs;
- expanded SQLite/ULP function catalog;
- optional MCP server;
- experimental web AI SQL Chat, disabled by default;
- repeatable build/test/format/release workflows.

This list describes the current source, not a comparison with a verified earlier public release.

## Upgrade Notes

For portable installs:

1. extract the new release into a separate versioned directory;
2. preserve the previous release for rollback;
3. compare configuration/provider/writer defaults;
4. validate Query library metadata and custom plugins/templates;
5. run `--version`, provider/writer/function discovery, and representative queries;
6. move the stable PATH/launcher only after validation.

Do not overwrite a running installation. Keep mutable configuration, Query library, logs, checkpoints, outputs, and persistent databases separate when practical.

No specific breaking upgrade from an earlier released version is asserted because the repository contains no approved historical changelog.

## Version Compatibility

The documented application targets Windows and .NET Framework 4.8.1. Compatibility also depends on:

- packaged x86/x64 native SQLite components;
- SQLite version/compile options;
- registered function/provider/writer catalogs;
- provider schemas/properties;
- database/provider drivers;
- custom plugin binary compatibility;
- Query/template syntax;
- Windows permissions and services.

Use runtime discovery rather than assuming all builds expose identical functions or formats.

## Versioning Policy

The source uses a three-part numeric product version (`major.minor.patch`) and the release archive uses those three components. No publisher-approved semantic-versioning compatibility promise, support duration, deprecation window, or release cadence is currently documented.

**Owner input required:** define whether semantic versioning applies, what constitutes breaking change, supported-version policy, prerelease notation, release cadence, and security-fix/backport policy.

Until then, treat behavior/configuration changes between builds as requiring release-note review and regression testing.

## Release History

### Current pre-release line

#### Added

The current repository contains the capability set summarized under [What's New](#whats-new).

#### Changed

No verified prior public baseline is available in the repository.

#### Fixed

No approved release-level issue list is available in the repository.

#### Security

See [ULP Security](security.md). No release-specific advisory list is supplied here.

#### Breaking Changes

No verified prior public compatibility contract is available.

#### Upgrade Notes

Treat the currently downloaded artifact as the documented baseline and follow the portable upgrade procedure above.

**Owner input required:** publication date, concise highlights, issue/commit references, breaking changes, known issues, and supported upgrade sources.

## Unreleased and Planned Changes

Repository TODO files describe development intentions, not release commitments. Items may change, be removed, or ship under a different version.

Before publishing a future release:

- update root `CHANGELOG.md` with verified changes;
- update this user-facing history;
- state compatibility and migration steps;
- regenerate runtime/provider/writer/function references;
- rebuild dependency/legal inventory;
- verify package availability and hashes/signatures;
- remove resolved owner-review placeholders.

## Related Documentation

- [Deployment and Packaging](deployment.md)
- [Installing ULP](installation.md)
- [ULP Reference](reference.md)
