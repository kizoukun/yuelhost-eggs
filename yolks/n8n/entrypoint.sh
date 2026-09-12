#!/bin/sh
# Pterodactyl entrypoint for n8n.
cd /home/container || exit 1

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Blank egg variables arrive as empty strings; unset them so n8n uses its defaults.
for name in $(env | sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=$/\1/p'); do
    unset "$name"
done

# Listen on the server's primary allocation.
if [ -z "$N8N_PORT" ] && [ -n "$SERVER_PORT" ]; then
    export N8N_PORT="$SERVER_PORT"
fi

if [ -n "$N8N_EDITOR_BASE_URL" ]; then
    # A public URL means n8n is reached through a domain and reverse proxy.
    export N8N_WEBHOOK_URL="${N8N_WEBHOOK_URL:-$N8N_EDITOR_BASE_URL}"
    export N8N_PROXY_HOPS="${N8N_PROXY_HOPS:-1}"
elif [ -n "$SERVER_IP" ] && [ "$SERVER_IP" != "0.0.0.0" ] && [ -n "$SERVER_PORT" ]; then
    export N8N_HOST="${N8N_HOST:-$SERVER_IP}"
    export N8N_WEBHOOK_URL="${N8N_WEBHOOK_URL:-http://${SERVER_IP}:${SERVER_PORT}/}"
fi

# Secure cookies only work over HTTPS, so allow logging in on http://ip:port.
if [ -z "$N8N_SECURE_COOKIE" ]; then
    case "$N8N_EDITOR_BASE_URL" in
        https://*) export N8N_SECURE_COOKIE=true ;;
        *) export N8N_SECURE_COOKIE=false ;;
    esac
fi

# Keep the Node.js heaps inside the server's memory limit (SERVER_MEMORY is in
# MiB). n8n runs the main process plus a task runner child process, so the
# limit is split between them and a quarter is left for non-heap memory.
if [ "${SERVER_MEMORY:-0}" -gt 0 ] 2>/dev/null; then
    case "$NODE_OPTIONS" in
        *max-old-space-size*) ;;
        *) export NODE_OPTIONS="--max-old-space-size=$((SERVER_MEMORY * 55 / 100)) ${NODE_OPTIONS}" ;;
    esac
    if [ -z "$N8N_RUNNERS_MAX_OLD_SPACE_SIZE" ]; then
        export N8N_RUNNERS_MAX_OLD_SPACE_SIZE="$((SERVER_MEMORY * 20 / 100))"
    fi
    if [ "$SERVER_MEMORY" -lt 2048 ]; then
        echo "Warning: n8n needs about 2048 MiB of memory. This server has ${SERVER_MEMORY} MiB and may be killed while it runs out of memory."
    fi
fi

# Convert "{{VARIABLE}}" in the startup command to "${VARIABLE}" and run it.
PARSED=$(echo "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g')
printf "\033[1m\033[33mcontainer~ \033[0m%s\n" "$PARSED"
eval "$PARSED"
