#!/usr/bin/env bash
# Install the Claude Code statusline on a new machine.
# Idempotent: symlinks ~/.claude/statusline.sh -> this repo, and points
# settings.json's statusLine at it. Safe to re-run.
set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/statusline.sh"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
LINK="$CLAUDE_DIR/statusline.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR"
chmod +x "$REPO_SCRIPT"

# Symlink, backing up any real file already there.
if [ -L "$LINK" ]; then
  rm "$LINK"
elif [ -e "$LINK" ]; then
  mv "$LINK" "$LINK.bak.$(date +%s)"
fi
ln -s "$REPO_SCRIPT" "$LINK"
echo "linked: $LINK -> $REPO_SCRIPT"

# Point settings.json at the link (create file if missing, preserve other keys).
python3 - "$SETTINGS" <<'PY'
import json, os, sys
path = sys.argv[1]
try:
    with open(path) as f:
        cfg = json.load(f)
except FileNotFoundError:
    cfg = {}
cfg["statusLine"] = {"type": "command", "command": "~/.claude/statusline.sh"}
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
print(f"configured statusLine in: {path}")
PY

echo "done. restart Claude Code to see the statusline."
