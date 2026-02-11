# Slack Channel

Connect OpenClaw to Slack. Use bot and app tokens, restrict channels, and store tokens securely.

## What it is

OpenClaw connects as a Slack app. Supports DMs, channels, and slash commands. Configure via `channels.slack` in config.

**Best practice**: Store tokens in env or secrets manager. Grant minimal OAuth scopes.

## When to use it

* Chat with your AI from Slack
* Slash commands (e.g. `/openclaw`)
* Channel-specific automation

## Prerequisites

* Slack app with Bot Token and optionally App-Level Token
* Gateway running

## Instructions

### 1. Create Slack app

1. [api.slack.com/apps](https://api.slack.com/apps) → Create New App
2. OAuth & Permissions → add Bot Token Scopes (e.g. `chat:write`, `channels:history`, `im:history`)
3. Install to Workspace → copy Bot User OAuth Token

### 2. Add config

```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "xoxb-...",
      "appToken": "xapp-...",
      "channels": {
        "#general": { "allow": true, "requireMention": true }
      },
      "dm": {
        "enabled": true,
        "allowFrom": ["U123"]
      }
    }
  }
}
```

### 3. Slash command (optional)

```json
{
  "channels": {
    "slack": {
      "slashCommand": {
        "enabled": true,
        "name": "openclaw",
        "ephemeral": true
      }
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `channels.slack.botToken` | Bot User OAuth Token |
| `channels.slack.appToken` | App-Level Token (Socket Mode) |
| `channels.slack.channels` | Channel allowlist |
| `channels.slack.dm.allowFrom` | DM user allowlist |

## Docker note (Clawfather)

Store tokens in `.env`. Never commit them.

## Links

* [Slack](https://docs.clawd.bot/channels/slack)
* [Slack Security Best Practices](https://api.slack.com/authentication/best-practices)
