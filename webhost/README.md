# WebHost

Nginx + PHP-FPM web hosting for any PHP or static website. Optionally installs WordPress or NamelessMC, deploys a git repository, and requires Composer packages.

## Images

| PHP | Image | Base |
| --- | --- | --- |
| 8.4 (default) | `ghcr.io/kizoukun/yolks:nginx_php_8.4` | Alpine 3.24 |
| 8.5 | `ghcr.io/kizoukun/yolks:nginx_php_8.5` | Alpine 3.24 |
| 8.3 | `ghcr.io/kizoukun/yolks:nginx_php_8.3` | Alpine 3.24 |
| 8.2 | `ghcr.io/kizoukun/yolks:nginx_php_8.2` | Alpine 3.22 |

Images are built from [`yolks/nginx_php`](../yolks/nginx_php) and rebuilt weekly for Alpine security updates.

## Server files

| Path | Purpose |
| --- | --- |
| `webroot/` | Website files |
| `nginx/nginx.conf`, `nginx/conf.d/default.conf` | Nginx config |
| `php-fpm/php-fpm.conf`, `php-fpm/pool.d/www.conf` | PHP-FPM config |
| `php-fpm/conf.d/99-webhost.ini` | PHP settings (memory limit, upload size, ...) |
| `logs/` | Access, error and PHP logs |

Config files are created on the first start and never overwritten afterwards, so edits are kept. Delete a file and restart to get the default back. The `listen` port in `default.conf` is set to the server's primary allocation on every start.

## Setup

- **Static or PHP site:** upload files into `webroot`, or set **Git Repository** (plus username and access token for private repositories) and reinstall.
- **WordPress / NamelessMC:** enable the option and reinstall while `webroot` is empty, then open `http://ip:port/` to finish the setup. A database has to be created in the panel.
- **Composer:** a `composer.json` without `vendor/` is installed automatically on start; extra packages can be listed in **Composer Packages**.

## Notes

- Access logs are written to `logs/access.log` only; Nginx and PHP errors also show in the console.
- Dotfiles such as `.env` and `.git` are not served.
- The git access token is sent as an HTTP header and is not stored in `.git/config`.
