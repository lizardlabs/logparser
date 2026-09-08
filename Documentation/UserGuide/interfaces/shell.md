# SQL shell

The shell keeps a connection open while you enter successive SQL statements. It is useful for inspecting schema, creating temporary tables, and refining an investigation interactively.

```powershell
ulp --shell
ulp --shell --database investigation.sqlite
```

End SQL with `;` or use `.run` to execute the current buffer. `.show` displays the buffer; `.clear` clears it; `.help` lists commands; `.quit` exits. Ctrl+C cancels a running query. A file-backed database preserves ordinary tables, but TEMP tables belong to the current connection.

<!-- Screenshot placeholder: shell commands, a schema inspection, and a result. -->

For opt-in experimental AI, configure the endpoint and a key reference, then use `.ai <question>` to get a proposal. Review before `.ai-run`; `.ai-clear` clears the conversation. See the [shell manual](../user-interface.md), [SQLite guide](../sqlite-guide.md), and [AI configuration](../ai.md).
