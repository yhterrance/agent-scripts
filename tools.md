# Tools Reference

CLI tools available on Terrance's machines. Use these for agentic tasks.

## gh

GitHub CLI for repositories, issues, pull requests, CI, and releases.

Usage:

```bash
gh help
```

When someone shares a GitHub URL, use `gh` to read it when possible:

```bash
gh issue view <url> --comments
gh pr view <url> --comments --files
gh pr diff <url>
gh run list
gh run view <run-id>
```

Notes:

- Prefer `gh pr view/diff` for PR context over web search.
- Use `gh run list/view` for GitHub Actions CI.
- Do not publish, comment, merge, push, or change remote state unless the user asks.

## agent-browser

Headless/headed Chrome CLI for inspecting and automating web apps from the terminal. Daemon-backed (fast between commands), supports snapshots with refs, screenshots, network/HAR, CPU/React profiling, CDP attach.

```bash
agent-browser --help
agent-browser skills get core --full   # canonical reference
```

When to use: localhost UI checks, repro a bug, take a screenshot, profile a slow page, drive a flow.

See skill `agent-browser` for the Dev Chrome profile auth setup on this machine. For commands, flags, and triage recipes, run `agent-browser skills get core --full` or `agent-browser --help`.
