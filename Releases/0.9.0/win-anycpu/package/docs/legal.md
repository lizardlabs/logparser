# Legal, Licensing, Privacy, and Disclaimers

This chapter is a readable summary, not the operative product license and not legal advice. Third-party terms apply independently. The repository currently has **no root `LICENSE` containing an approved product license grant**, so this document must not be interpreted as permission to copy, redistribute, modify, or commercially use ULP.

## Contents

- [Licensing](#licensing)
- [License for the Current Release](#license-for-the-current-release)
- [Commercial Use](#commercial-use)
- [Future Releases and Offerings](#future-releases-and-offerings)
- [Important Licensing Notes](#important-licensing-notes)
- [Software Disclaimer](#software-disclaimer)
- [Analysis Disclaimer](#analysis-disclaimer)
- [AI Disclaimer](#ai-disclaimer)
- [Privacy](#privacy)
- [Local Processing](#local-processing)
- [Network Activity](#network-activity)
- [AI Providers](#ai-providers)
- [API Keys](#api-keys)
- [Telemetry](#telemetry)
- [Logs and History](#logs-and-history)
- [Third-Party Components](#third-party-components)
- [Third-Party Licenses](#third-party-licenses)
- [Trademarks](#trademarks)
- [Legal Review Notes](#legal-review-notes)

## Licensing

The publisher must supply an approved product license for the actual release and distribution channel. A template under `docs/legal/EULA-TEMPLATE.md` is explicitly unapproved and cannot substitute for an operative license.

Third-party components keep their own licenses regardless of the product-license choice.

## License for the Current Release

Repository evidence establishes:

- ULP is described as a Lizard Labs product;
- third-party notices and license texts exist under `docs/legal`;
- a product EULA template exists but requires legal review;
- no approved root `LICENSE` is present.

Therefore no product license grant is stated here.

**Owner/counsel input required:** full legal entity/address, copyright statement, license grant, restrictions, term, support/update rights, warranty/liability terms, governing law, privacy terms, export/sanctions terms, and effective date.

## Commercial Use

Do not infer permission for commercial use, redistribution, hosting, resale, embedding, or service-provider use from source availability or documentation. Those rights must come from the approved product license.

Many listed third-party components use permissive licenses, but satisfying their conditions does not grant rights to ULP product code. Some shipped/observed components require additional review.

## Future Releases and Offerings

The publisher may choose different commercial, free, trial, subscription, enterprise, hosted, support, or dual-licensing offerings in the future. This possibility is not a promise and does not change rights for a current release.

Each release/channel must ship or link its actual applicable terms.

## Important Licensing Notes

- Never replace an operative `LICENSE` merely to match a proposed business model.
- Keep complete third-party notices and required license/source/relinking material.
- Run the dependency inventory against the exact Release/staging folder.
- Resolve every `review`/`unmapped` binary before publication.
- Record provenance for locally modified/prebuilt dependencies.
- Have qualified counsel approve product terms and distribution obligations.

## Software Disclaimer

No approved warranty disclaimer is present in a root product license. Users should test ULP, queries, providers, writers, generated files, automation, and upgrades in a controlled environment and maintain backups.

This explanatory caution does not replace counsel-approved warranty, liability, consumer-rights, or statutory language.

## Analysis Disclaimer

ULP transforms available data according to configured parsers and SQL. Results can be incomplete or misleading because of source permissions, retention, parsing ambiguity, encoding, timestamps, missing records, query logic, joins, aggregation, sampling, limits, or data quality.

Do not treat output as conclusive forensic, compliance, security, legal, medical, financial, employment, or operational evidence without validation by qualified people and appropriate chain-of-custody/process controls.

## AI Disclaimer

Experimental AI output can be incorrect, unsafe, inefficient, or fabricated. Generated SQL is a proposal that requires review. Users are responsible for provider selection, authorization to transmit schema/prompts, costs, retention, compliance, and the decision to execute.

See [AI Features](ai.md#ai-disclaimer).

## Privacy

No publisher-approved privacy policy is present in the repository. The behavior summary below is technical documentation, not a contractual privacy statement.

**Owner/counsel input required:** controller/business identity, contact, purposes/legal bases, retention, recipients/processors, international transfers, data-subject rights, cookies/browser storage, support diagnostics, telemetry policy, and jurisdiction-specific disclosures.

## Local Processing

Normal file/provider parsing, SQLite queries, and local output run in the ULP process/on the selected machine unless the configured source/destination/service is remote. ULP can expose local data through SQL results, output files, logs, web/MCP clients, post-actions, or remote connections chosen by the user.

Local processing does not mean every workflow is private: verify the provider, connection, output, hooks, web binding, MCP client, and AI settings.

## Network Activity

Network activity occurs when configured/selected for URL/cloud/network inputs, remote databases, Active Directory, network shares, the web listener, AI requests, or post-actions. Firewall/proxy/DNS/TLS and remote service logs may record metadata.

## AI Providers

When experimental web AI uses a remote endpoint, schema names/types, prompt, bounded chat context, model identifier, authentication, and network metadata leave the computer. Provider terms/settings control retention and processing. Result rows/files are not intentionally included by default, but user-entered prompt content is.

## API Keys

ULP supports `@env:`, `@file:`, and `@wincred:` secret references and does not persist the web AI key in normal settings/browser responses. The source system and provider still process the key. Users must protect, scope, rotate, and revoke it.

## Telemetry

The current user-facing configuration does not document a publisher analytics/telemetry endpoint enabled by default. This is not an approved policy or promise for every build. The publisher must approve and document telemetry/crash-reporting behavior per release.

## Logs and History

ULP logs can contain SQL, paths, schemas, timing, errors, and sanitized context. Checkpoints contain source/progress state. Browser session storage can contain Shell/AI history. Query libraries/configuration contain analyst intent and operational settings.

Define access, retention, deletion, backups, and disclosure procedures. Secret masking is not guaranteed for arbitrary data.

## Third-Party Components

The readable inventory is [Open Source Software Notices](legal/THIRD-PARTY-NOTICES.md). The generated binary snapshot is [`dependency-inventory.csv`](legal/dependency-inventory.csv).

The inventory currently flags items requiring review, including provenance/local modifications and components with LGPL/proprietary/unrecorded terms. Consult the exact release inventory rather than assuming the source dependency list equals shipped binaries.

## Third-Party Licenses

Full texts remain separately under [`docs/legal/licenses`](legal/licenses). They must not be merged into this chapter merely to reduce file count because they are independently operative notice material.

## Trademarks

“Universal Log Parser,” “ULP,” “Lizard Labs,” Microsoft, Windows, Excel, SQLite, OpenAI, and other names may be trademarks of their respective owners. No approved trademark policy or attribution list is supplied in the repository.

**Owner/counsel input required:** product marks, ownership statements, permitted use, third-party attribution, and logo/brand guidelines.

## Legal Review Notes

Before release, resolve:

- [ ] approved root product `LICENSE`/EULA;
- [ ] publisher legal identity, address, and contacts;
- [ ] copyright years/ownership;
- [ ] privacy and telemetry statement;
- [ ] security reporting channel;
- [ ] warranty/liability/governing-law terms;
- [ ] export/sanctions classification;
- [ ] trademark policy;
- [ ] every dependency inventory review/unmapped item;
- [ ] LGPL replacement/relinking/source obligations;
- [ ] proprietary redistributable rights;
- [ ] signing identity and package-channel terms.

## Related Documentation

- [ULP Security](security.md)
- [Deployment and Packaging](deployment.md)
- [Product legal checklist](legal/PRODUCT-LEGAL.md)
- [Unapproved EULA template](legal/EULA-TEMPLATE.md)
- [Legal source-material index](legal/README.md)
