---
name: agent-browser
description: "Browser automation CLI: localhost, snapshot, profile, screenshot, debug web UI."
---

# agent-browser

CLI for inspecting / automating Chrome from the terminal. Daemon-backed, persists between commands. Source: `~/Projects/oss/agent-browser`. Canonical reference: `agent-browser skills get core --full`.

## When to reach for it

- "Do you see X at http://localhost:..." / "is the tab loading"
- Repro a UI bug, take screenshot, dump accessibility tree
- Profile a slow / hot dev page (CPU, React renders, network, vitals)
- Drive a flow programmatically (fill form, click, assert)

Not for: cloud browser providers (use bundled provider skills), Electron apps (`agent-browser skills get electron`).

## Auth on Terrance's localhost

Sign-in needed (e.g. Clerk) => reuse Chrome login state. Profiles on this machine:

- `Default` (Terrance)
- `Dev` (Profile 2) — the dev account; use this for `localhost:3000` Tracing Paper, etc.

```bash
agent-browser --headed --profile Dev open http://localhost:3000/...
```

`--profile` snapshots the profile to a temp dir (read-only). No risk to original Chrome state.

## Page inspection recipe

```bash
agent-browser open <url> && agent-browser wait --load networkidle
agent-browser snapshot -i              # a11y tree with @e1, @e2, ... refs
agent-browser tab                       # list browser tabs (t1, t2, ...)
agent-browser get box @e57             # bounding box (verify spatial layout)
agent-browser eval "({w:innerWidth,h:innerHeight})"
agent-browser screenshot --annotate    # numbered overlay matching @eN refs
```

Spatial layout question ("is X bottom-right?") => `get box <ref>` + viewport size beats guessing from the a11y tree.

If a `group` snapshot label concatenates many child texts and is `clickable [onclick]`, the page is using `<div onclick>` instead of `role=tab` / `<button>`. The a11y tree can't split them; use `get html <ref>` or annotated screenshot.

## Performance profiling strategy

Symptom => tool:

- "Slow page load, real-user metrics" => `agent-browser vitals --json` (LCP/CLS/TTFB/FCP/INP + React hydration phases)
- "Why is CPU pegged?" => layered triage below
- "Network slow / waterfall" => `network har start/stop`, `network requests --filter ... --type ... --status ...`
- "Component re-rendering loop" => `--enable react-devtools` + `react renders start/stop`
- "Anything else low-level" => `profiler start/stop` (Chrome DevTools Performance JSON)

### Steady-state rule

Don't profile 3 min of activity. CDP traces explode in size and DevTools chokes loading them. Profile a **short window (10–30 s) on the *steady-state*** of the symptom. If CPU stays high after a task "finishes," the post-finish idle-but-hot phase is the easiest possible thing to profile — stationary signal, any 15 s window contains the loop.

### High-CPU triage decision tree

1. Pre-instrument with `--init-script cpu-probe.js` (template alongside this skill) BEFORE the trigger.
2. Trigger the slow flow (manually or via CLI), wait until it finishes.
3. Read `__cpuProbeRate`:
   - `rafPerSec >> 60` at idle => rAF loop. Could be React render storm OR direct rAF.
   - `rafPerSec ~0` but high CPU => timer / interval / WebSocket firehose / sync work.
   - `activeIntervals` / `activeTimeouts` high => leak.
4. `network requests --type websocket` and `console --json | tail -50` — streaming firehose or log spam?
5. `react renders start && sleep 15 && react renders stop --json` — sort by `renderCount`. A component rendering hundreds of times at idle = the bug.
6. Only if 5 doesn't pinpoint it: `profiler start && sleep 20 && profiler stop /tmp/idle-hot.json`. Load in Chrome DevTools → Performance. Bottom-Up sorted by Self Time.

### CPU probe template

`skills/agent-browser/scripts/cpu-probe.js` (this skill dir). Patches `rAF`, `setInterval`, `setTimeout`, observes long tasks, exposes `window.__cpuProbeRate`. Copy to `/tmp/` or pass directly to `--init-script`.

Launch with it:

```bash
agent-browser --headed --profile Dev \
  --enable react-devtools \
  --init-script ~/Projects/agent-scripts/skills/agent-browser/scripts/cpu-probe.js \
  open http://localhost:3000/<route>
```

`--enable react-devtools` and `--init-script` only apply when agent-browser **launches** the browser. CDP-attaching (`--cdp 9222`) won't install them. Plan the launch up front.

## Manual driving (let the user click)

Setup with `--headed --profile Dev --enable react-devtools --init-script ...`, hand off — the user types/clicks in the visible Chrome window. Daemon still controls it; `eval`, `react renders`, `profiler`, `network` all still work in parallel.

## Quirks / gotchas

- `fill` clears then types; `type` appends. Send buttons gated on non-empty input flip from `[disabled]` to `enabled=true` — verify with `is enabled @ref` before clicking.
- After page mutations, re-snapshot. Refs are per-snapshot; navigations and large DOM updates invalidate them.
- Default timeout 25 s, IPC timeout 30 s. Long ops: set `AGENT_BROWSER_DEFAULT_TIMEOUT` but stay under 30 s.
- One daemon per `--session`. `close --all` to nuke everything before relaunching with different flags.
- `--headed` ≠ separate browser — don't click in your own Chrome by mistake; click in the window agent-browser launched.

## When to load the full reference

```bash
agent-browser skills get core --full   # full command + flag reference
agent-browser --help
```

Use these when the recipe here doesn't cover the case (touch events, iOS sim, cloud providers, etc.).
