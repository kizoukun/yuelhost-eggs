ARG HERMES_VERSION=v2026.9.7
FROM nousresearch/hermes-agent:${HERMES_VERSION}

LABEL org.opencontainers.image.source="https://github.com/kizoukun/yuelhost-eggs" \
      org.opencontainers.image.description="Hermes Agent (Nous Research) yolk for Pterodactyl eggs" \
      org.opencontainers.image.licenses="MIT"

USER root

# Pterodactyl runs servers as an unprivileged user with the server files mounted
# on /home/container, so the upstream s6 /init bootstrap (which needs root) is
# replaced by a yolk-style entrypoint. The upstream /usr/bin/tini is only a shim
# that execs /init, so swap it for the real tini.
RUN rm -f /usr/bin/tini \
    && apt-get -o Acquire::Retries=3 update \
    && apt-get -o Acquire::Retries=3 install -y --no-install-recommends tini iproute2 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container -s /bin/bash container

ENV USER=container \
    HOME=/home/container \
    HERMES_HOME=/home/container \
    HERMES_WRITE_SAFE_ROOT=/home/container \
    HERMES_LAZY_INSTALL_TARGET=/home/container/lazy-packages \
    PATH=/opt/hermes/bin:/opt/hermes/.venv/bin:/home/container/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

USER container
WORKDIR /home/container

STOPSIGNAL SIGINT

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
