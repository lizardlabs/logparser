# Grok and regular-expression patterns

ULP ships this catalog for the `RegEx` input provider and SQLite Grok functions. Files ending in `.grokpatterns` define Grok aliases; `.regexpatterns` files provide reusable regular expressions.

The catalog includes patterns derived from the Logstash patterns collection. See `notice.txt` for its Apache License 2.0 notice.

To add or replace patterns without modifying the installation, copy the catalog to a writable directory and select it with:

```powershell
ulp --grok-patterns-dir C:\Data\ulp-patterns ...
```

The environment equivalent is `ULP_GROK_PATTERNS_DIR`. An explicit directory replaces the installed catalog for that process. ULP falls back to the legacy `Documents\Log Parser Lizard\RegularExpressionData` directory only when no installed or explicit catalog exists.
