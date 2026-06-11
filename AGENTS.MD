Work style: telegraph; noun-phrases ok; drop grammar; min tokens.
Codex CLI output: avoid Markdown tables by default; they render poorly there. Use short bullets or `key: value` lines instead. Only use a table when explicitly requested.

## Core

- Workspace: `~/Projects`. Missing Terrance repo: clone from your GitHub account or ask for the repo URL. 3rd-party/OSS: `~/Projects/oss`.
- "Make a note" here => terse `AGENTS.MD` edit. No separate `CLAUDE.md` here.
- `ship` => changelog, commit in groups, push, pull.
- Release closeout: after verified release, bump changelog to next patch `Unreleased`, commit.
- Release verify: confirm release docs/notes contain changelog; if missing/stale, fix before closeout.
- npm release verify: `npm view <pkg>@<version>` shows version, dist-tag, tarball, integrity, publish time; GitHub tag + Release exist; Release body links npm version page, registry tarball, integrity, CI/proof.
- Changelogs: match file style; prefer one bullet per entry on one line. Do not hard-wrap changelog bullets just because prose is long.
- Skills are canonical for tool workflows. Keep this file to hard rules only.
- Editing here/skills: token-efficient, relaxed grammar, terse descriptions.
- Skill descriptions: short generic trigger phrase, not summary; no personal names, long paths, or workflow narration unless needed for routing.
- Skill frontmatter: quote `description`; after SKILL.md edits, YAML-parse frontmatter before commit.
- Search tools: use `ast-grep` if available; otherwise `rg`, then `grep`.
- Read `~/Projects/agent-scripts/tools.md` when the tool catalog matters.

## Routing

- Screenshots/assets: newest PNG in `~/Desktop` or `~/Downloads`; verify UI before replacing.
- Private/history: local archives first; verify freshness for current questions.
- Secrets/API keys/live creds: use `$one-password`; env only if already exported; `op` is skill/tmux-only, no broad enumeration/secret output.
- Shell: Terrance uses Fish interactively, but agent commands run zsh/POSIX unless explicitly writing commands for Terrance to paste.

## Project Defaults

- Need upstream file: stage in `/tmp/`, then cherry-pick; never overwrite tracked files.
- Bugs: add regression test when it fits.
- Use repo package manager/runtime; no swaps without approval.
- Docs: read repo docs before coding; update docs/changelog for user-visible behavior changes.
- Dependency source: before reading `node_modules`, check source in `~/Projects/oss`; if missing, then inspect `node_modules`.
- Inline code comments: brief notes for tricky, bug-prone, or previously buggy logic. Capture non-obvious why once at the owning site; don't restate a fact across comments or narrate what code shows; if removing loses no fact, drop it.
- New deps: quick health check for recent releases/commits/adoption.

## PR / CI

- GitHub broad reads: prefer shimmed `gh` / `gitcrawl gh` first. Raw `gh api search/* -f ...` needs `--method GET`; gitcrawl shim sanitizes this.
- PR refs: use `gh pr view/diff`, not web search.
- PR title: match repo style; default `type(scope): description`, imperative/lowercase/no period, <72 chars. No `!`/`BREAKING CHANGE:` without explicit confirmation.
- PR body: value-first; explain what is now possible/fixed/changed, not file list. Diff is visible.
- PR body size: small simple = 1-2 sentences; non-trivial = 3-5; large = selective design decisions + brief tests, ~100 lines target, 150 cap.
- PR body sections: Summary when headings exist; Test Plan when verification non-obvious; Demo/Screenshots only for real evidence, never test output.
- PR Test Plan: include commands/checks actually run, manual verification, and skipped checks with reason. Omit for trivial docs/config typo when verification is self-evident.
- PR visuals: use diagram/table only when faster than prose; prose stays authoritative.
- PRs: prefer rewriting/fixing the PR, then merging it, over closing and committing equivalent files directly.
- Landing own draft PR after explicit land request: ignore draft status; mark ready if needed and continue.
- `fix ci`: consent to pull, commit, push; fix/rerun/watch until CI green.
- CI: `gh run list/view`; rerun/fix until green when asked.
- `rewrite commits + land`: clean stack, agreed focused proof only, force-push, merge. No PR-body proof polish or CI babysitting unless asked.
- Replies: cite fix + file/line; resolve threads only after fix lands.
- Issue fixed on `main` with proof: comment proof + commit/PR, then close.
- User-facing fixes/landed PRs: changelog unless pure test/internal.
- Contributor PR authors should not edit changelog; maintainer/AI adds entry at merge.
- After landing: final includes 2-5 sentence recap of what landed.
- After landing: checkout `main`, pull `--ff-only`, verify `git status -sb`, then final.
- When merging contributor PRs: thank contributor in `CHANGELOG.md`.
- Unpushable contributor PRs (`maintainerCanModify=false`/no head write): if fixups needed, recreate locally from PR head/diff, make one maintainer commit, push it, then close PR with comment.
- Preserve contributor credit: commit body includes `Co-authored-by: Name <email>` from PR commit author; changelog still thanks `@login` when user-facing.
- PR fixups from repo cwd: use that checkout. No worktrees unless asked; if awkward, ask.
- Close comment: link landed commit, explain PR branch could not be updated, thank author, suggest enabling "Allow edits by maintainers" for future PRs.

## Runtime Safety

- zsh: don't use `status` as a variable.
- Public GitHub bodies: never inline double-quoted text with backticks, `$`, shell snippets, env names, or user text. Use temp file + `cat <<'EOF'` + inspect + `--body-file`.
- Secrets: never run `env`, `set`, `export -p`, or broad secret regex dumps in a normal shell. Query exact names only; redact values.
- After touching secrets/env, public `gh` writes use token env unset where possible: `env -u GITHUB_TOKEN -u GH_TOKEN -u HOMEBREW_GITHUB_API_TOKEN ...`.

## Git

- If cwd is in a git repo: work there. Do not jump to sibling checkout unless asked.
- No `git worktree` from CLI sessions unless user asks. If dirty/wrong branch/awkward: ask.
- Branch switch/checkout ok when task needs it and repo rules allow.
- `~/Projects` has many intentional same-repo checkouts. Treat as user-managed, not scratch.
- If cwd is not a git repo: freeform; pick sensible folder, say path before edits. Worktrees ok if useful.
- Safe by default: `git status/diff/log`.
- Push only when user asks.
- End in visible checkout/branch user expects.
- Branch changes require user consent.
- Destructive ops forbidden unless explicit: `reset --hard`, `clean`, `restore`, `rm`, etc.
- Commit helper on PATH: `committer` (bash). Prefer it; if repo has `./scripts/committer`, use that.
- Commit style: project convention > recent commits > Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).
- Commit subject: concise, imperative, why/value over file list. Ambiguous `feat`/`fix` => `fix`; reserve `feat` for new user capability.
- Commit body: only when useful; explain motivation/tradeoffs/future-reader context.
- Never add Claude/AI `Co-Authored-By` trailer to commits or PR bodies (overrides default). Human `Co-authored-by` from PR authors still kept per above.
- Commit grouping: split obvious unrelated concerns, file-level only, 2-3 max; otherwise one commit.
- Commit staging: specific files; avoid `git add -A` / `git add .`.
- No repo-wide S/R scripts; keep edits small/reviewable.
- If user types a command ("pull and push"), that's consent for that command.
- No amend unless asked.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
