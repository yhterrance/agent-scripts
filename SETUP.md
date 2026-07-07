# New-machine setup

Canonical config lives here; machines consume it via symlinks. `settings.json` is the one exception — it is **per-machine and not tracked** (holds hooks, permissions, statusLine).

## 1. Prerequisites

- `git`, `python3` (statusline installer), `bun` (TS helpers: `browser-tools.ts`, `docs-list.ts`)
- Claude Code and/or Codex CLI
- `rtk` (token optimizer) — `brew install rtk`

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

RTK doc (referenced by `@RTK.md` in `AGENTS.MD`):

```sh
ln -sf ~/Projects/agent-scripts/RTK.md ~/.claude/RTK.md
# only if using rtk with Codex too:
# ln -sf ~/Projects/agent-scripts/RTK.md ~/.codex/RTK.md
```

## 4. Statusline

```sh
scripts/install-statusline.sh   # symlinks ~/.claude/statusline.sh + wires settings.json. Idempotent.
```

## 5. Commit hooks (skill validation)

```sh
git config core.hooksPath hooks   # runs scripts/validate-skills on pre-commit
```

## 6. rtk hook (per-machine — not in this repo)

The token savings come from a `PreToolUse` Bash hook in `~/.claude/settings.json`, which is machine-local. Install it per machine:

```sh
rtk init -g            # installs the hook + regenerates RTK.md, patches settings.json
rtk init --show        # verify
```

Because `~/.claude/RTK.md` is the symlink from step 3, `rtk init` writes the refreshed doc **through** it into this repo — commit the diff if it changed. A bare `brew upgrade rtk` does **not** touch RTK.md; only `rtk init` regenerates it.

Codex has no hook mechanism — rtk on Codex is instruction-only (voluntary `rtk <cmd>`), no transparent savings. Skip unless you want the doc.

## 7. settings.json

Not tracked here (per-machine: hooks, permissions, statusLine). Steps 4 and 6 patch it in place. If migrating a machine, copy the old `~/.claude/settings.json` over manually and re-run `rtk init --show` / `install-statusline.sh` to confirm the entries survived.
