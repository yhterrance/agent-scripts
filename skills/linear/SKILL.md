---
name: linear
description: "Linear via mcporter: list and create issues."
---

# Linear

Use for Linear issue listing and creation. Routes through `mcporter` so the same flow works from Claude Code and Codex.

## Defaults

- MCP server: `linear`
- Transport: `https://mcp.linear.app/mcp` (streamable HTTP)
- Auth: OAuth; tokens cache after `mcporter auth linear` (browser flow).
- Config: `~/.mcporter/mcporter.json`.

## Defaults (Terrance)

- Default team: `PRD`. Use unless the user names a different team.
- User identity (Linear actor): Terrance — same person as the CLAUDE.md `userEmail`.

## Guardrails

- Confirm `mcporter list linear --schema` matches the field names below before automating; Linear evolves its MCP surface.
- Issue creation is durable and notifies subscribers. Ask for confirmation before `create_issue` unless the user already provided title + team in the same turn.
- Never print OAuth tokens or auth headers; mcporter handles them in the cache.

## Commands

Verify the server is reachable and OAuth is fresh:

```bash
mcporter list linear --schema
```

List issues (illustrative args; confirm via `--schema`):

```bash
mcporter call 'linear.list_issues(team: "PRD")'
mcporter call 'linear.list_issues(query: "auth bug", limit: 10)'
```

Create an issue:

```bash
mcporter call 'linear.create_issue(team: "PRD", title: "Bug: login redirect loop", description: "Repro steps…")'
```

Structured output for piping into other tools:

```bash
mcporter call 'linear.list_issues(team: "PRD")' --output json
```

## When OAuth expires

```bash
mcporter auth linear
```

Re-runs the browser consent flow; the cached token at `~/.mcporter/oauth/` is refreshed in place.
