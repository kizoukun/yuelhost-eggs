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

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

WORKDIR /home/container

STOPSIGNAL SIGINT

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
