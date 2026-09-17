# New-machine setup

Canonical config lives here; machines consume it via symlinks. `settings.json` is the one exception — it is **per-machine and not tracked** (holds hooks, permissions, statusLine).

## 1. Prerequisites

- `git`, `python3` (statusline installer), `bun` (TS helpers: `browser-tools.ts`, `docs-list.ts`)
- Claude Code and/or Codex CLI

## 2. Clone

```sh
git clone git@github.com:yhterrance/agent-scripts.git ~/Projects/agent-scripts
```

Everything below assumes the repo is at `~/Projects/agent-scripts`.

## 3. Symlinks (shared, repo-backed)

Agent instructions (`AGENTS.MD`) and skills:

```sh
mkdir -p ~/.claude ~/.codex
ln -sf ~/Projects/agent-scripts/AGENTS.MD ~/.claude/CLAUDE.md
ln -sf ~/Projects/agent-scripts/AGENTS.MD ~/.claude/AGENTS.md
ln -sf ~/Projects/agent-scripts/AGENTS.MD ~/.codex/AGENTS.md
ln -sf ~/Projects/agent-scripts/skills    ~/.claude/skills
ln -sf ~/Projects/agent-scripts/skills    ~/.codex/skills
```

## 4. Statusline

```sh
scripts/install-statusline.sh   # symlinks ~/.claude/statusline.sh + wires settings.json. Idempotent.
```

## 5. Commit hooks (skill validation)

```sh
git config core.hooksPath hooks   # runs scripts/validate-skills on pre-commit
```

## 6. settings.json

Not tracked here (per-machine: hooks, permissions, statusLine). Step 4 patches it in place. If migrating a machine, copy the old `~/.claude/settings.json` over manually and re-run `install-statusline.sh` to confirm the entries survived.
