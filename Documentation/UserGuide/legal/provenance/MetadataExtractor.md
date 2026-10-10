# MetadataExtractor and XmpCore provenance

| Component | Exact package | Source and license |
| --- | --- | --- |
| MetadataExtractor | 2.9.1, netstandard2.0 | [release source/license](https://github.com/drewnoakes/metadata-extractor-dotnet/tree/2.9.1); Apache-2.0 |
| XmpCore | 6.1.10.1, netstandard2.0 | [upstream](https://github.com/drewnoakes/xmp-core-dotnet); Adobe BSD-3-Clause |

ULP consumes the unmodified NuGet DLLs. MetadataExtractor package source revision: `6f89263748e0fbf6a4b543dc65e6af8c1e924d2f`. XmpCore is a .NET port of Adobe's XMP SDK by Yakov Danila and Nathanael Jones, maintained by Drew Noakes and contributors. Its upstream README declares the same BSD license as Adobe's SDK; the old Adobe license URL in the NuGet manifest is no longer available. The current official Adobe BSD-3-Clause text is preserved together with upstream copyright attribution.

Retained texts: [MetadataExtractor license and dependency notice](../licenses/MetadataExtractor-Apache-2.0.txt), [Adobe BSD license](../licenses/XmpCore-Adobe-BSD-3-Clause.txt). Exact shipped DLL versions and SHA256 hashes are generated into [the inventory](../dependency-inventory.csv) from the final release output. No library sources need to be included in this package under the selected permissive distribution terms.
