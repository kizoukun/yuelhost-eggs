# YuelHost Eggs

Pterodactyl eggs and yolks (Docker images) used on YuelHost.

## Eggs

| Egg | Image |
| --- | --- |
| [Hermes Agent](hermes_agent) | `ghcr.io/kizoukun/yolks:hermes_agent` |

Import an egg in the panel under **Admin → Nests → Import Egg** using the `egg-*.json` file.

## Yolks

Images live in [`yolks/`](yolks) and are built and pushed to GHCR by GitHub Actions.

| Image | Source | Tags |
| --- | --- | --- |
| `ghcr.io/kizoukun/yolks:hermes_agent` | [`yolks/hermes_agent`](yolks/hermes_agent) | `hermes_agent` (latest release), `hermes_agent_<version>` |

The Hermes Agent workflow checks for a new upstream release every 6 hours and can be run manually with a specific version.
