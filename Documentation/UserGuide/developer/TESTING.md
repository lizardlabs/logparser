# Testing

## Repository build command

Run the repository command from the solution root. It provides one consistent entry point for builds, tests, formatting, verification, and release packaging:

```powershell
.\build.ps1 Build
.\build.ps1 Test
.\build.ps1 Format
.\build.ps1 FormatCheck
.\build.ps1 Finish
.\build.ps1 Release
```

`Format` applies the shared `code-style.editorconfig` rules to C# and Visual Basic code. `FormatCheck` verifies the rules without changing files. To limit either command, pass one or more files or directories with `-SourcePath`. `Directory.Build.props` loads the same rules for command-line builds and compatible IDEs.

`Finish` is intended for the end of a development session. It formats changed C# and Visual Basic files, builds ULP, and runs the test suite. Supplying `-SourcePath` limits formatting to the files from the current task. `Build` remains non-mutating and does not silently rewrite source code.

Use `-Configuration Release` where applicable, `-NoRestore` for a build that must reuse restored packages, and `-AllowUnreviewedLicenses` only when intentionally creating a release package with unresolved license-review entries.

The repository includes a PowerShell integration runner that exercises the compiled executable rather than mocking the query engine.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1
```

From the repository root use `-File .\PortableLogParser\tests\run-tests.ps1`. Add `-SkipBuild` to reuse an existing Debug build or `-Configuration Release` for a Release build.

Documentation can also be checked independently without building ULP:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\PortableLogParser\Tests\Test-Documentation.ps1
```

The documentation check validates local links and heading anchors, local tables of contents for the manual chapters, Markdown table structure, chapter-size and file-grouping policies, and accidental exposure of internal implementation names in end-user pages. Generated reference files are checked as link targets but are not treated as hand-written chapters.

Release packaging invokes its own staged-package validator automatically. To recheck an existing review directory and ZIP directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\PortableLogParser\Tests\Test-ReleasePackage.ps1 `
    -PackageDirectory .\artifacts\ulp-<version>-win-anycpu `
    -ArchivePath .\artifacts\ulp-<version>-win-anycpu.zip
```

It verifies that only `ulp.exe` and `README.md` are files at package root, checks the organized directory layout, rejects diagnostics and key/certificate formats, verifies the per-file checksum manifest and ZIP contents, and runs a real SQLite smoke query through the packaged launcher.

The suite covers help aliases, both Common query-builder models, Format/Destination and Writer compatibility syntax, namespaced settings, environment and secret references, ParsingModule SQL, provider-neutral ADO.NET execution, Scriban generation and path safety, ordered wildcard SQL files, joins, aggregates, recursive CTEs, SQL-shell commands, batch conditions, output fan-out, atomic files, documentation, writers, and Excel. A compiled scheduler harness verifies bounded parallelism, queued release, success/failure states, running and queued cancellation, statistics, interactive-output rejection, output collisions, and partial-file cleanup. Windows Credential Manager, live external database servers, live EVT access, clipboard integration, and the full-screen Text User Interface (TUI) require machine-specific or interactive tests.

Temporary files are restricted to a unique directory below `tests` and are removed in a guarded `finally` block. The runner prints one PASS or FAIL line per case and returns a nonzero process exit if any case fails.

## Manual writer gallery

`Build-OutputGallery.ps1` creates representative files for every noninteractive file writer. It is invoked after local builds and can also be run directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Tests\Build-OutputGallery.ps1 -Configuration Release -Executable .\bin\Release\ulp.exe
```

Use `-OutputDirectory` to select another exact gallery directory, `-SkipEventLog` on machines without Windows Event Log access, and `-Strict` to turn skips into failures. The gallery includes a three-result query so the Excel file can be reviewed as a multi-sheet workbook and HTML as a multi-section document. Validation includes workbook parts, worksheet counts/IDs, and A1 cell references; generated files are intentionally retained for visual inspection. Pass `-p:RunOutputGallery=false` to `dotnet build` for CI or a fast build. Gallery output is build-only and release packaging excludes it.
