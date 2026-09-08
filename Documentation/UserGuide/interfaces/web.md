# Browser interface

The optional ULP web server lets you browse saved queries, edit ad-hoc SQL, inspect results, and export data from a browser. It is separate from this documentation website.

```powershell
ulp --web
```

Follow the startup configuration prompts for the listener and authentication. HTTPS and local access are the normal starting point. HTTP is an explicit opt-in, not a safe default for credentials or sensitive data. Keep the server account's data access restricted, and do not expose an unrestricted SQL editor publicly.

<!-- Screenshot placeholder: Query library folders and saved-query editor. -->
<!-- Screenshot placeholder: ad-hoc editor and expanded result grid. -->

Use saved queries for repeatable workflows and ad-hoc SQL for temporary investigations. Experimental AI Chat needs separate configuration and an API key; generated SQL requires review. Run `ulp --help-web` for the complete command reference. See [browser workflows](../user-interface.md#work-in-the-browser) and [security](../security.md#web-interface-security).
