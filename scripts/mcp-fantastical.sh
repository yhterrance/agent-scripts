#!/bin/sh
set -eu

MISE_NPX="${HOME}/.local/share/mise/shims/npx"

if [ -x "$MISE_NPX" ]; then
  exec "$MISE_NPX" -y mcp-fantastical@1.2.0 "$@"
fi

exec npx -y mcp-fantastical@1.2.0 "$@"
