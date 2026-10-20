# New-machine setup

Canonical config lives here; machines consume it via symlinks. `settings.json` is the one exception — it is **per-machine and not tracked** (holds hooks, permissions, statusLine).

## 1. Prerequisites

- `git`, `python3` (statusline installer), `uv` (standalone Python), `ruby` (skill validation), `jq` (statusline), `bun` (TS helpers)
- Claude Code and/or Codex CLI

Check the installed tools first. Codex alone is sufficient; Claude Code is optional. Install only missing prerequisites. Use an existing directory on `PATH` for binaries; do not change `PATH` or shell startup files.

### Standalone Python

Install missing `uv` using its [official installation guide](https://docs.astral.sh/uv/getting-started/installation/), into an existing directory on the agent process's `PATH`. Then install the managed runtime:

```sh
uv python install 3.13
```

No manual virtualenv activation or global package installs. Ad hoc scripts use `uv run --no-project --isolated --python 3.13`; add `--with PACKAGE` for dependencies. uv manages isolated environments and caches packages. Retained scripts declare Python/dependencies with PEP 723 inline metadata and run with `uv run --script`. Repo work keeps the repo's runtime/package manager.

An embedded Python tool does not inherit this interpreter selection; use shell `uv run` when that tool cannot select the required environment. Restart agents after installation so their processes see the executable.

## 2. Clone

```sh
git clone git@github.com:yhterrance/agent-scripts.git ~/Projects/agent-scripts
```

Everything below assumes the repo is at `~/Projects/agent-scripts`.

## 3. Symlinks (shared, repo-backed)

Agent instructions (`AGENTS.MD`) and skills:

Check all destination paths before running these commands. Keep a link that already points here. If a destination is a file, directory, or different link, keep its contents and resolve the conflict first. Do not force replacement or create a nested `skills` link.

```sh
mkdir -p ~/.claude ~/.codex ~/.agents
ln -s ~/Projects/agent-scripts/AGENTS.MD ~/.claude/CLAUDE.md
ln -s ~/Projects/agent-scripts/AGENTS.MD ~/.claude/AGENTS.md
ln -s ~/Projects/agent-scripts/AGENTS.MD ~/.codex/AGENTS.md
ln -s ~/Projects/agent-scripts/skills    ~/.claude/skills
ln -s ~/Projects/agent-scripts/skills    ~/.agents/skills
```

Codex reads shared user skills from `~/.agents/skills`. Use one directory link, not one link per skill. Keep `~/.codex/skills/.system` unchanged.

See [Codex skill discovery](https://developers.openai.com/codex/skills/#where-to-save-skills).

## 4. Statusline

```sh
scripts/install-statusline.sh   # symlinks ~/.claude/statusline.sh + wires settings.json. Idempotent.
```

## 5. Local commit helper

Use `scripts/committer` from this repo. Do not install a global command or change `PATH`.

```sh
scripts/committer "commit message" path/to/file
```

## 6. Commit hooks (skill validation)

```sh
git config core.hooksPath hooks   # runs scripts/validate-skills on pre-commit
```

## 7. settings.json

Not tracked here (per-machine: hooks, permissions, statusLine). Step 4 patches it in place. If migrating a machine, copy the old `~/.claude/settings.json` over manually and re-run `install-statusline.sh` to confirm the entries survived.

Keep existing permissions and hooks. Do not copy another machine's settings unless a migration is required. Statusline configuration does not install Claude Code.

## 8. Verify

```sh
command -v git python3 uv ruby jq bun
uv run --no-project --isolated --python 3.13 python -c 'import sys; print(sys.version)'
hooks/pre-commit
bun scripts/docs-list.ts
printf '%s' '{"model":{"display_name":"Setup check"},"context_window":{"used_percentage":42}}' | ~/.claude/statusline.sh
```

The hook must validate the shared skills. The statusline must show `Setup check` and `42%` without errors. Restart the agent to load the shared instructions and skills. The Claude statusline appears when Claude Code is installed and restarted.
