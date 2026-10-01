---
name: new-branch
description: 'Create a branch from latest origin/main named for the task. Use when starting new work, "new branch", "branch off main", or before editing on main.'
---

# new-branch

Branch from fresh `origin/<default>`, not stale local `main`. Name it from the task.

## Steps

1. `git status -sb`. Dirty tree: carried over if no conflicts; if switch refuses, stop + ask. Never stash/reset unasked.
2. Default branch: `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`); fallback `main`.
3. `git fetch origin <default>` (only that ref; cheap).
4. Name: match repo convention first (`git branch -a --sort=-committerdate | head` for prefixes). Else `type/short-kebab-slug` (`feat|fix|refactor|docs|chore|test`), 2-5 words, lowercase, from the task's intent not its wording. Linked issue/ticket id → include (`fix/123-login-redirect`).
5. Exists already (local or `origin/`)? Don't reuse; add a distinguishing word, or ask if it looks like the same work.
6. `git switch -c <name> --no-track origin/<default>`. `--no-track` so a bare `git push` never targets `main`.
7. Verify: `git status -sb`; report branch, base SHA (`git rev-parse --short origin/<default>`).

## Rules

- No worktrees, no push, no commits. Stay in cwd checkout.
- Fetch fails (offline/auth): say so; don't fall back to local `main` silently. Ask.
- Task vague: pick best-guess name, say it, move on. Don't interview.
