# Legal and third-party material

Customer-facing release material:

- [Third-party notices](THIRD-PARTY-NOTICES.txt)
- [Readable third-party overview](THIRD-PARTY-NOTICES.md)
- [Generated shipped-file inventory](dependency-inventory.csv)
- [Bundled license texts](licenses/)
- [Component provenance](provenance/)
- [Required source information](source-information/)

Maintainer-only review material:

- [Internal compliance review](COMPLIANCE-REVIEW.md)
- [Product legal checklist](PRODUCT-LEGAL.md)
- [Unapproved EULA template](EULA-TEMPLATE.md)
- `PRODUCT-LICENSE-REQUIRED.txt`, which marks non-publishable review packages when no approved product license exists.

The release script excludes maintainer-only review files from the packaged customer manual. The release package places customer notices, license texts, provenance, source information, and either the approved product license or an explicit internal-review marker together under its top-level `legal` directory.
