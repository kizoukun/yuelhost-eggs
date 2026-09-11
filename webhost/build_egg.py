"""Generate egg-webhost.json from install.sh. Run: python3 webhost/build_egg.py"""
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


image = "ghcr.io/kizoukun/yolks:nginx_php_{}"

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {
        "version": "PTDL_v2",
        "update_url": "https://raw.githubusercontent.com/kizoukun/yuelhost-eggs/main/webhost/egg-webhost.json",
    },
    "exported_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    "name": "WebHost",
    "author": "kizoukungaming@gmail.com",
    "description": (
        "Nginx + PHP-FPM web hosting for any PHP or static website, with optional WordPress or "
        "NamelessMC install, git deployment and Composer packages."
    ),
    "features": None,
    "docker_images": {f"PHP {v}": image.format(v) for v in ("8.4", "8.5", "8.3", "8.2")},
    "file_denylist": [],
    "startup": "start-webhost",
    "config": {
        "files": "{}",
        "startup": json.dumps({"done": "Web server running on port"}, indent=4),
        "logs": "{}",
        "stop": "^C",
    },
    "scripts": {
        "installation": {
            "script": (here / "install.sh").read_text(),
            "container": "alpine:3.24",
            "entrypoint": "ash",
        }
    },
    "variables": [
        var("WordPress", "WORDPRESS", "0", "required|boolean",
            "Install the latest WordPress into an empty webroot.\n\n0 = off (default)\n1 = on"),
        var("NamelessMC", "NAMELESSMC", "0", "required|boolean",
            "Install the latest NamelessMC into an empty webroot and use its Nginx config.\n\n0 = off (default)\n1 = on"),
        var("Git Repository", "GIT_ADDRESS", "", "nullable|string|max:512",
            "HTTPS address of a git repository to deploy into webroot, e.g. https://github.com/user/site"),
        var("Git Branch", "BRANCH", "", "nullable|string|max:128",
            "Branch to clone. Leave blank for the default branch."),
        var("Git Username", "USERNAME", "", "nullable|string|max:128",
            "Username for a private repository."),
        var("Git Access Token", "ACCESS_TOKEN", "", "nullable|string|max:512",
            "Personal access token for a private repository. It is never written to .git/config."),
        var("Auto Update", "AUTO_UPDATE", "0", "required|boolean",
            "Pull the latest git changes on every start.\n\n0 = off (default)\n1 = on"),
        var("User Uploaded Files", "USER_UPLOAD", "0", "required|boolean",
            "Skip the website install and upload files yourself.\n\n0 = off (default)\n1 = on"),
        var("Composer Packages", "COMPOSER_MODULES", "", "nullable|string|max:512",
            "Composer packages to require on start, separated by spaces, e.g. guzzlehttp/guzzle"),
    ],
}

out = here / "egg-webhost.json"
out.write_text(json.dumps(egg, indent=4) + "\n")
print(out)
