#!/usr/bin/env bash
set -euo pipefail

IMAGE="${CODEX_SANDBOX_IMAGE:-local/codex-sandbox:latest}"

MODE="codex"

if [[ "${1:-}" == "--shell" ]]; then
    MODE="shell"
    shift
fi

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Codex sandbox image not found."
    echo
    echo "Build it with:"
    echo "  codex --build"
    echo
    echo "Or from the repo:"
    echo "  ./install.sh --build"
    exit 127
fi

WORKDIR="$(pwd -P)"
VOLUME_NAME="codex-sandbox-home-$(id -u)"
VOLUME_NAME="$(printf "%s" "$VOLUME_NAME" | tr -c "a-zA-Z0-9_.-" "_")"

TTY_ARGS=()
if [[ -t 0 && -t 1 ]]; then
    TTY_ARGS=(-it)
else
    TTY_ARGS=(-i)
fi

DOCKER_ARGS=(
    --rm
    "${TTY_ARGS[@]}"
    --init

    --hostname codex-sandbox
    --workdir /workspace

    --mount "type=bind,src=${WORKDIR},dst=/workspace,rw"
    --mount "type=volume,src=${VOLUME_NAME},dst=/home/codex"

    --tmpfs /tmp:rw,nosuid,nodev,size=1g
    --tmpfs /run:rw,nosuid,nodev,size=128m

    --read-only
    --cap-drop=ALL
    --security-opt no-new-privileges

    --pids-limit 512
    --memory 4g
    --cpus 4

    --env HOME=/home/codex
    --env USER=codex
    --env XDG_CONFIG_HOME=/home/codex/.config
    --env XDG_DATA_HOME=/home/codex/.local/share
    --env XDG_CACHE_HOME=/tmp/.cache
    --env NPM_CONFIG_CACHE=/tmp/npm-cache
    --env TMPDIR=/tmp

    --env OPENAI_API_KEY
    --env OPENAI_BASE_URL
    --env HTTP_PROXY
    --env HTTPS_PROXY
    --env NO_PROXY
)

if [[ "$MODE" == "shell" ]]; then
    if [[ "$#" -eq 0 ]]; then
        set -- -l
    fi

    exec docker run \
        "${DOCKER_ARGS[@]}" \
        --entrypoint /bin/bash \
        "$IMAGE" \
        "$@"
else
    exec docker run \
        "${DOCKER_ARGS[@]}" \
        "$IMAGE" \
        "$@"
fi
