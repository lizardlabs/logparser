# Legal, Licensing, Privacy, and Disclaimers

This chapter is a plain-language summary for users and release reviewers. It is not the operative product license and is not legal advice. The license shipped with a release controls where this summary differs.

## Contents

- [Current Product-License Status](#current-product-license-status)
- [Rights and Restrictions](#rights-and-restrictions)
- [Important Licensing Rules](#important-licensing-rules)
- [Software and Analysis Disclaimer](#software-and-analysis-disclaimer)
- [AI Disclaimer](#ai-disclaimer)
- [Privacy and Data Processing](#privacy-and-data-processing)
- [Local Processing](#local-processing)
- [Network Activity](#network-activity)
- [Credentials and API Keys](#credentials-and-api-keys)
- [Telemetry, Logs, and History](#telemetry-logs-and-history)
- [Third-Party Components](#third-party-components)
- [Trademarks](#trademarks)
- [Release Approval Blockers](#release-approval-blockers)

## Current Product-License Status

ULP is a proprietary product and is **not offered as open-source software**. This manual does not grant permission to copy, modify, publish, redistribute, host, resell, or embed ULP.

The current candidate does not contain a final approved product-license grant. A publishable release must therefore include an owner/counsel-approved `PRODUCT-LICENSE.txt` before distribution.

Until that license is approved and packaged, no right to use or distribute a release candidate should be inferred from this manual, the presence of binaries.

Third-party components retain their own license terms independently of the ULP product license.

## Rights and Restrictions

The approved product license must define the rights for the actual release, including:

- who may install and use ULP;
- whether use is personal, internal-business, evaluation, commercial, hosted, or otherwise limited;
- permitted number of users, machines, or services where applicable;
- whether copying, backup, transfer, redistribution, modification, or reverse engineering is allowed;
- support, update, termination, warranty, and liability terms;
- governing law, export restrictions, and mandatory consumer rights.

Do not infer those terms from a third-party dependency license. A permissive or copyleft license for one bundled library does not change ownership or licensing of ULP itself.

## Important Licensing Rules

For every release:

- ship the approved ULP product license;
- ship complete third-party notices and required license texts;
- preserve source/relinking material required by a component's license;
- generate the inventory from the exact staged package, not only project references;
- resolve every `review` or `unmapped` inventory entry before publication;
- document provenance and modifications for locally built or changed dependencies;
- confirm redistribution rights for proprietary and platform redistributables;
- keep internal legal review records separate from the customer-facing package.

The release build intentionally fails closed when required approval evidence is missing. An internal packaging override validates mechanics only and does not authorize publication.

## Software and Analysis Disclaimer

An approved product license must contain the operative warranty, liability, and mandatory-rights language. Until it does, this section is cautionary guidance only.

Test ULP, queries, providers, writers, generated files, automation, and upgrades in a controlled environment. Maintain backups of source data and important outputs.

ULP transforms available data according to configured parsers and SQL. Results can be incomplete or misleading because of permissions, retention, parsing ambiguity, encoding, timestamps, missing records, query logic, joins, aggregation, sampling, limits, or source quality.

Do not treat ULP output as conclusive forensic, compliance, security, legal, medical, financial, employment, or operational evidence without appropriate validation, expertise, and chain-of-custody/process controls.

## AI Disclaimer

AI assistance is experimental. Generated SQL or explanations can be incorrect, unsafe, inefficient, or fabricated. Treat generated SQL as an editable proposal: inspect every statement and confirm the selected inputs, outputs, parameters, and side effects before execution.

Users are responsible for provider selection, authorization to transmit prompts/schema information, provider charges, retention settings, and compliance obligations. See [AI Features](ai.md#ai-disclaimer).

## Privacy and Data Processing

No owner/counsel-approved privacy policy has yet been supplied for this candidate. The behavior described below is technical documentation, not a contractual privacy statement.

A final privacy statement should identify the responsible business, contact details, processing purposes, retention, recipients/processors, international transfers, data-subject rights, browser storage, diagnostics, and telemetry behavior relevant to the released product.

## Local Processing

Normal file/provider parsing, SQLite queries, and local writers run on the selected machine. Local operation can still expose information through:

- result files and console output;
- logs and full error details;
- checkpoints and persistent databases;
- saved queries and configuration;
- browser, TUI, shell, or MCP clients;
- lifecycle hooks and post-actions;
- permissions granted to the process account.

Review every input, destination, hook, listener, and client. “Local” does not by itself mean “private” or “safe.”

## Network Activity

ULP uses the network when the user selects or configures a network-capable workflow, including:

- URL, cloud, or network-share inputs;
- remote database connections;
- Active Directory/domain access;
- the built-in web-server listener;
- an AI API endpoint;
- an explicitly configured post-action program.

Remote services, proxies, DNS resolvers, firewalls, and TLS endpoints may record metadata or content according to their own policies.

When AI is enabled, the configured provider can receive the prompt, bounded conversation context, schema names and types, model identifier, authentication, and network metadata. ULP does not intentionally include input rows or files by default, but anything placed in the prompt is transmitted.

## Credentials and API Keys

ULP supports protected whole-value references such as `@env:`, `@file:`, and `@wincred:`. Use the narrowest practical credentials and protect the referenced source.

Do not place secrets directly in:

- command arguments;
- SQL or saved queries;
- checked-in configuration;
- filenames;
- screenshots;
- logs or shared diagnostics.

Connection-string masking is defense in depth, not a guarantee that arbitrary text or selected result columns cannot contain secrets. Rotate any value that may have been exposed.

## Telemetry, Logs, and History

The current user-facing configuration does not document a publisher analytics/telemetry endpoint enabled by default. This engineering observation is not a contractual promise for every release; the publisher must approve and state the final policy.

Operational artifacts can reveal sensitive information:

| Artifact | Possible contents |
| --- | --- |
| Logs | SQL, paths, schemas, timings, errors, and diagnostic context |
| Checkpoints | Source identity and processing progress |
| Browser/session history | Prompts, SQL, and generated statements |
| Query library | Investigation logic and business rules |
| Configuration | Paths, endpoints, identities, and behavior settings |

Apply appropriate access control, retention, backup, and deletion policies. Sanitize diagnostics before sharing them.

## Third-Party Components

ULP includes third-party libraries and web/pattern assets. Their terms apply in addition to the ULP product license.

The customer-facing inventory is provided in:

- [Third-Party Notices](legal/THIRD-PARTY-NOTICES.txt);
- [Dependency Inventory](legal/dependency-inventory.csv);
- [License Texts](legal/licenses/);
- [Component Provenance](legal/provenance/);
- [Required Source Information](legal/source-information/).

The inventory must be regenerated from the exact release package. Do not assume that a project dependency list describes every shipped native binary, JavaScript file, stylesheet, font, pattern definition, or locally built component.

## Trademarks

“Universal Log Parser,” “ULP,” “Lizard Labs,” and third-party names and marks may be trademarks of their respective owners. No trademark license is implied by a reference in this manual.

The publisher must approve final product-mark ownership, permitted logo/name use, and required third-party attributions before publication.

## Release Approval Blockers

The current candidate must not be described as ready for public distribution until these items are resolved:

- [ ] approved ULP product license with the publisher's legal identity and terms;
- [ ] copyright ownership and years;
- [ ] approved privacy and telemetry statement;
- [ ] private vulnerability-reporting contact and policy;
- [ ] warranty, liability, governing-law, export, and sanctions review;
- [ ] product trademark/brand guidance;
- [ ] every dependency and material-asset `review`/`unmapped` entry;
- [ ] LGPL replacement, relinking, and corresponding-source obligations;
- [ ] proprietary dependency and redistributable rights;
- [ ] locally built component ownership/provenance confirmation;
- [ ] release signing identity and publication-channel approval.

These are owner/legal decisions, not documentation edits. The package may be built with an internal-review marker for technical validation, but it remains non-publishable until the blockers are closed.

## Related Documentation

- [Security](security.md)
- [Deployment and Packaging](deployment.md)
- [AI Features](ai.md)
- [Third-Party Notices](legal/THIRD-PARTY-NOTICES.txt)
