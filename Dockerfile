FROM node:22-bookworm-slim

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    bash \
    less \
    nano \
    ripgrep \
    fd-find \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @openai/codex@latest \
    && npm cache clean --force

RUN set -eux; \
    if getent passwd node >/dev/null 2>&1; then userdel -r node || true; fi; \
    if getent group node >/dev/null 2>&1; then groupdel node || true; fi; \
    if ! getent group "${GROUP_ID}" >/dev/null 2>&1; then groupadd -g "${GROUP_ID}" codex; fi; \
    if ! getent passwd "${USER_ID}" >/dev/null 2>&1; then useradd -m -u "${USER_ID}" -g "${GROUP_ID}" -s /bin/bash codex; fi; \
    mkdir -p /home/codex; \
    chown -R "${USER_ID}:${GROUP_ID}" /home/codex

USER ${USER_ID}:${GROUP_ID}

WORKDIR /workspace

ENV HOME=/home/codex
ENV USER=codex
ENV XDG_CONFIG_HOME=/home/codex/.config
ENV XDG_DATA_HOME=/home/codex/.local/share
ENV XDG_CACHE_HOME=/tmp/.cache
ENV NPM_CONFIG_CACHE=/tmp/npm-cache
ENV TMPDIR=/tmp

ENTRYPOINT ["codex"]
