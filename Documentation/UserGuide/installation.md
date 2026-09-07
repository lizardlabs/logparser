# Installing ULP

ULP is distributed as a portable Windows application. The normal installation is to download the official ZIP, verify it, and extract the complete folder. ULP does not require a machine-wide installer.

Project home: [https://log-parser.com](https://log-parser.com)

## Contents

- [Choose an Installation](#choose-an-installation)
- [Install From the Release ZIP](#install-from-the-release-zip)
- [Run ULP](#run-ulp)
- [Add ULP to PATH](#add-ulp-to-path)
- [Portable and Managed Installations](#portable-and-managed-installations)
- [Upgrade](#upgrade)
- [Uninstall](#uninstall)
- [Build in an Authorized Developer Workspace](#build-in-an-authorized-developer-workspace)
- [Verify a Download](#verify-a-download)
- [Troubleshooting](#troubleshooting)

## Choose an Installation

| Method | Best for | Status |
| --- | --- | --- |
| Official release ZIP | Most users | Supported |
| Managed copy of the release ZIP | Teams, servers, and portable toolkits | Supported |
| Developer build | Authorized maintainers with the complete workspace | Supported for development |

Use a release linked from the ULP project site. Other installation channels are not documented as supported, so do not guess package names from public registries.

## Install From the Release ZIP

### Requirements

The current desktop/CLI build requires:

- Windows;
- .NET Framework 4.8.1;
- permission to run the application and read the selected inputs;
- write permission for requested outputs, logs, configuration, or checkpoints.

Some data providers require additional access. Examples include Windows Event Log permissions, database credentials, Active Directory connectivity, and access to network files.

### Download and extract manually

1. Open [log-parser.com](https://log-parser.com) and follow the official download link.
2. Download `ulp-<version>-win-anycpu.zip` and its `.sha256` file when supplied.
3. Verify the ZIP as described in [Verify a Download](#verify-a-download).
4. Extract it into a dedicated parent folder such as `%LOCALAPPDATA%\Programs\ULP` or `D:\Tools\ULP`.
5. Open the extracted `ulp-<version>-win-anycpu` folder and run `ulp.exe` from a terminal.

The ZIP contains one top-level ULP folder. Using **Extract here** therefore creates that folder instead of placing application files throughout the current directory.

Keep the extracted folder intact. The launcher, runtime assemblies, native SQLite components, configuration, queries, web assets, documentation, samples, skills, and legal material are packaged together. Copying only `ulp.exe` can make providers or features fail.

### Download with PowerShell

On the official release page, copy the exact URL of the ZIP asset and use it below:

```powershell
$assetUrl = '<paste the official ZIP asset URL here>'
$archive = Join-Path $env:TEMP 'ulp-release.zip'
$installRoot = Join-Path $env:LOCALAPPDATA 'Programs\ULP'

curl.exe --fail --location --output $archive $assetUrl
New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
Expand-Archive -LiteralPath $archive -DestinationPath $installRoot

$ulpHome = Get-ChildItem -LiteralPath $installRoot -Directory -Filter 'ulp-*-win-anycpu' |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1

& (Join-Path $ulpHome.FullName 'ulp.exe') --version
```

`curl.exe --fail --location` follows release redirects and fails for an HTTP error instead of saving an error page as a ZIP. Do not substitute a similarly named file from an unverified mirror.

## Run ULP

Open PowerShell in the extracted folder and display the basic command help:

```powershell
.\ulp.exe --help
```

Check the installed build:

```powershell
.\ulp.exe --version
```

Run a harmless query that does not require an input file:

```powershell
.\ulp.exe --query "SELECT sqlite_version() AS sqlite_version" --output console --format Terminal
```

Open the guided menu:

```powershell
.\ulp.exe --menu
```

ULP normally uses the `config` subdirectory of the current working directory for configuration and the installed `queries` directory for saved queries. Use `--config-dir` and `--queries-dir` when scripts must not depend on the working directory.

## Add ULP to PATH

For only the current PowerShell session:

```powershell
$ulpHome = 'D:\Tools\ULP\ulp-<version>-win-anycpu'
$env:Path = $ulpHome + ';' + $env:Path
ulp --help
```

For a permanent per-user setup, add the exact extracted ULP folder to the user `Path` in **System Properties > Environment Variables**. Open a new terminal and verify:

```powershell
Get-Command ulp
ulp --help
```

Do not add a broad parent directory containing unrelated executables.

## Portable and Managed Installations

ULP does not need registry entries or machine-wide configuration. You can keep multiple installations side by side:

```text
D:\Tools\ULP\ulp-<older-version>-win-anycpu\
D:\Tools\ULP\ulp-<newer-version>-win-anycpu\
```

For a managed team deployment:

1. verify the release once in a controlled staging area;
2. copy the complete extracted folder without changing its internal layout;
3. make the application and centrally managed Query library read-only to ordinary users where appropriate;
4. keep case data, generated output, logs, configuration, and checkpoints in separate writable locations;
5. launch ULP with explicit `--config-dir` and `--queries-dir` arguments;
6. test with the same account and permissions used in production.

Example portable invocation:

```powershell
& 'D:\Tools\ULP\ulp-<version>-win-anycpu\ulp.exe' `
    --config-dir 'D:\Cases\Example\config' `
    --queries-dir 'D:\Cases\Example\queries' `
    --input TextLine --from 'D:\Cases\Example\logs\*.log' `
    --table logs --query 'SELECT * FROM logs LIMIT 50'
```

## Upgrade

Install a new ZIP beside the previous folder instead of overwriting a working installation.

1. Verify and extract the new release.
2. Compare configuration defaults before copying custom settings.
3. Preserve your own queries and templates separately when practical.
4. Run `ulp --version`, basic help, and representative queries.
5. Update `PATH`, shortcuts, scheduled tasks, or launch scripts only after validation.
6. Keep the previous folder until rollback is no longer needed.

Do not mix DLLs or native components from different release folders.

## Uninstall

1. Stop running CLI, menu, TUI, MCP, and web-server processes.
2. Remove the ULP folder from `PATH`, shortcuts, scheduled tasks, or service wrappers you created.
3. Preserve user queries, configuration, logs, checkpoints, persistent databases, and generated output that you still need.
4. Delete the exact extracted release folder.

Removing the application folder does not remove data or configuration stored elsewhere.

## Build in an Authorized Developer Workspace

This section is for authorized maintainers with the complete ULP source workspace and required sibling projects. ULP is not presented as an open-source project, and these instructions do not grant access to or rights in the source code.

### Requirements

- Windows with .NET Framework 4.8.1 developer/targeting components;
- Visual Studio or Build Tools capable of building the solution's C# and VB.NET projects;
- a compatible .NET SDK/MSBuild installation;
- restored dependencies;
- the complete private workspace layout expected by the solution;
- PowerShell for integration and packaging checks.

From the workspace root:

```powershell
.\build.ps1 Build -Configuration Debug
.\build.ps1 Test -Configuration Debug
```

Verify formatting, build, and tests together:

```powershell
.\build.ps1 Finish -Configuration Release
```

Create a release candidate only after legal and dependency review is complete:

```powershell
.\build.ps1 Release
```

Release packaging intentionally fails when required product-license or component approvals remain unresolved. The internal review override tests package mechanics only; it does not authorize publication.

See [Deployment and Packaging](deployment.md#building-a-release-candidate) for the artifact layout and release gate.

## Verify a Download

Verification confirms that the received bytes match publisher-supplied evidence. It does not make an untrusted download source trustworthy.

### SHA-256

Calculate the ZIP hash:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath .\ulp-<version>-win-anycpu.zip
```

Compare the complete hexadecimal value with the `.sha256` file or value published through an official channel. A checksum hosted only beside an archive on an untrusted mirror is not independent evidence.

### Digital signature

When a release claims Authenticode signing, inspect the launcher:

```powershell
Get-AuthenticodeSignature -LiteralPath .\ulp.exe |
    Format-List Status,StatusMessage,SignerCertificate,TimeStamperCertificate
```

Confirm the signer and timestamp against the release information. A technically valid signature from an unexpected publisher is not sufficient.

### Package contents

The extracted package includes `legal\package-files.sha256`. Release validation checks that this manifest matches the packaged files. It also checks the dependency inventory and required legal material before a publishable package can be created.

## Troubleshooting

### `ulp` is not recognized

Run the executable by explicit path first:

```powershell
.\ulp.exe --help
```

If that works, open a new terminal and inspect `PATH`:

```powershell
Get-Command ulp -ErrorAction SilentlyContinue
$env:Path -split ';'
```

### .NET Framework is missing

Install or enable .NET Framework 4.8.1 from Microsoft, then retry. A newer .NET runtime alone does not necessarily provide the .NET Framework components used by this application.

### A DLL or SQLite component is missing

Re-extract the complete ZIP. Do not run an isolated copy of the launcher and do not combine files from different releases.

### Access is denied

Use a folder where the current account can execute files and write requested output. Determine whether the selected event channel, data source, network resource, or output genuinely needs elevated rights before running as administrator.

### Windows blocks the downloaded file

Confirm the source, checksum, and claimed signature first. After verification, use the file **Properties** dialog or explicitly unblock the extracted files:

```powershell
Get-ChildItem -LiteralPath $ulpHome.FullName -Recurse -File | Unblock-File
```

Do not bypass SmartScreen or execution-policy warnings for an unverified file.

### The application starts but an input fails

Run help and the SQLite-only test query first. Then check the input path, provider options, permissions, credentials, native dependencies, and configuration directory. Use `--verbose`, `--full-errors`, or file logging for diagnostics and remove secrets before sharing logs.

## Related Documentation

- [Getting Started](getting-started.md)
- [Deployment and Packaging](deployment.md)
- [Security](security.md)
- [Troubleshooting](troubleshooting.md)
