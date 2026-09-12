# n8n

[n8n](https://n8n.io) is a workflow automation tool with 400+ integrations, webhooks, schedules and AI agents in a visual editor.

## Image

`ghcr.io/kizoukun/yolks:n8n` is built from the official `n8nio/n8n` image (see [`yolks/n8n`](../yolks/n8n)). The tag follows the latest stable n8n release, and every release is also published as `n8n_<version>`, e.g. `n8n_2.38.7`. Wings pulls the image when the server starts, so a restart picks up a new release.

## Setup

1. Start the server and open `http://ip:port`.
2. Create the owner account.

The server's primary allocation is used as the n8n port.

### Domain

To serve n8n on a domain, point a reverse proxy at the allocation and set **Public URL** to the domain, e.g. `https://n8n.example.com`. The editor and webhook URLs then use it, n8n trusts one proxy hop, and secure cookies are enabled for `https` URLs. Without a Public URL, webhooks use `http://ip:port` and secure cookies are off so the login works over plain HTTP.

### Database

SQLite is used by default and stored in `.n8n/database.sqlite`. For larger setups, set **Database Type** to `postgresdb` and fill in the PostgreSQL variables. MySQL/MariaDB databases from the panel are not supported by n8n.

## Server files

| Path | Purpose |
| --- | --- |
| `.n8n/config` | Encryption key for stored credentials. Back it up together with the database. |
| `.n8n/database.sqlite` | Workflows, credentials and executions (SQLite) |
| `.n8n/nodes/` | Community nodes |

## Notes

- **Memory:** give the server at least 2 GB. n8n runs a main process plus a task runner child process; the memory limit is split between them (55% main heap, 20% runner heap) and the server warns in the console below 2 GB. Database migrations on start are the heaviest moment, so a 1 GB server gets killed for running out of memory (exit code 137).
- Task runners run in internal mode, so the Code node supports JavaScript. Python in the Code node needs an external runner and is not available.
- Community nodes are limited to verified ones (`N8N_UNVERIFIED_PACKAGES_ENABLED=false`).
- The settings n8n warns about deprecating are pinned in the image, so upstream default changes never move them under a running server.
- Telemetry to n8n is off by default.
