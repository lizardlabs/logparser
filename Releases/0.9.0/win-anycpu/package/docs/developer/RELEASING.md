# Release packaging

Build and package the Windows AnyCPU distribution from the `PortableLogParser` directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\pack-release.ps1
```

The script builds Release and the package launcher, reads the version from the application executable, and creates three local artifacts:

- the unpacked review directory `artifacts/ulp-<version>-win-anycpu`;
- `artifacts/ulp-<version>-win-anycpu.zip`;
- `artifacts/ulp-<version>-win-anycpu.zip.sha256`.

The package root contains only `ulp.exe` and `README.md`. The launcher starts the application from `runtime`; configuration, documentation, legal material, patterns, queries, samples, session SQL, and optional AI-agent skills use separate top-level directories.

Release packaging reads the user manual and product license from the separate `lizardlabs/logparser` checkout, regenerates only the runtime-owned generated reference, and stages review artifacts under `Releases/<version>/<platform>/`. It never commits or pushes. The installed Grok catalog, explicit session-initialization examples, and compatible-agent skill instructions are validated as required package content.

Use `-SkipBuild` only after a successful Release build. The package contains both x86 and x64 SQLite native components because the managed executable is AnyCPU.

Local builds generate a manual writer gallery under `bin\<Configuration>\output-gallery`. Packaging explicitly excludes this build-only directory. For a fast or CI build that does not need the gallery, use `dotnet build ... -p:RunOutputGallery=false`.

During staging, the script regenerates `legal/dependency-inventory.csv` from every binary in the filtered package `runtime` directory. Excluded build outputs and satellite resources are absent from the shipped-binary inventory. Packaging fails when any shipped binary is `review` or `unmapped`; resolve those rows and update the license map/notices before publishing.

The same generated inventory replaces `Documentation/UserGuide/legal/dependency-inventory.csv` in the selected guide checkout and its packaged manual copy. This keeps the public guide, direct package legal folder, and actual shipped runtime synchronized.

`-AllowUnreviewedLicenses` exists only to smoke-test staging and ZIP mechanics. An archive produced with that switch is not a legally approved release and must not be published.

Every packaging run executes `Tests/Test-ReleasePackage.ps1`. It verifies the two-file root, required directories, forbidden diagnostic/secret files, every staged SHA-256 entry, archive parity, a real `SELECT 42` query, and fresh analysis-database initialization through the packaged launcher. Do not publish when that validation fails.
