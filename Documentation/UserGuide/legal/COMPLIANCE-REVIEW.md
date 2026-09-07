# Internal release-compliance review

This maintainer document is not the customer-facing notice and is not legal advice. A normal release must fail while a material component remains `review` or `unmapped`. Use `legal/THIRD-PARTY-NOTICES.txt` as the shipped customer-facing notice.

## Confirmed evidence

- `Microsoft.SqlServer.Types.dll` has SHA256 `30108ff222575a0fec8dec65bc92d1b0773e1429abef918d969dffeb7b5bb2ca` and exactly matches `lib/net40/Microsoft.SqlServer.Types.dll` in the signed `Microsoft.SqlServer.Types` 14.0.1016.290 NuGet package.
- `Microsoft-SQL-Server-System-CLR-Types-2017.rtf` has SHA256 `ec4d25ff42cf6244d72b4378010bcf003153bd70b2efb684871a5058ac5f6114` and exactly matches both the package license entry and Microsoft's official license download.
- Release compliance classification for Microsoft.SqlServer.Types: **approved with conditions based on the license associated with Microsoft.SqlServer.Types 14.0.1016.290**. The conditions are summarized in its provenance record; this is not a statement of legal approval.
- `TagLibSharp.dll` has SHA256 `3a842e84068734f3eaf578a0c0875b15058c194b2f205479efa867388bc5c16e` and exactly matches the net45 DLL in the official TagLibSharp 2.2.0 NuGet package. No ULP modification is present in that DLL.
- Exact TagLib# source from upstream tag `TaglibSharp-2.2.0.0` is packaged without the large test-media corpus at `source-information/TagLibSharp-2.2.0-source.zip`. It contains the library source, license, notices, key, project, solution, and build-control files.
- All ten currently staged x86 Visual C++ runtime files have valid Microsoft Authenticode signatures and file version `14.28.29913.0`.
- `SQLite.Interop.dll` imports only `VCRUNTIME140.dll` plus Windows system libraries on x86, and only Windows system libraries on x64. This observation does not by itself authorize removal of the other runtime files.
- `CodeReader.Core.dll` product metadata includes source commit `4bb413569daa590b9796554d64d242e7674928cb`; the source is under the Lizard Labs `llappbb` repository and is strong-name-signed using a Lizard Labs key. No explicit copyright assignment or product-license declaration was found in the component source.
- The shipped web assets identify DevExtreme 19.1.11, jQuery 3.5.1, and JSZip 3.3.0. DevExtreme is a distinct commercial-license review item.

## Release blockers requiring owner records or engineering provenance

- Supply and approve the ULP product license/EULA. The repository contains only a disclaimer and an unapproved EULA template.
- Record the DevExpress/DevExtreme subscription owner, licensed version, and redistribution rights for the web assets.
- Record the Visual C++ 14.28 toolchain license and the Microsoft redist-list evidence for every retained DLL; separately test whether only `vcruntime140.dll` is needed for x86 SQLite interop.
- Supply the exact modified System.Data.SQLite source revision, patch/modification record, author/owner of modifications, and build instructions.
- Confirm CodeReader.Core ownership/assignment and whether any source was copied from third parties.
- Resolve every other `review` or `unmapped` inventory entry produced from the final staging directory.

## Internal candidate rule

`-AllowUnreviewedLicenses` may create an internal review package. Such a package must contain `PRODUCT-LICENSE-REQUIRED.txt`, expose unresolved inventory states, and must not be published. The default release path remains fail-closed.

## Final audit disposition

| Question | Finding |
| --- | --- |
| Is an approved ULP product license present and valid for distribution? | **No.** The repository `LICENSE` is a disclaimer without a substantive license grant, and `EULA-TEMPLATE.md` is explicitly unapproved. This alone blocks publication. |
| Are shipped third-party notices self-contained? | **Yes for the review package.** `legal/THIRD-PARTY-NOTICES.txt`, expanded `legal/licenses`, provenance, source information, the shipped-file inventory, and the checksum manifest are packaged together. |
| Is Microsoft.SqlServer.Types resolved to the exact package/license? | **Yes, with conditions.** DLL and RTF hashes exactly match the signed 14.0.1016.290 package; all distribution conditions in the Microsoft terms still apply. |
| Is TagLib# supplied with matching source and LGPL material? | **Yes, with conditions.** The DLL exactly matches upstream 2.2.0, remains replaceable, is unmodified, and matching library/build source plus LGPL-2.1 is included. Product terms must preserve LGPL replacement/debugging rights. |
| Is modified System.Data.SQLite provenance complete? | **No.** Exact modified source, patch record, owner, reproducible build steps, and native relationship remain unrecorded. |
| Is Visual C++ redistribution substantiated? | **No.** Signatures/version/import analysis are recorded, but the licensed toolchain and applicable Microsoft redist-list evidence are missing. |
| Is CodeReader.Core ownership substantiated? | **Not conclusively.** Repository, commit, signer context, and author evidence strongly suggest a first-party component, but explicit ownership/assignment and copied-code confirmation are absent. |
| Are non-.NET web/pattern assets reviewed? | **Inventoried.** jQuery, JSZip, Grok files, ULP assets, and DevExtreme JS/CSS/fonts are mapped. DevExtreme redistribution and favicon ownership remain unresolved. |
| Does the final manifest cover all shipped files? | **Yes for the generated review artifact.** Packaging verifies each file hash, detects missing/duplicate manifest paths, and requires inventory rows for runtime DLLs, web assets, and Grok files. |
| Is the current artifact publishable? | **No.** It is an internal review artifact created with `-AllowUnreviewedLicenses`; its unresolved inventory states and product-license marker intentionally prevent publication. |
| What owner actions remain? | Approve a product license/EULA; document DevExtreme redistribution rights and favicon ownership; provide modified SQLite source/build provenance; record Visual C++ toolchain/redist evidence and trim unneeded runtimes after testing; confirm CodeReader.Core ownership; then regenerate and pass packaging without the override. |

Automated release-compliance checks completed. Remaining business/legal approvals, if any, are listed explicitly above.
