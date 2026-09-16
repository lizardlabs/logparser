# Universal Log Parser — Open Source Software Notices

This notice covers third-party components observed in the ULP Release output. Versions come from `packages.config` or assembly product metadata. Run `legal/generate-dependency-inventory.ps1` after every dependency/build change; its CSV is the authoritative binary-level snapshot.

This inventory is an engineering compliance aid, not legal advice. Entries marked **REVIEW** must be cleared before a commercial release.

`licenses/MIT.txt` is the shared MIT permission text and points back to the component-specific copyright holders in this notice. It is no longer an evtx-specific license mislabeled as the license for every MIT dependency. Components whose upstream license contains extra notices have their own file.

## Direct application dependencies

| Project | Version | Project / license | Copyright | Redistribution notes |
| --- | --- | --- | --- | --- |
| AWS SDK for .NET | 3.3.0.x | [project](https://github.com/aws/aws-sdk-net), [Apache-2.0](licenses/Apache-2.0.txt) | Amazon.com, Inc. or affiliates | Include Apache license and applicable notices. |
| CsvHelper | 33.0.1 | [project](https://joshclose.github.io/CsvHelper/), Apache-2.0 OR MS-PL | Josh Close, 2009–2024 | ULP elects Apache-2.0; include license/notices. |
| DocumentFormat.OpenXml | 2.12.3 | [project](https://github.com/dotnet/Open-XML-SDK), [MIT](licenses/MIT.txt) | Microsoft Corporation | Preserve copyright and permission notice. |
| ExcelDataReader | 3.6.0 | [project](https://github.com/ExcelDataReader/ExcelDataReader), [MIT](licenses/MIT.txt) | ExcelDataReader developers | Preserve copyright and permission notice. Used for driver-free `.xlsx`, `.xlsm`, and `.xls` input. |
| Markdig | 0.41.1 | [project](https://github.com/xoofx/markdig), [BSD-2-Clause](licenses/BSD-2-Clause.txt) | Alexandre Mutel | Preserve copyright, conditions, and disclaimer. |
| Microsoft .NET / Extensions libraries | 8.0.0–10.0.0 previews; mostly 9.0.4 | [dotnet](https://github.com/dotnet/runtime), [MIT](licenses/MIT.txt) | Microsoft Corporation | Preserve MIT notice. Preview dependencies should also receive product/security review. |
| Model Context Protocol C# SDK | 0.1.0-preview.13 | [project](https://github.com/modelcontextprotocol/csharp-sdk), [MIT](licenses/MIT.txt) | Anthropic and contributors | Preserve MIT notice; preview API stability review recommended. |
| Newtonsoft.Json | 13.0.3 | [project](https://github.com/JamesNK/Newtonsoft.Json), [MIT](licenses/MIT.txt) | James Newton-King | Preserve MIT notice. |
| PdfPig | 0.1.16 | [project](https://github.com/UglyToad/PdfPig), [Apache-2.0](licenses/Apache-2.0.txt) | PdfPig, Apache PDFBox/FontBox, and contributors | Used for PDF text-layer extraction. Preserve the Apache license and [upstream attribution notices](licenses/PdfPig-NOTICES.txt). |
| Scriban | 7.2.6 | [project](https://github.com/scriban/scriban), [BSD-2-Clause](licenses/BSD-2-Clause.txt) | Alexandre Mutel | Source is compiled into the ULP common assembly; preserve the BSD notice and disclaimer. |
| Spectre.Console | 0.49.1 | [project](https://github.com/spectreconsole/spectre.console), [MIT](licenses/MIT.txt) | Spectre.Console contributors | Preserve MIT notice. |
| System.Data.SQLite | 1.0.113.0, locally modified build | [project](https://system.data.sqlite.org/), Public Domain | SQLite/System.Data.SQLite contributors | No standard attribution obligation; **REVIEW** provenance and local modifications against the shipped native interop binaries. |
| Terminal.Gui / NStack | 1.0.0-beta.10.34 / 1.0.0 | [project](https://github.com/gui-cs/Terminal.Gui), [MIT](licenses/MIT.txt) | Novell Inc., Microsoft Corporation, contributors | Preserve MIT notice. This build is referenced from a local checkout, so release provenance must be recorded. |
| YamlDotNet | 16.3.0 | [project](https://github.com/aaubry/YamlDotNet), [MIT](licenses/MIT.txt) | Antoine Aubry and contributors | Preserve MIT notice. |

## Transitive/runtime components in the Release folder

| Project | Observed version | License | Redistribution notes |
| --- | --- | --- | --- |
| Crc32.NET | 1.2.0.5 | MIT | Copyright (c) 2016 force; preserve notice. |
| DeviceDetector.NET | 4.2.0 | Apache-2.0 | Preserve Apache license/notices. |
| Eric Zimmerman evtx parser | 1.0.1.1 | [MIT](licenses/Eric-Zimmerman-Evtx-MIT.txt) | Copyright (c) 2019 Eric Zimmerman; exact source license preserved from the local upstream checkout. |
| FluentValidation | 8.6.3 | Apache-2.0 | Preserve Apache license/notices. |
| Humanizer | 2.7.9 | [MIT plus bundled notices](licenses/Humanizer-MIT.txt) | Copyright (c) .NET Foundation and Contributors; also preserve the Inflector and ByteSize notices included by upstream. |
| LiteDB | 4.1.4 | MIT | Copyright (c) 2014–2022 Mauricio David; preserve notice. |
| Apache log4net | 1.2 | Apache-2.0 | Preserve Apache license/notices. |
| MarkdownLog | 0.9.0 | MIT | Copyright 2014 BlackJet Software Ltd; preserve notice. |
| SharpCompress | 0.24.0 | MIT | Copyright (c) 2014 Adam Hathcock; preserve notice. |
| UAParser | 3.1.44 | Apache-2.0 | Preserve Apache license/notices. |
| YAXLib | 2.14 | MIT | Copyright 2009–2013 Sina Iravanian; preserve notice. |
| TagLib# | 2.2.0 | [LGPL-2.1-only](licenses/LGPL-2.1.txt) | **APPROVED WITH CONDITIONS:** the unmodified, replaceable DLL exactly matches the upstream package. Matching library/build source and LGPL terms are shipped under `source-information` and `licenses`; product terms must preserve LGPL replacement and debugging rights. |
| Microsoft.SqlServer.Types | 14.0.1016.290 | [Microsoft System CLR Types for Microsoft SQL Server 2017 terms](licenses/Microsoft-SQL-Server-System-CLR-Types-2017.rtf) | **APPROVED WITH CONDITIONS:** shipped DLL and license exactly match Microsoft's signed package. Preserve notices and comply with all distribution, platform, trademark, indemnity, and excluded-license conditions summarized in the provenance record. |
| Microsoft Visual C++ runtime binaries | 14.x family | Microsoft Visual C++ redistributable terms | **REVIEW:** confirm the build toolchain grants redistribution and ship the applicable Microsoft terms. |
| CodeReader.Core | 1.0.0 | Provenance not recorded here | **REVIEW:** local-source dependency with no license declaration found. Classify it as a documented Lizard Labs-owned product component, add the actual third-party terms, or replace/remove it before release. |

`LizardLabs.*`, `LplInputFormats.dll`, and ULP assemblies are product components and belong under the product license, not an open-source license, provided Lizard Labs owns or has licensed all included code.

## Commercial-suitability finding

The MIT, BSD-2-Clause, Apache-2.0, MS-PL, and Public Domain entries are generally permissive and commonly suitable for commercial distribution when their notice obligations are met. No GPL/AGPL component was found. TagLib# is LGPL-2.1-only and has an implemented dynamic-library/source compliance path; Microsoft.SqlServer.Types is proprietary and approved with conditions for the exact audited package. Modified/prebuilt components and commercial web assets still need the provenance decisions identified above. Do not treat this engineering conclusion as legal approval.
