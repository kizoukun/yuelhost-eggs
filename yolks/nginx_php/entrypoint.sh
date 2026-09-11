#!/bin/bash
# Pterodactyl entrypoint for the Nginx + PHP-FPM yolk.
cd /home/container || exit 1

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Convert "{{VARIABLE}}" in the startup command to "${VARIABLE}" and run it.
PARSED=$(echo "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g')
printf "\033[1m\033[33mcontainer~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
eval "$PARSED"
