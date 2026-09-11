# Hermes Agent

[Hermes Agent](https://github.com/NousResearch/hermes-agent) by Nous Research is a self-improving, open-source AI agent with persistent memory, skills and a cron scheduler. This egg runs it as a messaging gateway for Telegram and Discord.

## Image

`ghcr.io/kizoukun/yolks:hermes_agent` is built from the official `nousresearch/hermes-agent` image (see [`yolks/hermes_agent`](../yolks/hermes_agent)). The tag follows the latest Hermes Agent release, and every release is also published as `hermes_agent_<version>`, e.g. `hermes_agent_v2026.9.7`. Wings pulls the image when the server starts, so a restart picks up a new release.

The agent code lives in the image. Agent data (config, memory, skills, sessions, logs) is stored in `.hermes` on the server. Files the agent creates with its tools land in the server root, separate from its own data.

## Setup

1. Set an LLM API key (OpenRouter, Anthropic or Gemini). Leave the provider blank to auto-detect it from the key, and optionally set a model.
2. For an OpenRouter-compatible proxy, set **OpenRouter Base URL**.
3. Set a Telegram and/or Discord bot token.
4. Set the allowed user IDs for that platform. When blank, Hermes denies every sender.
5. Start the server.

Other providers, platforms and tool keys can be added to `.hermes/.env`, and settings to `.hermes/config.yaml`, through the file manager. Values in `.hermes/.env` override the egg variables. The provider is written to `.hermes/config.yaml` on every start (`auto` when blank), so set it with the egg variable rather than in the file.

## Server ports

No ports are required. Telegram uses long polling and Discord uses an outbound websocket.

## Notes

- Stopping the server sends Ctrl+C, which shuts the gateway down gracefully.
- An invalid bot token stops the server with exit code 78 and a `failed to connect` message.
- With no bot token the gateway keeps running for scheduled cron jobs only.
