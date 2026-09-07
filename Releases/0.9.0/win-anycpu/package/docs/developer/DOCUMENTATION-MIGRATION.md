# Documentation Migration Map

<!-- standalone-reason: Maintainer-only compatibility map with an independent migration lifecycle. -->

This map records the transition from fragmented user pages to the chapter-based ULP manual. It exists for maintainers, link compatibility, release scripts, and documentation tests; it is not an additional user-manual chapter.

## Rules

- The substantial files directly under `docs/` are the authoritative hand-written user manual.
- `docs/reference/generated/` contains output produced from the running ULP catalog by `ulp --docs`.
- Old generated paths under `docs/user/` remain as concise moved notices where existing inbound links may exist.
- A focused page is not removed until its unique supported behavior and safety guidance is in a manual chapter or generated runtime reference.
- Legal source text, developer documentation, blog articles, and executable samples stay separate because they have different audiences or lifecycles.

## Focused User Pages

| Previous path | Authoritative manual destination | Exact generated reference / compatibility |
| --- | --- | --- |
| `docs/user/GENERAL.md` | `docs/getting-started.md`, `docs/how-to.md` | Remains generated/embedded for terminal General Help |
| `docs/user/CLI.md` | `docs/reference.md` | `docs/reference/generated/cli-reference.md`; old path is a moved notice |
| `docs/user/CONFIGURATION.md` | `docs/reference.md#configuration` | `docs/reference/generated/configuration-reference.md`; old path is a moved notice |
| `docs/user/AUTOMATION.md` | `docs/how-to.md#automation`, `docs/reference.md#automation-and-lifecycle-options` | `docs/reference/generated/automation-reference.md`; old path is a moved notice |
| `docs/user/BACKGROUND-JOBS.md` | `docs/reference.md#background-jobs`, `docs/user-interface.md` | `docs/reference/generated/background-jobs-reference.md`; old path is a moved notice |
| `docs/user/OUTPUT-PIPELINES.md` | `docs/inputs-and-outputs.md#multiple-output-pipelines` | `docs/reference/generated/output-pipelines-reference.md`; old path is a moved notice |
| `docs/user/MCP.md` | `docs/deployment.md#mcp-deployment`, `docs/security.md#mcp-security` | `docs/reference/generated/mcp-reference.md`; old path is a moved notice |
| `docs/user/ADO-NET.md` | `docs/reference.md#ado` | `docs/reference/generated/ado-net-reference.md`; old path is a moved notice |
| `docs/user/SCRIBAN.md` | `docs/inputs-and-outputs.md#scriban`, `docs/samples.md` | `docs/reference/generated/scriban-reference.md`; old path is a moved notice |
| `docs/user/QUERY-BUILDER.md` | `docs/user-interface.md#query-builder` | `docs/reference/generated/query-builder-reference.md`; old path is a moved notice |
| `docs/user/SQLITE.md` | `docs/sqlite-guide.md`, `docs/functions.md` | Retained as generated terminal-help detail during this release |
| `docs/user/INCREMENTAL-INPUT.md` | `docs/inputs-and-outputs.md#incremental-input-and-checkpoints` | Remains generated/embedded for terminal incremental help |
| `docs/user/SAMPLES.md` | `docs/samples.md` | Retained as generated executable-example detail |
| `docs/user/WEB.md` | `docs/user-interface.md`, `docs/security.md` | Retained as generated exact web-option reference |
| `docs/user/AI.md` | `docs/ai.md` | Retained as a generated AI status notice |
| `docs/user/README.md` | `docs/README.md` | Retained as the generated compatibility/reference index |

## Provider and Writer Pages

| Previous pattern | Current canonical pattern | Compatibility behavior |
| --- | --- | --- |
| `docs/user/provider-<NAME>.md` | `docs/reference/generated/provider-<NAME>.md` | Generator writes a moved notice at every old path |
| `docs/user/writer-<NAME>.md` | `docs/reference/generated/writer-<NAME>.md` | Generator writes a moved notice at every old path |

The catalogs `provider-catalog.json` and `writer-catalog.json` list the runtime names, descriptions, and canonical detail paths. The generator and integration tests must move together whenever these paths change.

## Generated Inventories

| Artifact | Location | Generation method |
| --- | --- | --- |
| CLI reference | `docs/reference/generated/cli-reference.md` | `ulp --docs docs` |
| Configuration reference | `docs/reference/generated/configuration-reference.md` | `ulp --docs docs` |
| Configuration schema | `docs/reference/generated/configuration.json` | `ulp --docs docs` |
| Provider catalog/details | `docs/reference/generated/provider-catalog.json`, `provider-*.md` | `ulp --docs docs` from runtime catalog |
| Writer catalog/details | `docs/reference/generated/writer-catalog.json`, `writer-*.md` | `ulp --docs docs` from runtime catalog |
| SQLite functions | `docs/reference/generated/sqlite-functions.json` | `docs/reference/generate-function-reference.ps1` against the built runtime |

## Maintainer Verification

After a generator or path change:

1. build ULP;
2. run `ulp --docs docs` twice and confirm the second run is unchanged;
3. run `Tests/Test-Documentation.ps1`;
4. run the documentation-generation integration test;
5. search documentation, source, sample READMEs, release scripts, and tests for stale old paths;
6. inspect the manual index and generated index on GitHub-compatible Markdown;
7. run `git diff --check` and the full integration suite.
