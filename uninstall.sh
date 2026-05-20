#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${CODEX_SANDBOX_INSTALL_DIR:-$HOME/.local/bin}"
TARGET="$INSTALL_DIR/codex"

if [[ -L "$TARGET" || -f "$TARGET" ]]; then
    rm -f "$TARGET"
    echo "Removed: $TARGET"
else
    echo "Nothing to remove: $TARGET does not exist"
fi

cat <<EOF

Docker image and auth volume were not removed.

To remove the image:
  docker rmi local/codex-sandbox:latest

To remove the persistent Codex home volume:
  docker volume rm codex-sandbox-home-\$(id -u)

EOF
