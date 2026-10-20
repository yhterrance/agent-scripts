# Agent Scripts

Shared agent instructions, skills, and small portable helpers for Terrance's local workspaces.

Setting up a fresh machine? See [`SETUP.md`](SETUP.md).

This repo is the canonical place for:
- `AGENTS.MD`: shared hard rules for Codex/Claude-style agents
- `skills/`: reusable workflow skills, including pointers to repo-owned skills
- [`scripts/`](scripts/): dependency-light helpers used across projects
- `hooks/`: local guardrails such as skill validation

## Skills

Skills are the main routing layer. Each `skills/<name>/SKILL.md` has YAML front matter:

```yaml
---
name: skill-name
description: "Short generic trigger phrase."
---
```

Rules:
- Keep descriptions short and generic; optimize for routing, not documentation.
- Keep skill bodies terse and operational.
- Prefer helper scripts under `skills/<name>/scripts/` when a workflow has repeatable commands.
- Validate after edits: `scripts/validate-skills`.
- Quote `description` in front matter.

Shared skills live in `skills/`; repo-owned skills stay in their source repo and use a pointer `SKILL.md` here, with local notes taking precedence.

## Agent Instructions

Shared hard rules live in `AGENTS.MD`.

Downstream repos should use a pointer-style `AGENTS.MD`:

```text
READ ~/Projects/agent-scripts/AGENTS.MD BEFORE ANYTHING (skip if missing).
```

Repo-specific rules go below that pointer. Do not copy the shared blocks into downstream repos.
