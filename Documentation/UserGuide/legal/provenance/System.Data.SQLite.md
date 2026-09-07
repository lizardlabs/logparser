# Modified System.Data.SQLite provenance

## Confirmed facts

- Shipped managed file: `runtime/System.Data.SQLite.dll`, version `1.0.113.0`, SHA256 `3849474ae2633ed81d93400f26c58578b5436f114bd4ca8bc4db3d951f05c4b2` in the audited candidate.
- Shipped x86 interop: `runtime/x86/SQLite.Interop.dll`, version `1.0.113.0`, SHA256 `7aa95519eef57d3e490d1f4fd67ca0f9544b2e17cf81dd42aec879aba03ba1a0`.
- Shipped x64 interop: `runtime/x64/SQLite.Interop.dll`, version `1.0.113.0`, SHA256 `1f4333f1c60129f5ae66b9368a1f7e6806eea811adb52b38da89c242638db401`.
- Project references call the managed assembly `SQLite.PLP.Modified` and load it from a local binary-only reference directory.
- Upstream System.Data.SQLite and SQLite are Public Domain; that status is not treated as a redistribution blocker.
- The inspected local reference directory contains managed/native binaries and build map/export files, but not the modified source or build instructions.
- The x86 native interop directly imports `VCRUNTIME140.dll`; the x64 native interop directly imports only Windows system libraries.

## Required provenance before release

- Exact upstream System.Data.SQLite release/check-in and SQLite core version.
- Repository or archive containing the exact modified source.
- A patch/change description and the author/owner of every ULP modification.
- Reproducible managed, x86, and x64 build commands and toolchain versions.
- Evidence tying each final binary hash to that build.
- Confirmation whether any LINQ/Entity Framework source governed by MS-PL is compiled into the shipped managed assembly.

Classification remains `review` until this evidence is supplied. No proprietary ULP source publication is implied merely by the upstream Public Domain status.
