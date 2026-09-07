# Deployment and Packaging

This chapter explains how to deploy the supported portable ULP package, automate it safely, and build a release candidate. End users should start with [Installing ULP](installation.md).

## Contents

- [Deployment Model](#deployment-model)
- [Portable Deployment](#portable-deployment)
- [Team and Server Deployment](#team-and-server-deployment)
- [Configuration and Data Locations](#configuration-and-data-locations)
- [Automation](#automation)
- [Deploying the Web Server](#deploying-the-web-server)
- [Building a Release Candidate](#building-a-release-candidate)
- [Release Artifact Layout](#release-artifact-layout)
- [Compliance and Publication Gate](#compliance-and-publication-gate)
- [Package Verification](#package-verification)
- [CI/CD Integration](#cicd-integration)
- [Future Web-Server Container](#future-web-server-container)
- [Release Checklist](#release-checklist)

## Deployment Model

ULP currently uses one supported distribution model: a complete portable Windows ZIP. The archive contains one versioned top-level folder so it can be extracted safely into a tools directory.

```text
verified release ZIP
    -> one ULP folder
        -> launcher and README at the root
        -> runtime, config, queries, web, docs, samples, skills, and legal material
```

There is no machine-wide registration step. Installation, upgrade, rollback, and removal are folder operations controlled by the user or administrator.

## Portable Deployment

1. Obtain the ZIP and checksum through the official project site.
2. Verify the checksum and any release signature.
3. Extract the complete archive to a dedicated parent directory.
4. Keep the package directory read-only where practical.
5. Store mutable configuration and output outside the package for long-lived deployments.
6. Run a smoke query before changing launchers or automation.

Example smoke test:

```powershell
& 'D:\Tools\ULP\ulp-<version>-win-anycpu\ulp.exe' `
    --query 'SELECT 42 AS deployment_test' `
    --output console --format JSON --no-env
```

Use side-by-side folders for upgrades. This avoids mixing assemblies from different releases and provides a simple rollback path.

## Team and Server Deployment

For a controlled shared deployment, separate application files from mutable operational data:

```text
D:\Applications\ULP\ulp-<version>-win-anycpu\   read-only application
D:\ULP\Queries\                                  approved saved queries
D:\ULP\Config\                                   environment configuration
D:\ULP\State\                                    logs and checkpoints
D:\ULP\Output\                                   generated results
```

Recommended controls:

- run scheduled jobs and services under a dedicated ordinary account;
- grant only the input and output permissions required by each job;
- use read-only database credentials for analysis;
- protect centrally approved queries and templates from untrusted changes;
- use explicit paths rather than relying on a service account's working directory;
- keep credentials out of command arguments and source-controlled files;
- retain the previous release until representative workloads pass.

The portable package itself does not create services, scheduled tasks, firewall rules, or PATH entries. Administrators own those external deployment choices.

## Configuration and Data Locations

For predictable automation, pass explicit locations:

```powershell
& $ulpExecutable `
    --config-dir 'D:\ULP\Config' `
    --queries-dir 'D:\ULP\Queries' `
    --input TextLine `
    --from 'D:\Data\Application\*.log' `
    --table logs `
    --query 'SELECT * FROM logs LIMIT 100'
```

Keep these categories separate:

| Category | Recommended handling |
| --- | --- |
| Application package | Immutable after verification |
| Query library | Reviewed and versioned by the operator |
| Configuration | Environment-specific and access controlled |
| Secrets | Referenced from protected external storage |
| Logs and checkpoints | Writable, retained according to policy |
| Results | Written to an explicit controlled output root |

ULP supports whole-value secret references such as `@env:`, `@file:`, and `@wincred:`. Connection strings shown in normal diagnostics are masked, but operators should still prevent arbitrary data from being logged.

## Automation

### PowerShell wrapper

Use the process exit code and preserve diagnostic output separately from result output:

```powershell
$ulp = 'D:\Applications\ULP\current\ulp.exe'
$arguments = @(
    '--no-env',
    '--config-dir', 'D:\ULP\Config',
    '--queries-dir', 'D:\ULP\Queries',
    '--command', 'daily-errors'
)

& $ulp @arguments
if ($LASTEXITCODE -ne 0) {
    throw "ULP failed with exit code $LASTEXITCODE"
}
```

### Scheduled execution

Before scheduling a query:

1. run it interactively as the intended service account;
2. use absolute paths;
3. select a non-interactive output destination;
4. set overwrite/empty-output behavior explicitly;
5. configure log rotation and checkpoint retention;
6. test cancellation, timeout, missing-input, and full-disk behavior;
7. document the expected exit code and artifacts.

Do not place passwords, API keys, or credential-bearing connection strings in scheduled-task arguments. Use protected secret references.

### Stable launch path

A small administrator-controlled launcher can point automation at the validated release folder. Change that pointer only after smoke tests, and keep rollback atomic. Do not update files inside a running release directory.

## Deploying the Web Server

The built-in web interface is part of ULP. It is separate from the static/user-guide website.

For local interactive use, keep the default localhost and HTTPS behavior. For a managed server deployment:

- use a trusted HTTPS certificate;
- require authentication;
- bind only to the intended interface;
- restrict the listener with firewall rules;
- choose the least-permissive web policy that supports the workflow;
- make the installed Query library read-only;
- disable ad-hoc SQL, editing, Shell, source display, and AI when they are not required;
- run the process under a dedicated account;
- keep query, configuration, input, and output directories explicitly mounted or assigned;
- stop the listener when it is no longer needed.

Plain HTTP is an explicit opt-in for controlled scenarios and should not carry credentials or sensitive results over an untrusted network. See [Web Interface Security](security.md#web-interface-security) and the [Web interface guide](web-interface.md).

## Building a Release Candidate

These commands are for authorized maintainers in the complete ULP workspace.

From the repository root, verify formatting, build, and tests:

```powershell
.\build.ps1 FormatCheck
.\build.ps1 Build -Configuration Release
.\build.ps1 Test -Configuration Release
```

The combined quality command formats changed C#/VB files, builds, and runs the test suite:

```powershell
.\build.ps1 Finish -Configuration Release
```

Create and validate the portable release candidate:

```powershell
.\build.ps1 Release
```

The release command:

1. builds the main application and release launcher;
2. reads the version from the built executable;
3. refreshes runtime-generated documentation;
4. stages the organized package tree;
5. copies the external user manual and legal material;
6. regenerates the dependency and material-asset inventory;
7. creates the package file manifest;
8. runs a packaged smoke query and structural checks;
9. creates the ZIP and checksum;
10. stages a review copy in the separate user-guide repository.

The packager does not commit or push either repository.

## Release Artifact Layout

The local build writes the candidate under the workspace `artifacts` directory. The ZIP contains the versioned staging directory itself:

```text
ulp-<version>-win-anycpu.zip
└── ulp-<version>-win-anycpu\
    ├── ulp.exe
    ├── README.md
    ├── config\
    ├── docs\
    ├── legal\
    ├── patterns\
    ├── queries\
    ├── runtime\
    ├── samples\
    ├── session-sql\
    ├── skills\
    └── web\
```

Only the launcher and README are at the package root. Supporting content stays grouped in named directories.

Important release evidence includes:

| File | Purpose |
| --- | --- |
| `legal/package-files.sha256` | SHA-256 for every packaged file except the manifest itself |
| `legal/dependency-inventory.csv` | Shipped binary and material-asset license status |
| `legal/THIRD-PARTY-NOTICES.txt` | Customer-facing third-party notices |
| `legal/licenses/` | Expanded third-party license texts |
| `legal/provenance/` | Component provenance and review records |
| ZIP-adjacent `.sha256` | Hash of the downloadable archive |

The separate user-guide repository receives an expanded review copy, ZIP, and checksum under `Releases/<version>/win-anycpu/`.

## Compliance and Publication Gate

Packaging fails closed when an approved ULP product license is missing or the dependency inventory contains unresolved `review` or `unmapped` items.

An internal mechanics-only candidate can be produced with:

```powershell
.\build.ps1 Release -AllowUnreviewedLicenses
```

That switch does **not** approve the license, third-party redistribution, provenance, or publication. Such a package must be marked **INTERNAL REVIEW ONLY - DO NOT PUBLISH**.

Before publication, an owner or qualified reviewer must resolve the exact blockers listed in [Legal, Licensing, Privacy, and Disclaimers](legal.md#release-approval-blockers) and the internal compliance record.

## Package Verification

Release validation should confirm all of the following:

- the archive contains exactly one top-level package folder;
- only `ulp.exe`, `README.md`, and organized directories appear at package root;
- the package starts and executes its smoke query;
- debug symbols, XML compiler sidecars, secrets, certificates, keys, and test outputs are absent;
- native SQLite files exist for the packaged architectures;
- every manifest entry exists and matches its SHA-256 value;
- every material binary/web/pattern asset is represented in the inventory;
- customer legal references resolve inside the package;
- an approved product license is present;
- no inventory row remains `review` or `unmapped`;
- the ZIP checksum matches the finished archive.

After validation, test the archive on a clean supported machine or VM using the installation instructions users will receive.

## CI/CD Integration

A release pipeline should keep validation and publication as separate stages.

### Validation stage

1. restore from approved dependency sources;
2. run formatting verification;
3. build Release;
4. run all automated tests;
5. generate and validate documentation;
6. build the package without the internal legal override;
7. scan the exact staged package;
8. verify manifest, inventory, license, and archive structure;
9. run clean-machine smoke tests.

### Approval and publication stage

1. record the source revision and dependency lock state;
2. complete owner/legal/security approval;
3. apply any required signing;
4. regenerate final hashes after signing;
5. publish the ZIP, checksum, release notes, and legal material together;
6. verify the public download independently;
7. preserve immutable release evidence.

Never make an internal-review override part of an automatic public publication job.

## Future Web-Server Container

Docker support is intentionally deferred until the portable release is stable. The planned image will run **ULP's built-in web server**, not the documentation website.

The intended container contract is:

- run ULP as a non-root user;
- mount the local Query library read-only;
- mount input data read-only whenever possible;
- use separate writable mounts for output, logs, checkpoints, and other state;
- provide configuration and secrets at runtime rather than embedding them in the image;
- expose only the web-server port;
- require authentication and protect external traffic with HTTPS, commonly through a trusted reverse proxy;
- use a read-only container filesystem apart from explicit writable mounts;
- include a health check and graceful shutdown.

No Docker command or image name is documented until a Dockerfile, entry point, mount contract, authentication flow, and end-to-end tests exist. The portable ZIP remains the supported deployment.

## Release Checklist

- [ ] Formatting, Release build, and all tests pass.
- [ ] Runtime-generated docs match the executable.
- [ ] The product license is approved and packaged.
- [ ] Dependency and material-asset reviews are resolved.
- [ ] Customer notices and license/source material are complete.
- [ ] The package manifest and ZIP checksum are regenerated.
- [ ] The ZIP extracts into one top-level folder.
- [ ] The package runs on a clean supported system.
- [ ] Credentials, keys, debug files, and private review records are absent.
- [ ] Release notes describe verified changes and known issues.
- [ ] Signing and security review are complete where required.
- [ ] Publication is an explicit owner-approved action.

## Related Documentation

- [Installing ULP](installation.md)
- [Security](security.md)
- [Versions and Release History](versions.md)
- [Legal, Licensing, Privacy, and Disclaimers](legal.md)
