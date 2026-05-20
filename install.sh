#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${CODEX_SANDBOX_INSTALL_DIR:-$HOME/.local/bin}"
TARGET="$INSTALL_DIR/codex"

BUILD_AFTER_INSTALL="false"

case "${1:-}" in
    "")
        ;;
    --build)
        BUILD_AFTER_INSTALL="true"
        ;;
    --help|-h)
        cat <<EOF
Usage:
  ./install.sh           Install codex command only
  ./install.sh --build   Install codex command and build Docker image

Environment:
  CODEX_SANDBOX_INSTALL_DIR   Default: \$HOME/.local/bin
  CODEX_SANDBOX_IMAGE         Default: local/codex-sandbox:latest
EOF
        exit 0
        ;;
    *)
        echo "Unknown option: $1" >&2
        echo "Run: ./install.sh --help" >&2
        exit 2
        ;;
esac

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not installed or not available in PATH." >&2
    exit 1
fi

mkdir -p "$INSTALL_DIR"

chmod +x "$REPO_ROOT/bin/codex"
chmod +x "$REPO_ROOT/scripts/build-image.sh"
chmod +x "$REPO_ROOT/scripts/run-container.sh"

ln -sfn "$REPO_ROOT/bin/codex" "$TARGET"

echo "Installed codex sandbox command:"
echo "  $TARGET -> $REPO_ROOT/bin/codex"

case ":$PATH:" in
    *":$INSTALL_DIR:"*)
        ;;
    *)
        echo
        echo "Warning: $INSTALL_DIR is not in PATH."
        echo
        echo "For fish, run:"
        echo "  fish_add_path $INSTALL_DIR"
        echo
        echo "For bash/zsh, add this to your shell config:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        ;;
esac

if [[ "$BUILD_AFTER_INSTALL" == "true" ]]; then
    "$REPO_ROOT/scripts/build-image.sh" --build
else
    echo
    echo "Next step:"
    echo "  codex --build"
fi
