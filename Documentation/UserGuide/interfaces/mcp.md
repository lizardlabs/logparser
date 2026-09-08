# Agents and MCP

MCP lets an agent use ULP's providers, saved-query library, SQLite queries, and output writers through discoverable tools. Configure your client to launch the installed executable with `--mcp`; use an absolute path.

Start an investigation by calling `GetRuntimeInfo`, then `CreateSession`. Use the returned `sessionId` on every data tool call. One server can host separate task databases without reusing each task's temporary tables or history. Omitting the ID selects the default session.

Typical workflow:

```text
GetRuntimeInfo
CreateSession
ListSavedQueries -> GetSavedQuery -> LoadSavedQuery
ExecuteSavedQuery (with sessionId)
CloseSession
```

For an ad-hoc investigation, discover provider help, create a virtual table, inspect its schema, and execute a bounded query. Materialize once for repeated code analysis. Close the session only after saving results you need; named-session data is in memory.

<!-- Screenshot placeholder: agent discovering a Code recipe and returning source spans. -->

Session IDs do not grant separate permissions. A CLI process cannot see an MCP in-memory table. See [client configuration](../reference/generated/mcp-reference.md), [coding-agent guidance](../ai.md#use-ulp-directly-from-an-agent), and [runtime discovery and sessions](../ai.md#independent-agent-sessions).
