# AI-assisted SQL

AI Chat is experimental, disabled by default, and may change. Configure it under **Options > Configure AI (experimental)**, in a command-line `.config` file, or with switches. Use **Options > AI Chat** or `.ai <question>` in the SQL shell. The web UI uses the same configuration and conversation service.

```text
--ai
--ai-base-url=https://api.openai.com/v1
--ai-model=gpt-4.1-mini
--ai-key=@env:ULP_AI_API_KEY
--ai-timeout=60
```

Save those entries as `ai.config`, provision the environment variable securely, and start `ulp --config ai.config --shell` or `ulp --config ai.config --web`. `--web-ai`, `--web-ai-base-url`, `--web-ai-model`, `--web-ai-key`, and `--web-ai-timeout` remain accepted web aliases. `--no-ai` disables saved AI configuration for one run. Remote endpoints require HTTPS; loopback endpoints may use HTTP. The model name is configurable; use one supported by your chosen provider.

The key can use `@env:NAME`, `@file:C:\Secrets\ulp-key.txt`, or `@wincred:TARGET`. Protect secret files and credential-store entries with the running account's access controls. Do not paste keys into SQL, prompts, source control, screenshots, or process arguments. The menu can save the reference in `settings.config`; it never saves a literal key or secret headers. A key entered through the masked prompt lasts only for this process.

Prompts, recent conversation, table/column names, and installed function names are sent to the chosen provider. Result rows and file contents are not automatically sent. Treat schemas as sensitive too. Review the provider's privacy and retention terms before enabling AI.

The assistant can explain, clarify, or return SQL grounded in the actual schema. It cannot guarantee correctness. Proposals are never executed automatically. In the shell use `.ai-run` explicitly after review; `.ai-clear` clears local conversation state. In the browser choose **Run here** to keep a bounded result table in the chat, or **Open in Ad-hoc editor** to edit first. Normal query permissions still apply. SELECT is not a security sandbox.

The portable integration uses the [Chat Completions request format](https://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create). It omits optional sampling controls so providers/models that reject them remain usable.
