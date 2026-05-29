---
name: slacrawl
description: "Slack archive: search, sync, threads/DMs, Slacrawl repo work."
---

# Slacrawl

First read canonical repo skill:

`~/Projects/slacrawl/.agents/skills/slacrawl/SKILL.md`

Treat it as the base workflow. Local notes here override it.

## Local Credentials

`bot`/`all` need API tokens; config reads them from env (`token_env`): `SLACK_BOT_TOKEN`, `SLACK_APP_TOKEN`, `SLACK_USER_TOKEN`. User token enables DM/mpim sync. Not exported by default; `doctor` shows them missing.

Tokens live in 1Password item `slacrawl-illoca` (vault `illoca`), fields `bot_token`/`app_token`/`user_token`. Inject via `op run` (refs only, never the values). `op` is tmux-only; sign in first per `$one-password` (`op signin --account my.1password.com`).

```bash
SLACK_BOT_TOKEN='op://illoca/slacrawl-illoca/bot_token' \
SLACK_APP_TOKEN='op://illoca/slacrawl-illoca/app_token' \
SLACK_USER_TOKEN='op://illoca/slacrawl-illoca/user_token' \
op run --account my.1password.com -- slacrawl sync --source bot --latest-only
```

`wiretap` needs no tokens (reads Slack Desktop cache); empty if the desktop app is logged out/not running.
