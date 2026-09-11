"""Generate egg-n8n.json. Run: python3 n8n/build_egg.py"""
import json
from datetime import datetime, timezone
from pathlib import Path

here = Path(__file__).parent


def var(name, env, default, rules, description):
    return {
        "name": name,
        "description": description,
        "env_variable": env,
        "default_value": default,
        "user_viewable": True,
        "user_editable": True,
        "rules": rules,
        "field_type": "text",
    }


install_script = """#!/bin/ash
# n8n installation script
# The n8n code ships in the yolk image; workflows and credentials are stored in .n8n on the server.
mkdir -p /mnt/server/.n8n
echo "n8n install complete"
"""

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {
        "version": "PTDL_v2",
        "update_url": "https://raw.githubusercontent.com/kizoukun/yuelhost-eggs/main/n8n/egg-n8n.json",
    },
    "exported_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    "name": "n8n",
    "author": "kizoukungaming@gmail.com",
    "description": (
        "n8n workflow automation. Build automations with 400+ integrations, webhooks, "
        "schedules and AI agents in a visual editor.\n\n"
        "Open http://ip:port after the first start to create the owner account.\n\n"
        "https://n8n.io"
    ),
    "features": None,
    "docker_images": {"n8n (latest)": "ghcr.io/kizoukun/yolks:n8n"},
    "file_denylist": [],
    # exec so Ctrl+C from the panel reaches n8n directly and it shuts down gracefully.
    "startup": "exec n8n start",
    "config": {
        "files": "{}",
        "startup": json.dumps({"done": "Editor is now accessible via"}, indent=4),
        "logs": "{}",
        "stop": "^C",
    },
    "scripts": {
        "installation": {
            "script": install_script,
            "container": "alpine:3.24",
            "entrypoint": "ash",
        }
    },
    "variables": [
        var("Public URL", "N8N_EDITOR_BASE_URL", "", "nullable|url|max:256",
            "Public address when n8n is served on a domain through a reverse proxy, "
            "e.g. https://n8n.example.com. Used for the editor and webhook URLs. Leave blank to use http://ip:port."),
        var("Timezone", "GENERIC_TIMEZONE", "Asia/Jakarta", "required|string|max:64",
            "Timezone for Schedule triggers and date functions, e.g. Asia/Jakarta or UTC."),
        var("Database Type", "DB_TYPE", "sqlite", "required|string|in:sqlite,postgresdb",
            "sqlite (default, stored in .n8n) or postgresdb. MySQL is not supported by n8n."),
        var("PostgreSQL Host", "DB_POSTGRESDB_HOST", "", "nullable|string|max:256",
            "PostgreSQL host when Database Type is postgresdb."),
        var("PostgreSQL Port", "DB_POSTGRESDB_PORT", "5432", "required|integer|between:1,65535",
            "PostgreSQL port."),
        var("PostgreSQL Database", "DB_POSTGRESDB_DATABASE", "n8n", "nullable|string|max:128",
            "PostgreSQL database name."),
        var("PostgreSQL User", "DB_POSTGRESDB_USER", "", "nullable|string|max:128",
            "PostgreSQL username."),
        var("PostgreSQL Password", "DB_POSTGRESDB_PASSWORD", "", "nullable|string|max:256",
            "PostgreSQL password."),
        var("Telemetry", "N8N_DIAGNOSTICS_ENABLED", "false", "required|string|in:true,false",
            "Send anonymous usage data to n8n.\n\nfalse = off (default)\ntrue = on"),
    ],
}

out = here / "egg-n8n.json"
out.write_text(json.dumps(egg, indent=4) + "\n")
print(out)
