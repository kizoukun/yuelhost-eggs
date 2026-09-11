# YuelHost Eggs

Pterodactyl eggs and yolks (Docker images) used on YuelHost.

## Eggs

| Egg | Image |
| --- | --- |
| [Hermes Agent](hermes_agent) | `ghcr.io/kizoukun/yolks:hermes_agent` |
| [WebHost](webhost) | `ghcr.io/kizoukun/yolks:nginx_php_<8.2-8.5>` |

Import an egg in the panel under **Admin → Nests → Import Egg** using the `egg-*.json` file.

## Yolks

Images live in [`yolks/`](yolks) and are built and pushed to GHCR by GitHub Actions.

| Image | Source | Tags |
| --- | --- | --- |
| `ghcr.io/kizoukun/yolks:hermes_agent` | [`yolks/hermes_agent`](yolks/hermes_agent) | `hermes_agent` (latest release), `hermes_agent_<version>` |
| `ghcr.io/kizoukun/yolks:nginx_php_<version>` | [`yolks/nginx_php`](yolks/nginx_php) | `nginx_php_8.2`, `nginx_php_8.3`, `nginx_php_8.4`, `nginx_php_8.5` |

The Hermes Agent workflow checks for a new upstream release every 6 hours and can be run manually with a specific version. The Nginx PHP images are rebuilt weekly for Alpine security updates.
