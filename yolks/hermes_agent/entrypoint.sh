#!/bin/bash
# Pterodactyl entrypoint for Hermes Agent. Prepares HERMES_HOME the way the
# upstream s6 stage2 hook does, then runs the egg's startup command.
cd /home/container || exit 1

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Blank egg variables arrive as empty strings; unset them so Hermes treats
# them as not configured instead of as empty credentials.
while IFS='=' read -r name _; do
    unset "$name"
done < <(env | grep -E '^[A-Za-z_][A-Za-z0-9_]*=$')

# Earlier versions kept agent data in /home/container/.hermes; move it to the
# server root once.
if [ -d /home/container/.hermes ] && [ "$HERMES_HOME" = /home/container ] && [ ! -e /home/container/config.yaml ]; then
    echo "Moving Hermes data from .hermes to the server root"
    shopt -s dotglob nullglob
    mv -n /home/container/.hermes/* /home/container/
    shopt -u dotglob nullglob
    rmdir /home/container/.hermes 2>/dev/null \
        || echo "Warning: some files already existed in the server root and were left in .hermes"
fi

mkdir -p \
    "$HERMES_HOME/backups" \
    "$HERMES_HOME/cron" \
    "$HERMES_HOME/sessions" \
    "$HERMES_HOME/logs/gateways" \
    "$HERMES_HOME/hooks" \
    "$HERMES_HOME/memories" \
    "$HERMES_HOME/skills" \
    "$HERMES_HOME/skins" \
    "$HERMES_HOME/plans" \
    "$HERMES_HOME/workspace" \
    "$HERMES_HOME/home" \
    "$HERMES_HOME/pairing" \
    "$HERMES_HOME/platforms/pairing" \
    "$HERMES_HOME/lazy-packages"

# Seed config files on first boot only.
seed() {
    if [ ! -f "$HERMES_HOME/$1" ] && [ -f "/opt/hermes/$2" ]; then
        cp "/opt/hermes/$2" "$HERMES_HOME/$1"
    fi
}
seed ".env" ".env.example"
seed "SOUL.md" "docker/SOUL.md"

# Start config.yaml at the current schema version. `hermes config set` on a
# missing file writes no version, and the next boot's migration then treats
# the config as too old to migrate.
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
    config_version=$(/opt/hermes/.venv/bin/python -c 'from hermes_cli.config import DEFAULT_CONFIG; print(DEFAULT_CONFIG["_config_version"])' 2>/dev/null)
    [ -n "$config_version" ] && printf '_config_version: %s\n' "$config_version" > "$HERMES_HOME/config.yaml"
fi
[ -f "$HERMES_HOME/.env" ] && chmod 600 "$HERMES_HOME/.env"

# Image updates replace the code but keep HERMES_HOME, so run the same
# config schema migrations the upstream image runs on boot.
if [ -f "$HERMES_HOME/config.yaml" ] && [ -f /opt/hermes/scripts/docker_config_migrate.py ]; then
    /opt/hermes/.venv/bin/python /opt/hermes/scripts/docker_config_migrate.py \
        || echo "Warning: config migration failed, continuing"
fi

/opt/hermes/.venv/bin/python /opt/hermes/tools/skills_sync.py > /dev/null \
    || echo "Warning: bundled skills sync failed, continuing"

# agent-browser does not find the Playwright Chromium layout on its own.
if [ -z "$AGENT_BROWSER_EXECUTABLE_PATH" ] && [ -d "$PLAYWRIGHT_BROWSERS_PATH" ]; then
    browser_bin=$(find "$PLAYWRIGHT_BROWSERS_PATH" -type f -executable \
        \( -name chrome -o -name chromium -o -name chrome-headless-shell -o -name headless_shell -o -name chromium-browser \) \
        2>/dev/null | head -n 1)
    [ -n "$browser_bin" ] && export AGENT_BROWSER_EXECUTABLE_PATH="$browser_bin"
fi

# Convert "{{VARIABLE}}" in the startup command to "${VARIABLE}" and run it.
PARSED=$(echo "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g')
printf "\033[1m\033[33mcontainer~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
eval "$PARSED"
