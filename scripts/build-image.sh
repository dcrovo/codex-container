#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${CODEX_SANDBOX_IMAGE:-local/codex-sandbox:latest}"

MODE="${1:---build}"

DOCKER_BUILD_FLAGS=()

case "$MODE" in
    --build)
        ;;
    --update|--rebuild)
        DOCKER_BUILD_FLAGS+=(--pull --no-cache)
        ;;
    *)
        echo "Usage: $0 [--build|--update|--rebuild]" >&2
        exit 2
        ;;
esac

echo "Building Codex sandbox image:"
echo "  Image: $IMAGE"
echo "  Context: $REPO_ROOT"

docker build \
    "${DOCKER_BUILD_FLAGS[@]}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t "$IMAGE" \
    "$REPO_ROOT"
