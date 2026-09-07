# TagLib# provenance and source availability

| Field | Evidence |
| --- | --- |
| Component | TagLib# / `TagLibSharp` |
| Exact version | `2.2.0` (assembly `2.2.0.0`) |
| Upstream release tag | `TaglibSharp-2.2.0.0` |
| Upstream release commit | `13a3e95` (short identifier displayed by the upstream release) |
| Official package | `https://www.nuget.org/packages/TagLibSharp/2.2.0` |
| Source repository | `https://github.com/mono/taglib-sharp` |
| License | LGPL-2.1-only; `../licenses/LGPL-2.1.txt` |
| Shipped file | `runtime/TagLibSharp.dll` |
| Purpose | Media-file metadata reading |
| Modified by ULP | No; the shipped DLL exactly matches the official package's net45 DLL |
| Shipped/package DLL SHA256 | `3a842e84068734f3eaf578a0c0875b15058c194b2f205479efa867388bc5c16e` |
| Corresponding source | `../source-information/TagLibSharp-2.2.0-source.zip` |
| Source archive SHA256 | `282cc9b36c36c43aa420d420834e631d3d42d80bf29bc44735512e8d03db5e8c` |

ULP ships TagLib# as a separate replaceable dynamic library. The source archive contains the library source and the files needed to build it from the exact upstream tag; large test-media fixtures and examples that are not needed to build the library are omitted. The ULP product terms must not prohibit rights required for debugging changes to, or using an interface-compatible modified replacement for, this LGPL library.

This mechanism does not make ULP source code subject to the LGPL. It preserves the separate library's license, notices, replacement model, and exact corresponding source alongside the release.
