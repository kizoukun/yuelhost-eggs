"""Generate egg-minecraft-bedrock.json from install.sh. Run: python3 minecraft_bedrock/build_egg.py"""
import json
from datetime import datetime, timezone
from pathlib import Path

here = Path(__file__).parent


def var(name, env, default, rules, description, viewable=True):
    return {
        "name": name,
        "description": description,
        "env_variable": env,
        "default_value": default,
        "user_viewable": viewable,
        "user_editable": viewable,
        "rules": rules,
        "field_type": "text",
    }


# The yolk runs the startup line through `echo -e ${STARTUP}` and `eval`, so it must stay on one line with no
# glob characters (* ? [) and no backslashes. NETHERNET_UDP_PORTS comes from the panel (<public IP>:<port>:<port>),
# never from an egg variable, because the container sits on a Docker bridge and cannot see the node's public IP.
startup = "; ".join([
    # Binding the public IP inside the container breaks TCP, so server-ip is never written.
    "sed -i -e '/^server-ip=/d' -e '/^server-port=/d' -e '/^transport=/d' server.properties",
    'echo "server-port=${SERVER_PORT}" >> server.properties',
    "echo transport=nethernet >> server.properties",
    # Only one entry: comma lists in server-udp-ports break joins.
    'if test -n "${NETHERNET_UDP_PORTS}"; then sed -i "/^server-udp-ports=/d" server.properties'
    ' && echo "server-udp-ports=${NETHERNET_UDP_PORTS}" >> server.properties; fi',
    # Without a saved identity key players re-accept trust after every restart. On a start without one, feed
    # "serveridentity save" to the console once the signaling port answers, then pass the panel console through.
    # The explicit <&0 matters: bash otherwise points a background job's stdin at /dev/null and cat exits at once.
    "if test -f keys/server_identity_key.pem; then ./bedrock_server",
    "else rm -f /tmp/bds.in && mkfifo /tmp/bds.in",
    "(until (: < /dev/tcp/127.0.0.1/${SERVER_PORT}) 2>/dev/null; do sleep 2; done; echo serveridentity save; exec cat) <&0 > /tmp/bds.in &"
    " ./bedrock_server < /tmp/bds.in",
    "kill $! 2>/dev/null; fi",
])

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {
        "version": "PTDL_v2",
        "update_url": "https://raw.githubusercontent.com/kizoukun/yuelhost-eggs/main/minecraft_bedrock/egg-minecraft-bedrock.json",
    },
    "exported_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    "name": "Vanilla Bedrock",
    "author": "kizoukungaming@gmail.com",
    "description": (
        "Minecraft Bedrock Dedicated Server on the NetherNet transport, based on the pelican-eggs Vanilla Bedrock egg.\n\n"
        "Bedrock players join through the server subdomain on port 443 (TLS signaling through Nginx Proxy Manager); "
        "gameplay is UDP straight to the node on the server port. The panel sets NETHERNET_UDP_PORTS."
    ),
    "features": ["pid_limit"],
    "docker_images": {"ghcr.io/pelican-eggs/yolks:debian": "ghcr.io/pelican-eggs/yolks:debian"},
    "file_denylist": [],
    "startup": startup,
    "config": {
        "files": json.dumps({
            "server.properties": {
                "parser": "properties",
                "find": {
                    "server-port": "{{server.build.default.port}}",
                    "server-name": "{{server.build.env.SERVERNAME}}",
                    "gamemode": "{{server.build.env.GAMEMODE}}",
                    "difficulty": "{{server.build.env.DIFFICULTY}}",
                    "level-name": "{{server.build.env.WORLDNAME}}",
                    "allow-cheats": "{{server.build.env.CHEATS}}",
                },
            }
        }, indent=4),
        "startup": json.dumps({"done": "Server started"}, indent=4),
        "logs": "{}",
        "stop": "stop",
    },
    "scripts": {
        "installation": {
            "script": (here / "install.sh").read_text(),
            "container": "ghcr.io/pelican-eggs/installers:debian",
            "entrypoint": "bash",
        }
    },
    "variables": [
        var("Bedrock Version", "BEDROCK_VERSION", "latest", "required|string|max:20",
            "The version of bedrock. (Ex. 1.7.0.13)\n\nDefault version is latest."),
        var("ld lib path", "LD_LIBRARY_PATH", ".", "required|string|max:20",
            "Dumb reasons to need this", viewable=False),
        var("Server Name", "SERVERNAME", "Bedrock Dedicated Server", "required|string|max:50",
            "The name for the server"),
        var("Gamemode", "GAMEMODE", "survival", "required|string|in:survival,creative,adventure",
            'Allowed values: "survival", "creative", or "adventure"'),
        var("Difficulty", "DIFFICULTY", "easy", "required|string|in:peaceful,easy,normal,hard",
            'Allowed values: "peaceful", "easy", "normal", or "hard"'),
        var("Allow cheats", "CHEATS", "false", "required|string|in:true,false",
            'If true then cheats like commands can be used.\n\nAllowed values: "true" or "false"'),
        var("Choose World", "WORLDNAME", "default", "required|string|max:100",
            "If you have multiple world files, Enter the World Folder Name you want to Select to Start the Server"),
    ],
}

(here / "egg-minecraft-bedrock.json").write_text(json.dumps(egg, indent=4) + "\n")
print("wrote", here / "egg-minecraft-bedrock.json")
