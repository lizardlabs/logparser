# Agents and MCP

MCP lets an agent use ULP's providers, saved-query library, SQLite queries, output writers, and packaged agent skills through discoverable tools. Configure your client to launch the installed executable with `--mcp`; use an absolute path.

On discovery, the server publishes `ulp://runtime` and the `ulp://skills/{name}` resource template. Runtime information includes the exact installed CLI path and skills directory. Clients that do not display resources can call `GetRuntimeInfo`, `ListAgentSkills`, and `GetAgentSkill` instead.

Start an investigation by reading the relevant packaged skill, calling `GetRuntimeInfo`, and then creating a session. Use the returned `sessionId` on every data tool call. One server can host separate task databases without reusing each task's temporary tables or history. Omitting the ID selects the default session.

Typical workflow:

```text
GetRuntimeInfo
ListAgentSkills -> GetAgentSkill
CreateSession
ListSavedQueries -> GetSavedQuery -> LoadSavedQuery
ExecuteSavedQuery (with sessionId)
CloseSession
```

For an ad-hoc investigation, discover provider help, create a virtual table, inspect its exact schema with `DescribeTable`, and execute a bounded preview. Build queries only from confirmed columns and materialize once for repeated code analysis. Close the session only after saving results you need; named-session data is in memory.

<!-- Screenshot placeholder: agent discovering a Code recipe and returning source spans. -->

Session IDs do not grant separate permissions. A CLI process cannot see an MCP in-memory table. See [client configuration](../reference/generated/mcp-reference.md), [coding-agent guidance](../ai.md#use-ulp-directly-from-an-agent), and [runtime discovery and sessions](../ai.md#independent-agent-sessions).
