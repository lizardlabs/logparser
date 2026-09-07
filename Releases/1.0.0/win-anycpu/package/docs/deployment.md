# Deployment and Packaging

This chapter covers ULP 1.0 deployment for administrators and release maintainers. The verified distribution path in the current source tree is a portable Windows ZIP built from the complete repository. Chocolatey, WinGet, Windows Installer, and public NuGet distribution are not yet backed by publisher-approved package definitions here.

For end-user download, extraction, PATH, upgrade, and removal instructions, see [Installing ULP](installation.md). This chapter focuses on controlled rollout, automation, package creation, and release artifacts.

## Contents

- [Overview](#overview)
- [Portable Deployment](#portable-deployment)
- [Chocolatey Deployment](#chocolatey-deployment)
- [WinGet Deployment](#winget-deployment)
- [Windows Installer Deployment](#windows-installer-deployment)
- [NuGet Deployment](#nuget-deployment)
- [Enterprise Deployment](#enterprise-deployment)
- [Silent Installation](#silent-installation)
- [PATH Configuration](#path-configuration)
- [Automation](#automation)
- [Package Verification](#package-verification)
- [Building Release Packages](#building-release-packages)
- [Release Artifacts](#release-artifacts)
- [Package Matrix](#package-matrix)
- [Maintainer Packaging Files](#maintainer-packaging-files)
- [CI/CD Integration](#cicd-integration)
- [Release Checklist](#release-checklist)

## Overview

ULP is a portable Windows application targeting .NET Framework 4.8.1. The release executable is AnyCPU, while the complete package includes native SQLite components for both x86 and x64 operation.

The current package model is intentionally simple:

```text
release build
    -> dependency/license inventory
    -> staged portable directory
    -> versioned ZIP archive
```

Do not deploy only `ulp.exe`. Runtime DLLs, native components, configuration, Query library content, web assets, documentation, and other files beside the executable are part of the application.

### Verified and unverified channels

| Channel | Status in this source tree |
| --- | --- |
| Portable ZIP | Implemented by the release script |
| Internal file share/software distribution of that ZIP | Supported as an administrative use of the portable package |
| Build from source | Implemented for a complete developer workspace |
| Chocolatey | No publisher-approved package definition or ID |
| WinGet | No publisher-approved manifest or ID |
| Windows Installer/MSI | No installer project or approved product code |
| Public NuGet SDK/tool | No supported public package ID |

The project website is [log-parser.com](https://log-parser.com). A similarly named package in a public registry is not automatically an official ULP release.

## Portable Deployment

Portable deployment is the current recommended administrative model. It supports side-by-side versions, does not require machine-wide installer state, and is easy to roll back.

### Directory layout

Use a versioned installation root:

```text
C:\Tools\ULP\
├── 1.0.0\
│   ├── ulp.exe
│   ├── config\
│   ├── docs\
│   ├── queries\
│   ├── samples\
│   ├── web\
│   ├── x86\
│   ├── x64\
│   └── runtime dependencies
└── current -> selected version (managed by the administrator)
```

Windows directory junctions/symbolic links require appropriate permissions and policy. A simpler alternative is a stable wrapper script or deployment-system alias that invokes the selected version's `ulp.exe`.

### Deploy

1. obtain the archive from the approved source;
2. verify checksum/signature information that was actually published;
3. extract to a new versioned directory;
4. preserve the complete package layout;
5. apply organization-managed configuration separately;
6. run a smoke test under the intended service/user account;
7. update the stable launcher or PATH only after validation.

Example smoke tests:

```powershell
C:\Tools\ULP\1.0.0\ulp.exe --version
C:\Tools\ULP\1.0.0\ulp.exe --query "SELECT sqlite_version()" --output none
C:\Tools\ULP\1.0.0\ulp.exe --list-providers
C:\Tools\ULP\1.0.0\ulp.exe --list-writers
```

Provider-specific smoke tests should use a small non-sensitive source and the same permissions as production.

### Upgrade

Install the new archive beside the old version, copy or regenerate only reviewed local configuration, validate, then move the stable launcher/PATH entry. Do not extract a new version over a running installation.

Keep user-maintained configuration and Query libraries outside the version directory when frequent upgrades are expected:

```powershell
ulp --config-dir C:\ProgramData\ULP\config `
    --queries-dir C:\ProgramData\ULP\queries `
    --query "SELECT 1"
```

### Roll back

Point the stable launcher back to the previous intact version. Review configuration compatibility first: a newer release may have generated new provider/writer properties or Query library conventions not understood by an older release.

### Remove

Stop ULP processes, remove the PATH/launcher reference, then remove the selected version directory according to retention policy. Configuration, Query libraries, logs, output, checkpoint files, and persistent databases are user/operational data; do not delete them merely because one executable version is removed.

## Chocolatey Deployment

There is no publisher-approved Chocolatey package definition or verified package ID in the current source tree. Consequently, this manual does not provide `choco install`, upgrade, or uninstall commands.

Before this channel can be documented as supported, maintainers must provide and review:

- a package ID owned by the publisher;
- a `.nuspec` with verified metadata and license/project URLs;
- install/uninstall scripts;
- an immutable official archive URL;
- SHA256 verification;
- package contents and PATH behavior;
- upgrade/downgrade rules;
- automated packaging tests;
- publication ownership and recovery procedure.

An enterprise may create an internal Chocolatey wrapper around the official portable ZIP, but it becomes that enterprise's package and support responsibility. Do not present an internal ID as the public ULP package.

## WinGet Deployment

There is no publisher-approved WinGet manifest or verified package identifier in this source tree. Do not guess one.

A future manifest set should define and test:

- exact publisher/package identifiers;
- installer type and architecture behavior;
- version and official download URL;
- SHA256 hash;
- upgrade and uninstall behavior;
- PATH/alias behavior;
- agreement between manifest metadata and the signed release.

Submit a public manifest only after the official artifact is immutable and available from a stable publisher-controlled URL.

## Windows Installer Deployment

The current project does not include a supported MSI/MSIX/setup project or an approved product/upgrade code. Portable ZIP deployment is therefore the implemented release path.

A future installer needs explicit decisions for:

- per-user versus per-machine scope;
- install directory and ACLs;
- PATH or application execution aliases;
- file associations, if any;
- configuration preservation;
- Query library ownership;
- upgrade/repair/rollback semantics;
- service/firewall/certificate behavior, if any;
- digital signing and timestamping;
- silent command contract;
- uninstall data-retention policy.

Do not wrap the ZIP in an installer and claim repair/uninstall support without implementing and testing those behaviors.

## NuGet Deployment

ULP 1.0 is documented as an application, not a supported public SDK or .NET tool package. No official package ID or stable public programming API is defined here.

Internal projects may reference source projects in the complete workspace, but that is development integration rather than public NuGet deployment. A future package must define its audience (library, global/local tool, or provider SDK), supported target frameworks, compatibility policy, dependencies, examples, and versioning before user commands are published.

## Enterprise Deployment

### Recommended model

For managed Windows estates:

1. acquire and verify the official portable archive;
2. import it into the organization's trusted artifact system;
3. record the original hash and provenance;
4. scan it under organizational policy;
5. deploy the complete directory read-only to ordinary users where practical;
6. store mutable configuration, queries, logs, checkpoints, and output outside the application directory;
7. grant only required source/output permissions;
8. use a versioned rollout and rollback ring;
9. validate representative providers and writers;
10. collect sanitized diagnostics under an explicit retention policy.

### Configuration separation

Example organization layout:

```text
C:\Program Files\ULP\1.0.0\       application package (admin managed)
C:\ProgramData\ULP\config\       shared reviewed defaults
C:\ProgramData\ULP\queries\      shared Query library
C:\ProgramData\ULP\logs\         protected operational logs
D:\ULP-Output\                     controlled output
```

Invoke explicit locations in automation:

```powershell
& 'C:\Program Files\ULP\1.0.0\ulp.exe' `
  --config-dir 'C:\ProgramData\ULP\config' `
  --queries-dir 'C:\ProgramData\ULP\queries' `
  --log-file 'C:\ProgramData\ULP\logs\job-{yyyy-MM-dd}.log' `
  -c.daily-errors
```

Use ACLs so untrusted users cannot replace the executable, DLLs, native SQLite components, Query library SQL, web assets, or centrally managed configuration.

### Web deployment

The optional web interface is not a general-purpose internet service. Default to localhost. For controlled LAN use, configure HTTPS, authentication, a restricted permission mode, firewall scope, and a trusted certificate. Keep AI disabled unless its external data flow is approved. See [User Interface](user-interface.md) and [AI Features](ai.md).

### MCP deployment

The MCP server communicates over stdio and normally runs as the configured desktop client's user:

```powershell
ulp --mcp
ulp --mcp --database C:\Data\agent-session.sqlite `
    --queries-dir C:\Data\ulp-queries
```

It exposes provider/table discovery, schema inspection, bounded query execution, saved-query discovery/review/load/execute, writer discovery, explicit export, materialization, table removal, and session history. A reliable agent workflow is:

1. discover a saved query or provider;
2. inspect its metadata/help and table schema;
3. load a recipe with overrides without executing it;
4. review prepared SQL and native bindings;
5. execute only after review;
6. materialize streaming sources before plans that rescan them;
7. export only to an explicitly approved path.

Use an absolute executable path and controlled configuration/query directories. Query-library parameters are restricted to declarations in the recipe and bound as SQLite parameters; library selection is fixed by the server administrator at startup. Treat Query library files as trusted code, grant the process only required filesystem/event-log permissions, and keep protocol stdout free of banners or diagnostics.

VS Code/GitHub Copilot configurations commonly use a workspace `.vscode/mcp.json` with a `servers` object:

```json
{
  "servers": {
    "ulp": {
      "type": "stdio",
      "command": "C:\\Tools\\ULP\\ulp.exe",
      "args": ["--mcp", "--database", "C:\\Data\\agent.sqlite"],
      "env": {
        "ULP_CONFIG_DIR": "C:\\Tools\\ULP\\config",
        "ULP_QUERIES_DIR": "C:\\Data\\ulp-queries"
      }
    }
  }
}
```

Claude Desktop and Cursor commonly use an `mcpServers` object in their respective MCP configuration:

```json
{
  "mcpServers": {
    "ulp": {
      "command": "C:\\Tools\\ULP\\ulp.exe",
      "args": ["--mcp"],
      "env": { "ULP_CONFIG_DIR": "C:\\Tools\\ULP\\config" }
    }
  }
}
```

Client configuration locations and schemas can change, so compare these ULP values with the client's current documentation. Verify the executable first with `ulp --version` and `ulp --list-providers`; then call saved-query/provider/table discovery from the client. An idle server terminal is normal for a long-running stdio service. JSON is the default interoperable query payload; TOON remains available through explicit export rather than replacing MCP JSON. See the [generated MCP command reference](reference/generated/mcp-reference.md) and [ULP Security](security.md#mcp-security).

## Silent Installation

There is no installer-specific silent command because no supported installer exists. Portable extraction and configuration can be automated without prompts.

Example controlled extraction after independent verification:

```powershell
$archive = 'C:\ApprovedPackages\ulp-1.0.0-win-anycpu.zip'
$target = 'C:\Tools\ULP\1.0.0'
New-Item -ItemType Directory -Path $target -Force | Out-Null
Expand-Archive -LiteralPath $archive -DestinationPath $target
& (Join-Path $target 'ulp.exe') --version
```

An administrator should fail deployment when the target already contains a different package rather than silently merging directories. The example leaves overwrite/idempotence policy to the deployment system.

## PATH Configuration

Prefer one exact trusted directory. Do not add a broad writable parent directory containing unrelated executables.

For one process/session:

```powershell
$env:Path = 'C:\Tools\ULP\current;' + $env:Path
ulp --version
```

For managed machines, deploy a user/machine PATH entry through the organization's configuration system. Preserve the existing value, avoid duplicates, and ensure the chosen directory is not writable by untrusted users.

Verify resolution:

```powershell
Get-Command ulp -All
where.exe ulp
ulp --version
```

Multiple unexpected results can execute the wrong release. Use an absolute path in scheduled tasks and high-assurance automation.

## Automation

ULP separates result data on stdout, diagnostics on stderr, and status through exit codes. A deployment smoke test can capture all three independently.

```powershell
$ulp = 'C:\Tools\ULP\1.0.0\ulp.exe'
& $ulp --query 'SELECT 1 AS ok' --format JSON 1> result.json 2> diagnostic.log
if ($LASTEXITCODE -ne 0) {
    throw "ULP smoke test failed with exit code $LASTEXITCODE."
}
```

Use `--require-rows`, `--expect-scalar`, or `--require-condition` for explicit gates. Use `--no-output-if-empty` and staged writers when an old artifact must survive an empty run. See [ULP Reference](reference.md#automation-and-lifecycle-options).

Do not put passwords, API keys, or credential-bearing connection strings directly in scheduled-task arguments. Use `@env:`, `@file:`, or `@wincred:` references and restrict access to their source.

## Package Verification

### SHA256

If the publisher supplies a hash through a trusted channel, compare it before extraction:

```powershell
(Get-FileHash .\ulp-1.0.0-win-anycpu.zip -Algorithm SHA256).Hash
```

The value is meaningful only when compared with an independently trusted expected hash. This source tree does not define a release hash because each archive has its own value.

### Digital signatures

Inspect an executable signature when the release claims to be signed:

```powershell
Get-AuthenticodeSignature .\ulp.exe | Format-List Status,StatusMessage,SignerCertificate,TimeStamperCertificate
```

Do not infer a signing identity. Accept only the publisher identity and certificate policy documented for the particular release.

### Archive contents

Verify at minimum:

- `ulp.exe` is present;
- x86 and x64 native SQLite components are present;
- required runtime DLLs remain beside the application;
- `docs`, `samples`, Query library/web/config content intended for the release are present;
- `docs/legal` and the dependency inventory are present;
- obsolete `PortableLogParser.exe` names are absent;
- `.pdb` files and assembly XML documentation files are absent;
- build-only `output-gallery`, benchmark data, temporary, partial, and test files are absent.

### Antivirus and reputation

Use organizational scanning and the publisher's actual release statements. A clean result from one scanner is not a permanent guarantee, and this manual does not invent a VirusTotal URL or detection count.

## Building Release Packages

### Prerequisites

Use the complete repository/workspace on Windows with:

- .NET Framework 4.8.1 developer/targeting support;
- a compatible .NET SDK/MSBuild toolchain;
- restored packages and referenced sibling projects/dependencies;
- PowerShell;
- permission to write build output and the repository-level `artifacts` directory.

### Unified build command

From the repository root:

```powershell
.\build.ps1 Build -Configuration Release
.\build.ps1 Test -Configuration Release
.\build.ps1 FormatCheck
```

`Finish` formats changed C#/VB source, builds, and tests:

```powershell
.\build.ps1 Finish -Configuration Release
```

### Release package

Create the verified portable package:

```powershell
.\build.ps1 Release
```

Equivalent project-directory command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\pack-release.ps1
```

The release script:

1. builds `UniversalLogParser.csproj` in Release unless `-SkipBuild` is used;
2. builds the small package launcher and requires both compiled executables;
3. regenerates the binary dependency/license inventory;
4. fails when an inventory item is unreviewed/unmapped;
5. reads the package version from `ulp.exe`;
6. regenerates runtime-owned reference files into `Documentation/UserGuide/reference/generated`, then reads the manual and product license from the separate user-guide repository;
7. excludes debug symbols, compiler XML sidecars, output galleries, secrets, certificates, signing keys, obsolete files, and unnecessary localized satellite resource assemblies;
8. writes per-file SHA-256 hashes and executes a SQLite smoke query through the packaged launcher;
9. creates and validates the versioned ZIP under the repository `artifacts` directory;
10. writes a separate SHA-256 file for the completed ZIP;
11. stages the ZIP, checksum, and expanded review package under `Releases/<version>/<platform>/` in this user-guide repository without committing or pushing.

`-SkipBuild` is safe only after a known successful Release build from the intended source revision.

### License-review escape hatch

`-AllowUnreviewedLicenses` exists only to test staging/ZIP mechanics. A package produced with it is not legally approved for publication.

```powershell
.\build.ps1 Release -AllowUnreviewedLicenses
```

Do not upload or distribute that artifact as a release. Resolve the inventory and notices first.

## Release Artifacts

The implemented release archive is named:

```text
artifacts\ulp-<version>-win-anycpu.zip
artifacts\ulp-<version>-win-anycpu.zip.sha256
```

The staging directory uses the same name without `.zip`. Version is read as three numeric components from the built executable.

The user-guide repository receives the same artifacts under:

```text
Releases\<version>\<platform>\
├── README.md
├── ulp-<version>-<platform>.zip
├── ulp-<version>-<platform>.zip.sha256
└── package\
```

The packager updates `Releases/README.md` and `Releases/latest.json` locally. It never commits or pushes; publication is an explicit repository-owner step.

The ZIP root contains only `ulp.exe` and `README.md`. `ulp.exe` is a small launcher that starts the application from `runtime` using the application's binding configuration. Keep the complete extracted directory together.

The organized subdirectories are:

| Directory | Contents |
| --- | --- |
| `config` | Editable application/provider/writer defaults |
| `docs` | User manual and generated reference |
| `legal` | Direct product license/notices/inventory/checksums and an archive of supplemental third-party license texts |
| `patterns` | Installed Grok and reusable regular-expression definitions plus their notice |
| `queries` | Installed recursive Query library |
| `runtime` | Main application, managed dependencies, native x86/x64 components, and web assets; unnecessary localized satellite resources are omitted |
| `samples` | Sample data, SQL, scripts, and templates |
| `session-sql` | Optional explicit connection-initialization SQL examples |
| `skills` | Optional public-CLI instructions for compatible coding and AI agents |

The release process excludes:

- `.pdb` debug symbols;
- XML files that are assembly documentation companions;
- obsolete `PortableLogParser.exe*` files;
- `output-gallery`;
- `.pfx`, `.p12`, `.snk`, and `.key` certificate/signing-key files;
- files not present in the selected Release output/docs/samples inputs.

Ordinary non-assembly XML data/configuration files are not excluded solely because their extension is `.xml`.

## Package Matrix

| Artifact/channel | Platform | Contents | Built now | Publish status |
| --- | --- | --- | ---: | --- |
| `ulp-<version>-win-anycpu.zip` | Windows, AnyCPU with x86/x64 native parts | Application, runtime, docs, samples, config | Yes | Publisher decides per release |
| Source workspace | Windows development environment | Projects, tests, docs, scripts | Yes | Repository access dependent |
| Chocolatey package | Windows | Not defined | No | Not published/verified here |
| WinGet manifest | Windows | Not defined | No | Not published/verified here |
| MSI/MSIX/setup | Windows | Not defined | No | Not published/verified here |
| Public NuGet SDK/tool | .NET | Not defined | No | Not published/verified here |

## Maintainer Packaging Files

Current authoritative files:

| File | Purpose |
| --- | --- |
| repository `build.ps1` | Unified Build/Test/Format/Finish/Release entry point |
| `PortableLogParser/pack-release.ps1` | Portable staging, inventory gate, and ZIP creation |
| `PortableLogParser/ReleaseLauncher` | Minimal root launcher for the organized `runtime` directory |
| `PortableLogParser/Tests/Test-ReleasePackage.ps1` | Root-layout, checksum, archive-content, forbidden-file, and packaged-query validation |
| `PortableLogParser/UniversalLogParser.csproj` | Release executable build and package-copy inputs |
| `PortableLogParser/legal/generate-dependency-inventory.ps1` | Runtime binary/license inventory generation |
| `PortableLogParser/docs/legal/dependency-inventory.csv` | Generated dependency review evidence |
| `PortableLogParser/docs/developer/RELEASING.md` | Concise maintainer release notes |
| `PortableLogParser/docs/developer/TESTING.md` | Build, tests, format, gallery, and benchmark guidance |

There is currently no `packaging/` directory containing Chocolatey, WinGet, Windows Installer, NuGet, or portable package definitions. Create channel-specific configuration only when implementing that channel; do not merge technically unrelated package files merely to reduce documentation file count.

## CI/CD Integration

A release pipeline should use the same repository commands as a maintainer workstation:

```powershell
.\build.ps1 FormatCheck
.\build.ps1 Build -Configuration Release
.\build.ps1 Test -Configuration Release
.\build.ps1 Release
```

Recommended stages:

1. checkout the exact revision with required dependencies;
2. restore through the approved dependency source;
3. verify formatting;
4. build Release with the output gallery disabled when appropriate;
5. run automated tests;
6. generate/review dependency inventory;
7. package without the unreviewed-license override;
8. inspect archive structure and execute smoke tests from an extracted copy;
9. calculate and publish SHA256 through a trusted channel;
10. sign before packaging or according to the approved signing design;
11. publish immutable artifacts;
12. promote through deployment rings with rollback retained.

For a fast build where the manual writer gallery is not required:

```powershell
dotnet build .\PortableLogParser\UniversalLogParser.csproj `
  --configuration Release -p:RunOutputGallery=false
```

Never expose signing keys, package tokens, database credentials, or API keys in logs. Fail the pipeline when required legal/security checks are unavailable instead of silently publishing an incomplete artifact.

## Release Checklist

- [ ] Version metadata is correct and `ulp --version` reports it.
- [ ] Changed C#/VB source passes formatting verification.
- [ ] Release build succeeds from a clean/controlled workspace.
- [ ] Automated tests pass in Release configuration.
- [ ] Dependency inventory has no `review` or `unmapped` binaries.
- [ ] License and third-party notices match shipped dependencies.
- [ ] Archive name matches the executable version.
- [ ] Complete x86/x64 native dependencies are present.
- [ ] `ulp.exe --help`, `--version`, SQLite smoke query, provider list, and writer list pass from the extracted archive.
- [ ] PDB, assembly XML documentation, output gallery, benchmarks, tests, temporary files, and obsolete executable names are absent.
- [ ] Documentation and samples are present and links point to the release behavior.
- [ ] Package hash is recorded and published through the approved channel.
- [ ] Signature status matches the release claim.
- [ ] Upgrade and rollback are tested against the previous supported release.
- [ ] Published artifact is immutable and retrievable from the official location.

## Related Documentation

- [Installing ULP](installation.md)
- [ULP Reference](reference.md)
- Consolidated security chapter — planned; current package safety guidance appears above and in Installation
- [Developer release process](developer/RELEASING.md)
- [Developer testing](developer/TESTING.md)
- [Legal source material](legal/README.md)
