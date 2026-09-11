#!/bin/ash
# Web hosting installation script
# Server files: /mnt/server
apk add --no-cache git curl unzip tar xz ca-certificates || { echo "Failed to install packages"; exit 1; }

mkdir -p /mnt/server/webroot /mnt/server/logs /mnt/server/tmp
cd /mnt/server/webroot || exit 1

is_true() {
    [ "$1" = "1" ] || [ "$1" = "true" ]
}

# The placeholder page created on first start does not count as website files.
if [ "$(ls -A)" = "index.php" ] && grep -q "Upload your website into the" index.php; then
    rm -f index.php
fi

if is_true "${USER_UPLOAD}"; then
    echo "User upload enabled, skipping website install"
    exit 0
fi

if is_true "${WORDPRESS}"; then
    if [ -n "$(ls -A)" ]; then
        echo "webroot is not empty, skipping WordPress install"
        exit 0
    fi
    echo "Installing WordPress"
    curl -fsSL -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz || { echo "Failed to download WordPress"; exit 1; }
    echo "$(curl -fsSL https://wordpress.org/latest.tar.gz.sha1)  /tmp/wordpress.tar.gz" | sha1sum -c - || { echo "WordPress checksum mismatch"; exit 1; }
    tar -xzf /tmp/wordpress.tar.gz --strip-components=1 -C /mnt/server/webroot
    rm -f /tmp/wordpress.tar.gz
    echo "WordPress installed. Open http://ip:port/ to finish the setup"
    exit 0
fi

if is_true "${NAMELESSMC}"; then
    if [ -n "$(ls -A)" ]; then
        echo "webroot is not empty, skipping NamelessMC install"
        exit 0
    fi
    echo "Installing NamelessMC"
    curl -fsSL -o /tmp/nameless.tar.xz https://github.com/NamelessMC/Nameless/releases/latest/download/nameless-deps-dist.tar.xz \
        || { echo "Failed to download NamelessMC"; exit 1; }
    tar -xJf /tmp/nameless.tar.xz -C /mnt/server/webroot
    rm -f /tmp/nameless.tar.xz
    # The archive root is mode 700, which tar applies to webroot.
    chmod 755 /mnt/server/webroot
    echo "NamelessMC installed. Open http://ip:port/ to finish the setup"
    exit 0
fi

if [ -n "${GIT_ADDRESS}" ]; then
    case "${GIT_ADDRESS}" in
        *.git) ;;
        *) GIT_ADDRESS="${GIT_ADDRESS}.git" ;;
    esac

    # Authenticate without storing the token in .git/config.
    set --
    if [ -n "${USERNAME}" ] && [ -n "${ACCESS_TOKEN}" ]; then
        set -- -c "http.extraHeader=Authorization: Basic $(printf '%s:%s' "${USERNAME}" "${ACCESS_TOKEN}" | base64 | tr -d '\n')"
    fi

    if [ -d .git ]; then
        echo "Pulling the latest changes"
        git "$@" pull --ff-only || { echo "git pull failed"; exit 1; }
    elif [ -n "$(ls -A)" ]; then
        echo "webroot has files but no git repository, skipping clone"
    elif [ -n "${BRANCH}" ]; then
        echo "Cloning branch ${BRANCH}"
        git "$@" clone --single-branch --branch "${BRANCH}" "${GIT_ADDRESS}" . || { echo "git clone failed"; exit 1; }
    else
        echo "Cloning the default branch"
        git "$@" clone "${GIT_ADDRESS}" . || { echo "git clone failed"; exit 1; }
    fi
    exit 0
fi

echo "Install complete. A placeholder page is created on first start"
