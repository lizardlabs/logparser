# Installing ULP

This chapter describes the supported portable installation, source-build workflow, upgrade and removal practices, and package verification. It also records the status of common Windows distribution channels so that an unpublished package is never mistaken for an official release.

Project home: [https://log-parser.com](https://log-parser.com)

## Contents

- [Choosing an Installation Method](#choosing-an-installation-method)
- [Download and Unzip](#download-and-unzip)
- [Portable Installation](#portable-installation)
- [Chocolatey](#chocolatey)
- [WinGet](#winget)
- [Windows Installer](#windows-installer)
- [NuGet](#nuget)
- [Build From Source](#build-from-source)
- [Verifying Downloads](#verifying-downloads)
- [Troubleshooting Installation](#troubleshooting-installation)

## Choosing an Installation Method

Use only a package published or linked by the ULP publisher. A package name found in a public registry is not proof that it belongs to this project.

| Method | Best for | Current documentation status |
| --- | --- | --- |
| Download and unzip | Most users; a complete ready-to-run release | Supported release-package layout |
| Portable installation | Side-by-side versions, removable tools, no machine-wide changes | Supported |
| Chocolatey | Managed command-line installation and upgrades | No publisher-approved package information in this source tree |
| WinGet | Windows package-manager installation | No publisher-approved manifest information in this source tree |
| Windows Installer | Managed desktop or enterprise installation | No installer project or approved product code documented here |
| NuGet | Embedding a library in a .NET application | No supported ULP SDK package ID documented here |
| Build from source | Contributors and maintainers with the complete source workspace | Supported for development; see prerequisites |

The absence of a command in this chapter is intentional. Do not guess a Chocolatey ID, WinGet ID, installer URL, NuGet package ID, repository URL, or signing identity. Add those details only after the publisher has created and verified the corresponding distribution channel.

## Download and Unzip

### Requirements

The current ULP executable targets:

- Windows;
- .NET Framework 4.8.1;
- x86 or x64 through an AnyCPU managed executable and packaged native SQLite components.

You also need permission to extract files, run the executable, read the selected input, and write any requested output. Some providers require additional permissions or services, such as Windows Event Log access, Active Directory connectivity, or network access.

### Download

Start from the [ULP project home](https://log-parser.com) and follow its current download instructions. If a release is provided as `ulp-<version>-win-anycpu.zip`, download the archive and its separately published `.sha256` file from the same official release.

You can download in a browser and extract manually, or use PowerShell. On the release page, copy the exact ZIP asset URL, then run:

```powershell
$version = '0.9.0'
$downloadUrl = '<paste the ZIP asset URL from the official release page>'
$archive = Join-Path $env:TEMP "ulp-$version-win-anycpu.zip"
$installRoot = Join-Path $env:LOCALAPPDATA 'Programs\ULP'

curl.exe --fail --location --output $archive $downloadUrl
Expand-Archive -LiteralPath $archive -DestinationPath $installRoot

$ulpHome = Join-Path $installRoot "ulp-$version-win-anycpu"
& (Join-Path $ulpHome 'ulp.exe') --version
```

Do not paste an asset URL from an unofficial mirror. `curl.exe --fail --location` follows the release redirect and stops on an HTTP error instead of saving an error page as if it were the ZIP.

Do not download a similarly named executable from an unverified mirror. See [Verifying Downloads](#verifying-downloads) before running a package obtained outside a controlled internal distribution system.

### Extract

The archive already contains one versioned top-level folder. Choose its parent directory and expand the complete archive:

```powershell
$installRoot = Join-Path $env:LOCALAPPDATA 'Programs\ULP'
New-Item -ItemType Directory -Path $installRoot -Force
Expand-Archive -LiteralPath .\ulp-0.9.0-win-anycpu.zip -DestinationPath $installRoot
$ulpHome = Join-Path $installRoot 'ulp-0.9.0-win-anycpu'
```

Replace the example version and archive name with the release you downloaded.

Keep the extracted directory intact. ULP depends on DLLs, configuration, documentation, query recipes, native SQLite components, and other packaged files beside `ulp.exe`. Copying only the executable can cause startup or provider failures.

### Run

Open PowerShell in the extracted directory and display basic help:

```powershell
Set-Location $ulpHome
.\ulp.exe --help
```

Display version and application information through the available help/about command for that release, then run a harmless SQLite query:

```powershell
.\ulp.exe --query "SELECT sqlite_version() AS sqlite_version" --output console --format Terminal
```

Open the guided menu:

```powershell
.\ulp.exe --menu
```

If Windows blocks the file because it came from the internet, inspect the file's origin and signature before removing the block. After verification, files in a trusted downloaded archive can be unblocked explicitly:

```powershell
Get-ChildItem -LiteralPath $ulpHome -Recurse -File | Unblock-File
```

Do not use `Unblock-File` as a substitute for verifying the source and package.

### Add to PATH

Adding ULP to `PATH` lets you run `ulp` from another directory. For the current PowerShell session only:

```powershell
$env:Path = $ulpHome + ';' + $env:Path
ulp --help
```

For a persistent user-level installation, add the exact ULP directory to the user `Path` through **System Properties > Environment Variables**. A scripted update should preserve the existing value and avoid adding duplicates. Open a new terminal afterward and verify:

```powershell
Get-Command ulp
ulp --help
```

Avoid adding a broad parent directory containing unrelated executables.

### Upgrade

For a portable ZIP installation, install the new release into a new versioned directory:

```text
%LOCALAPPDATA%\Programs\ULP\ulp-<old-version>-win-anycpu\
%LOCALAPPDATA%\Programs\ULP\ulp-<new-version>-win-anycpu\
```

Then:

1. verify the new package;
2. copy only intentional user configuration, Query library changes, and templates;
3. compare configuration changes instead of overwriting new defaults blindly;
4. run `ulp --help` and one representative query;
5. update `PATH` or your launcher to the new directory;
6. retain the previous version until the new version is validated.

Do not merge old DLLs into a new release directory. Side-by-side directories make rollback predictable.

### Uninstall

For an extracted ZIP installation:

1. stop running ULP shells, menus, MCP servers, and web servers;
2. remove the ULP directory from `PATH` or any launcher;
3. preserve Query library files, configuration, templates, logs, checkpoints, or generated output that you still need;
4. delete the exact version directory.

ULP can also use configuration in a working directory's `config` subdirectory. Removing the application directory does not remove files you created elsewhere.

## Portable Installation

A portable installation is the same complete release layout without machine-wide registration. It is useful for side-by-side testing, incident-response toolkits, controlled servers, and removable media.

### Install

Extract the complete release into a dedicated folder, for example:

```text
D:\Tools\ULP\ulp-<version>-win-anycpu\
```

Run the executable by explicit path:

```powershell
& 'D:\Tools\ULP\ulp-<version>-win-anycpu\ulp.exe' --help
```

Use a working directory appropriate for the investigation. By default, ULP looks for application/provider/writer defaults in a `config` subdirectory of the current working directory, while the installed Query library is normally beside `ulp.exe`. Use explicit `--config-dir` and `--queries-dir` values when a portable workflow must not depend on the current directory.

Example:

```powershell
& 'D:\Tools\ULP\ulp-<version>-win-anycpu\ulp.exe' `
    --config-dir 'D:\Cases\Example\config' `
    --queries-dir 'D:\Cases\Example\queries' `
    --input TextLine --from 'D:\Cases\Example\logs\*.log' `
    --table logs --query 'SELECT * FROM logs LIMIT 50'
```

### Upgrade

Extract the new portable release beside the old one. Reapply only reviewed settings and custom queries. Test the new version before changing scripts or shortcuts.

### Remove

Stop any running process, preserve user-created files, and remove the exact portable directory. If you created shortcuts, scheduled tasks, environment variables, firewall rules, or service wrappers separately, remove those separately; extracting ULP does not create them automatically.

## Chocolatey

The current source tree does not contain a publisher-approved Chocolatey package definition or verified package ID. No `choco install` command is documented yet.

### Install

When an official package is published, this section must record:

- the exact package ID and official package page;
- the publisher/maintainer identity;
- whether the package downloads or embeds the release archive;
- checksum and signature verification behavior;
- supported installation scope.

Until then, use the verified ZIP installation.

### Upgrade

An upgrade command will be documented only after the package ID and upgrade behavior are tested against an official package.

### Uninstall

An uninstall command will be documented only after removal behavior, retained configuration, and package-manager metadata are verified.

### Verify Package

Before documenting a future Chocolatey package, verify its nuspec, install/uninstall scripts, download URL, checksum, archive contents, PATH changes, and publisher ownership. Package configuration belongs under `packaging/chocolatey`; the user instructions remain in this chapter.

### Troubleshooting

Do not install an unofficial package merely because its name resembles ULP. Use the portable release until the project site identifies an approved Chocolatey package.

## WinGet

The current source tree does not contain a publisher-approved WinGet manifest or verified package identifier.

### Install

No `winget install` command is documented. A future instruction must use the exact verified ID and should include `winget show <verified-id>` so users can inspect the publisher, source, installer type, and version before installation.

### Upgrade

Document the upgrade command only after the official manifest's version matching and installer behavior have been tested.

### Uninstall

Document the uninstall command only after the official package has a stable identifier and verified cleanup behavior.

## Windows Installer

The current source tree does not include a publisher-approved MSI/EXE installer project or product code. The ZIP release is the documented installation method.

### Install

When an installer is published, document its official download location, UI choices, installation scope, default directory, PATH behavior, shortcuts, certificate/signature, and retained user data.

### Silent Installation

Do not invent silent switches. Record only switches tested against the released installer, including exit codes and logging options.

### Upgrade

Document supported in-place and side-by-side upgrade behavior after the installer upgrade code and migration rules are verified.

### Repair

Document repair behavior only if the released installer registers it.

### Uninstall

Document the verified Apps & Features and silent removal paths, including which configuration or user data is preserved.

## NuGet

ULP is currently documented as an application, not as a supported public SDK package. The source tree does not identify an official NuGet package ID for embedding ULP in another application.

### Install Package

No `dotnet add package` or `Install-Package` command is documented until a supported package is published.

### PackageReference

A future example must use the publisher-approved package ID and version and must distinguish a stable public API from application-internal assemblies.

### Basic .NET Example

Do not reference internal classes or interfaces in user documentation. Add an example only after a supported public .NET entry point and compatibility policy exist.

## Build From Source

Building from source is intended for contributors and maintainers. The current project uses classic .NET Framework project files and references related source projects in the maintainer workspace. A standalone public source bundle must include or replace those dependencies before these instructions can be considered a clean-room public build recipe.

### Requirements

- Windows with .NET Framework 4.8.1 developer/targeting components;
- a current Visual Studio or Build Tools installation capable of building .NET Framework C# and VB.NET projects;
- a .NET SDK/MSBuild version compatible with the project;
- restored package dependencies;
- all repository and sibling source dependencies expected by the solution;
- PowerShell for integration tests and release packaging.

### Clone

Use the repository URL supplied by the project owner:

```powershell
git clone <repository-url>
Set-Location <repository-directory>
```

`<repository-url>` and `<repository-directory>` are placeholders. They must be replaced with an official source location; this documentation does not invent one.

### Build

From the source workspace containing `PortableLogParser/UniversalLogParser.csproj`:

```powershell
dotnet build .\PortableLogParser\UniversalLogParser.csproj -c Debug
```

For a release build:

```powershell
dotnet build .\PortableLogParser\UniversalLogParser.csproj -c Release
```

Local builds normally generate an output-writer gallery after compilation. For a fast or CI build that does not need manual gallery artifacts:

```powershell
dotnet build .\PortableLogParser\UniversalLogParser.csproj -c Debug -p:RunOutputGallery=false
```

### Test

Run the integration suite from the project directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\PortableLogParser\Tests\run-tests.ps1
```

See the [developer testing guide](developer/TESTING.md) for focused tests and prerequisites.

### Run

After a Debug build:

```powershell
.\PortableLogParser\bin\Debug\ulp.exe --help
```

Build the release ZIP from the `PortableLogParser` project directory:

```powershell
Set-Location .\PortableLogParser
powershell -NoProfile -ExecutionPolicy Bypass -File .\pack-release.ps1
```

Release packaging regenerates the dependency inventory and intentionally fails when license-review entries are unresolved. A bypass intended for internal package-content testing is not approval to publish an archive.

## Verifying Downloads

Verification confirms that the file you received matches publisher-supplied evidence. It does not make an untrusted source trustworthy by itself.

### SHA256

Calculate a SHA-256 digest:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath .\ulp-0.9.0-win-anycpu.zip
```

Compare the complete hexadecimal value with a checksum published through an official channel. Do not rely on a checksum hosted only beside an archive on an untrusted mirror.

### Digital Signatures

Inspect an executable's Authenticode status:

```powershell
Get-AuthenticodeSignature -LiteralPath .\ulp.exe | Format-List Status,StatusMessage,SignerCertificate,TimeStamperCertificate
```

An expected result depends on the release's documented signing policy. This source documentation does not claim a signer identity or signature status without a verified release artifact. Check that the signer, timestamp, certificate chain, filename, and release channel match publisher guidance.

### Virus/Antivirus Information

Antivirus products can disagree, and a scan result can change as definitions change. The documentation must not claim that a package was scanned or declared clean unless it links to evidence for the exact release artifact and hash.

If local policy permits external scanning, remember that uploading an internal or unpublished binary to a third-party service shares that file with the service. Follow organizational rules before uploading software or case data.

## Troubleshooting Installation

### `ulp` is not recognized

Run by explicit path first:

```powershell
.\ulp.exe --help
```

If that works, inspect command resolution and `PATH`:

```powershell
Get-Command ulp -ErrorAction SilentlyContinue
$env:Path -split ';'
```

Open a new terminal after changing persistent environment variables.

### Windows reports that .NET Framework is missing

Install or enable .NET Framework 4.8.1 from an official Microsoft source, then retry. A newer .NET runtime alone is not necessarily a substitute for the .NET Framework targeting/runtime components used by this application.

### A DLL or native SQLite component is missing

Re-extract the complete release. Do not run an isolated copy of `ulp.exe`, and do not mix files from different ULP versions.

### Access is denied

Use a directory where your account can execute files, and write output to a directory where it has write permission. Elevation should not be the first response; determine whether the selected event channel, source, output directory, certificate store, or network resource actually requires additional rights.

### Windows blocks the downloaded file

Confirm the source, checksum, and signature first. Then use the file Properties dialog or `Unblock-File` for the verified archive/extracted files. Do not bypass SmartScreen or execution policy warnings for an unverified download.

### The application starts but a provider fails

Run basic help and a SQLite-only query first. Then check provider-specific requirements, source paths, permissions, architecture-dependent dependencies, and configuration. Use `--verbose`, `--full-errors`, or file logging when collecting diagnostic information, and mask secrets before sharing logs.

### A source build cannot find related projects

The current maintainer project references related source projects outside the immediate ULP project directory. Confirm that you have the complete supported source workspace and expected relative layout. Do not replace missing dependencies with arbitrary binaries from the internet.

### Package-manager instructions are missing

That means the distribution channel has not been verified in this documentation. Use the portable ZIP method linked from the official project site rather than guessing a registry package name.
