#!/bin/bash
# Starts PHP-FPM and Nginx using the config files in /home/container.
DEFAULTS=/opt/webhost
cd /home/container || exit 1

warn() { echo -e "\033[1;33m[WARNING]\033[0m $*"; }
fail() { echo -e "\033[0;31m[ERROR]\033[0m $*"; exit 1; }

mkdir -p webroot logs tmp nginx/conf.d php-fpm/pool.d php-fpm/conf.d
rm -rf tmp/*

# Copy default config files that are missing. Existing files are never overwritten.
seed() {
    [ -e "$1" ] || cp "$DEFAULTS/$1" "$1"
}
seed nginx/nginx.conf
seed php-fpm/php-fpm.conf
seed php-fpm/pool.d/www.conf
seed php-fpm/conf.d/99-webhost.ini
if [ ! -e nginx/conf.d/default.conf ]; then
    if [ "${NAMELESSMC}" = "1" ] || [ "${NAMELESSMC}" = "true" ]; then
        cp "$DEFAULTS/templates/namelessmc.conf" nginx/conf.d/default.conf
    else
        cp "$DEFAULTS/nginx/conf.d/default.conf" nginx/conf.d/default.conf
    fi
fi
[ -n "$(ls -A webroot)" ] || cp "$DEFAULTS/webroot/index.php" webroot/index.php

# Listen on the server's primary allocation.
if [ -n "${SERVER_PORT}" ]; then
    sed -i -E "s/^([[:space:]]*listen[[:space:]]+)[0-9]+;/\1${SERVER_PORT};/" nginx/conf.d/default.conf
fi

# Authenticate git over HTTPS without storing the token in .git/config.
GIT_AUTH=()
if [ -n "${USERNAME}" ] && [ -n "${ACCESS_TOKEN}" ]; then
    GIT_AUTH=(-c "http.extraHeader=Authorization: Basic $(printf '%s:%s' "${USERNAME}" "${ACCESS_TOKEN}" | base64 | tr -d '\n')")
fi
if { [ "${AUTO_UPDATE}" = "1" ] || [ "${AUTO_UPDATE}" = "true" ]; } && [ -d webroot/.git ]; then
    echo "Pulling the latest changes from git"
    git -C webroot "${GIT_AUTH[@]}" pull --ff-only || warn "git pull failed, starting with the current files"
fi

if [ -f webroot/composer.json ] && [ ! -d webroot/vendor ]; then
    composer install --no-dev --no-interaction --working-dir=webroot || warn "composer install failed"
fi
if [ -n "${COMPOSER_MODULES}" ]; then
    # shellcheck disable=SC2086
    composer require ${COMPOSER_MODULES} --no-interaction --working-dir=webroot || warn "composer require failed"
fi

php-fpm -y /home/container/php-fpm/php-fpm.conf -D || fail "PHP-FPM failed to start, see logs/php-fpm.log"

NGINX_ARGS=(-p /home/container/ -c /home/container/nginx/nginx.conf -e /home/container/logs/error.log)
nginx -t -q "${NGINX_ARGS[@]}" || fail "Nginx config test failed, check the nginx folder"

echo "Web server running on port ${SERVER_PORT}"
exec nginx "${NGINX_ARGS[@]}"
