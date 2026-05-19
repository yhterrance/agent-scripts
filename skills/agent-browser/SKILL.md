---
name: agent-browser
description: "Browser automation CLI: localhost, snapshot, profile, screenshot, debug web UI."
---

# agent-browser

CLI for inspecting / automating Chrome from the terminal. Daemon-backed, persists between commands. Source: `~/Projects/oss/agent-browser`.

For commands, flags, recipes, and triage workflows, read the CLI's own docs — they are authoritative and stay in sync with the binary:

```bash
agent-browser skills get core --full   # full command + flag reference + recipes
agent-browser --help
```

Don't guess flag names or recipes from memory; check the reference first.

## When to reach for it

- "Do you see X at http://localhost:..." / "is the tab loading"
- Repro a UI bug, take screenshot, dump accessibility tree
- Profile a slow / hot dev page
- Drive a flow programmatically (fill form, click, assert)

Not for: cloud browser providers (use bundled provider skills), Electron apps (`agent-browser skills get electron`).

## Auth on Terrance's localhost (environment-specific)

Sign-in needed (e.g. Clerk) => reuse Chrome login state. Profiles on this machine:

- `Default` (Terrance)
- `Dev` (Profile 2) — the dev account; use this for `localhost:3000` Tracing Paper, etc.

```bash
agent-browser --headed --profile Dev --enable react-devtools open http://localhost:3000/...
```

`--profile` snapshots the profile to a temp dir (read-only). No risk to original Chrome state.

`--enable react-devtools` is default-on for the `Dev` profile because the dev account is used for React apps and the flag only applies at launch — forgetting it means `close --all` + relaunch + reauth. Drop it only when you want zero React instrumentation overhead (e.g. micro-perf measurement). Same for init-scripts and other `--enable` flags: launch-time only; CDP-attaching (`--cdp 9222`) skips them.

Manual hand-off (user clicks in the visible window while the daemon still drives it) uses the same launch line.
