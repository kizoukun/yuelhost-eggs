"""Generate egg-hermes-agent.json. Run: python3 hermes_agent/build_egg.py"""
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


install_script = """#!/bin/bash
# Hermes Agent installation script
# The Hermes Agent code ships in the yolk image; agent data is stored in the server root.
echo "Hermes Agent install complete"
"""

# The provider is written on every start so clearing the variable resets it to auto-detect.
startup = (
    'hermes config set model.provider "${HERMES_PROVIDER:-auto}"; '
    'if [ -n "${HERMES_MODEL}" ]; then hermes config set model.default "${HERMES_MODEL}"; fi; '
    "exec hermes gateway run --replace -v"
)

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {
        "version": "PTDL_v2",
        "update_url": "https://raw.githubusercontent.com/kizoukun/yuelhost-eggs/main/hermes_agent/egg-hermes-agent.json",
    },
    "exported_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    "name": "Hermes Agent",
    "author": "kizoukungaming@gmail.com",
    "description": (
        "Hermes Agent by Nous Research, the self-improving open-source AI agent, running as a "
        "Telegram / Discord messaging gateway with persistent memory, skills and cron.\n\n"
        "Set an LLM API key plus a bot token and allowed user IDs, then start the server. "
        "Other providers and platforms can be configured in .env and config.yaml in the server root.\n\n"
        "https://github.com/NousResearch/hermes-agent"
    ),
    "features": None,
    "docker_images": {"Hermes Agent (latest)": "ghcr.io/kizoukun/yolks:hermes_agent"},
    "file_denylist": [],
    "startup": startup,
    "config": {
        "files": "{}",
        "startup": json.dumps({"done": [
            "Gateway running with",
            "No messaging platforms enabled",
            "Gateway started with no connected platforms",
            "No adapter could be created",
        ]}, indent=4),
        "logs": "{}",
        "stop": "^C",
    },
    "scripts": {
        "installation": {
            "script": install_script,
            "container": "debian:bookworm-slim",
            "entrypoint": "bash",
        }
    },
    "variables": [
        var("LLM Provider", "HERMES_PROVIDER", "", "nullable|string|max:64",
            "Inference provider: openrouter, anthropic, gemini, zai, kimi-coding, minimax, nous-api. "
            "Leave blank to auto-detect from the API key."),
        var("Model", "HERMES_MODEL", "", "nullable|string|max:128",
            "Default model, e.g. anthropic/claude-sonnet-4.6 on OpenRouter. "
            "Leave blank to keep the model in config.yaml."),
        var("OpenRouter API Key", "OPENROUTER_API_KEY", "", "nullable|string|max:512",
            "API key from https://openrouter.ai/keys"),
        var("OpenRouter Base URL", "OPENROUTER_BASE_URL", "", "nullable|url|max:256",
            "Custom OpenRouter-compatible API URL, e.g. https://proxy.example.com/api/v1. "
            "Leave blank for https://openrouter.ai/api/v1."),
        var("Anthropic API Key", "ANTHROPIC_API_KEY", "", "nullable|string|max:512",
            "API key from https://console.anthropic.com"),
        var("Gemini API Key", "GEMINI_API_KEY", "", "nullable|string|max:512",
            "API key from https://aistudio.google.com/app/apikey"),
        var("Telegram Bot Token", "TELEGRAM_BOT_TOKEN", "", "nullable|string|max:256",
            "Bot token from @BotFather. Leave blank to disable Telegram."),
        var("Telegram Allowed Users", "TELEGRAM_ALLOWED_USERS", "", "nullable|string|max:512",
            "Comma-separated Telegram user IDs allowed to talk to the agent. Nobody is allowed when blank."),
        var("Discord Bot Token", "DISCORD_BOT_TOKEN", "", "nullable|string|max:256",
            "Bot token from the Discord Developer Portal. Leave blank to disable Discord."),
        var("Discord Allowed Users", "DISCORD_ALLOWED_USERS", "", "nullable|string|max:512",
            "Comma-separated Discord user IDs allowed to talk to the agent. Nobody is allowed when blank."),
    ],
}

out = here / "egg-hermes-agent.json"
out.write_text(json.dumps(egg, indent=4) + "\n")
print(out)
