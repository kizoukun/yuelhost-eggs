ARG N8N_VERSION=2.38.7
FROM n8nio/n8n:${N8N_VERSION}

LABEL org.opencontainers.image.source="https://github.com/kizoukun/yuelhost-eggs" \
      org.opencontainers.image.description="n8n yolk for Pterodactyl eggs" \
      org.opencontainers.image.licenses="SUL-1.0"

# Pterodactyl mounts the server files on /home/container and runs the container
# as its own unprivileged user; n8n keeps its data in /home/container/.n8n.
ENV USER=container \
    HOME=/home/container \
    N8N_USER_FOLDER=/home/container \
    N8N_LISTEN_ADDRESS=0.0.0.0

# Pin the settings n8n warns about deprecating, so an upstream default change
# never moves them under a running server. Community nodes stay limited to
# verified ones, and the compression limits use the safer upcoming defaults.
ENV N8N_UNVERIFIED_PACKAGES_ENABLED=false \
    N8N_RUNNERS_TASK_TIMEOUT=300 \
    N8N_COMPRESSION_NODE_MAX_DECOMPRESSED_SIZE_BYTES=268435456 \
    N8N_COMPRESSION_NODE_MAX_ZIP_ENTRIES=1000

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

WORKDIR /home/container

STOPSIGNAL SIGINT

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
