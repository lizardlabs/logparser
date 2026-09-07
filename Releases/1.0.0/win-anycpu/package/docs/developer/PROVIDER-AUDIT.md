# Repository-local input provider audit

The public provider catalog is intentionally explicit. A source file or compiled type is not automatically a supported provider.

## Registered providers

The catalog currently exposes the tested implementations for Windows events, structured text, generated rows, filesystem metadata, source code, Excel, Active Directory, and system snapshots. Helper language readers for C#, VB.NET, Razor, HTML, JavaScript, TypeScript, and Markdown are reached only through the `SourceCode` provider. They are not separate configuration surfaces.

`RegEx` uses the current Grok-capable multi-file reader. `FileSystem` owns optional media metadata. The C#, JavaScript, TypeScript, HTML, and Markdown reader types are implementation components of `SourceCode`, not additional provider candidates.

## Audited exclusions

| Candidate | Decision | Reason |
| --- | --- | --- |
| `HtmlTableReader` | Do not register | Uses regular expressions as an HTML parser, assumes the first file when constructing columns, stops after a second-file sentinel, can index past uneven rows, contains corrupted entity replacements, performs unbounded URL downloads, and throws from its provider type-code method. The structural `SourceCode` HTML reader is not a tabular replacement. A future HTML-table provider should use a maintained HTML parser and its own corpus. |
| `RegularExpressionEnhanced` | Do not register separately | Duplicates the public purpose and a large configuration surface already covered by the tested `RegEx` provider. Registering both would create two competing behaviors for the same workflow. |
| `Deprecated\RegexInputFormat` | Do not register | Superseded by `RegEx` and throws from its provider type-code method. |
| `Deprecated\TextFileInput` | Do not register | Superseded by `TextLine`, `TextWord`, `Delimiter`, and `RegEx`; it throws from its provider type-code method. |
| `Deprecated\Log4Net` | Do not register | Superseded by the maintained `log4jXML` reader and configurable `RegEx` provider. It has no current corpus or supported configuration contract. |
| `Deprecated\FacebookFqlDataSource` | Do not register | Its data-access members and provider type-code method are placeholders that throw. The external service is outside the current product scope. |
| `OtherDataSources\LogTypeTransactSQL` and `LogTypeOleDB` | Not providers | These are uncompiled option holders, do not implement the provider contract, and have no enumeration or schema behavior. Database connectivity belongs in a separately designed provider with secret handling, cancellation, and integration tests. |
| `TextRecrodInputFormat` and `DelimiterInputFormat.underconstruction` | Do not compile or register | Repository drafts are excluded from the project and are superseded by tested providers. |
| Test-format readers | Tests only | They are fixtures or experiments and are not product registrations. |

## Registration gate

A future repository-local provider is eligible only when it has:

- a distinct user need not already covered by the catalog;
- a small configuration-only public property surface with descriptions and defaults;
- deterministic schema and enumeration behavior;
- bounded I/O, cancellation where applicable, secret masking, and checkpoint support for large streams;
- representative corpus tests including malformed input and exact source spans where relevant;
- generated Markdown help and factory/catalog tests;
- no placeholder methods, unbounded network behavior, or dependency on unavailable desktop UI components.

Python and Java source readers remain deferred until representative external validation corpora are available. They should be added through the existing `SourceCode` language registry rather than as new public providers.
