# Scriban template samples

`summary.scriban` renders the first query result to one text stream or file:

```powershell
ulp --query "SELECT 'Widget' AS name, 'Class' AS kind" `
    --format Scriban --output console `
    --output.TemplateFile .\samples\templates\summary.scriban
```

`codegen` demonstrates directory generation. Its model template uses `mode:
each-row` and a data-driven `Models/{{ row.name }}.cs` output path; its README
template renders once.

```powershell
ulp --query "SELECT 'Customer' AS name, 'Entity' AS kind UNION ALL SELECT 'Order', 'Entity'" `
    --format Scriban --output file --output-file .\generated `
    --output.TemplateDirectory .\samples\templates\codegen
```

Use `--no-overwrite` when generated files must already be absent. ULP rejects
rooted paths and any rendered path that escapes the selected output directory.
See `docs\inputs-and-outputs.md#scriban` for the user guide and `docs\reference\generated\scriban-reference.md` for the exact generated runtime reference.
