# Microsoft Visual C++ runtime provenance

The audited candidate ships ten x86 files with Microsoft Authenticode signatures and file version `14.28.29913.0`: `concrt140.dll`, `msvcp140.dll`, `msvcp140_1.dll`, `msvcp140_2.dll`, `msvcp140_atomic_wait.dll`, `msvcp140_codecvt_ids.dll`, `vcamp140.dll`, `vccorlib140.dll`, `vcomp140.dll`, and `vcruntime140.dll`.

Inspection of the shipped native SQLite files found that x86 `SQLite.Interop.dll` directly imports `VCRUNTIME140.dll` and Windows system libraries. The x64 file imports only Windows system libraries. This suggests that several copied x86 runtime files may be unnecessary, but dependency inspection alone is not sufficient removal evidence.

## Release blockers

- Identify the exact licensed Visual Studio/MSVC installation that supplied version `14.28.29913.0`.
- Preserve the applicable Microsoft Visual Studio license and REDIST list for that toolchain.
- Verify every retained filename appears on that exact redistribution list.
- Confirm all retained files are unmodified Microsoft binaries and record their hashes.
- Run the ULP package and SQLite/provider tests in a clean 32-bit environment after removing any apparently unused files.

Classification remains `review`. Installing Microsoft's official VC++ Redistributable instead of app-local DLLs is an engineering alternative, not an automatic licensing requirement.
