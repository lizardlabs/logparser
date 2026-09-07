# Product legal information

Universal Log Parser (ULP) is a Lizard Labs product. Product copyright, trademark, privacy, support, warranty, export-control, and governing-law statements must be supplied by the publisher for the actual distribution channel and customer contract.

The product license does not replace third-party terms. The bundled [Open Source Software Notices](THIRD-PARTY-NOTICES.md) and license texts apply independently to the named components.

Before publishing a release:

1. Run `legal/generate-dependency-inventory.ps1 -FailOnReview` against the exact staging folder.
2. Resolve every `review` or `unmapped` binary; do not waive it merely because a prior build shipped it.
3. Confirm that the EULA, privacy statement, export classification, support policy, and copyright year/entity are approved.
4. Keep source/offer and relinking material required by LGPL components for the required period.
5. Preserve all copyright, patent, attribution, and license notices.

Product homepage: https://log-parser.com
