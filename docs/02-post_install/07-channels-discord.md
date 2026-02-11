# Discord Channel

Connect OpenClaw to Discord. Use a bot token, restrict DMs, and grant minimal permissions.

## What it is

OpenClaw connects as a Discord bot. Supports DMs, guilds, channels, and reactions. Configure via `channels.discord` in config.

**Best practice**: Store token in env; grant only required permissions. Use `allowFrom` for DMs.

## When to use it

* Chat with your AI from Discord
* Server-specific automation
* DM-only or guild+channel setups

## Prerequisites

* Discord bot token (from [Discord Developer Portal](https://discord.com/developers/applications))
* Gateway running

## Instructions

### 1. Create bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. New Application → Bot → Reset Token (copy it)
3. Enable only required intents (e.g. Message Content)

### 2. Add config

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "YOUR_BOT_TOKEN",
      "dm": {
        "enabled": true,
        "allowFrom": ["username"]
      },
      "guilds": {
        "123456789012345678": {
          "slug": "my-server",
          "requireMention": true,
          "channels": {
            "general": { "allow": true },
            "help": { "allow": true, "requireMention": true }
          }
        }
      }
    }
  }
}
```

### 3. Invite bot

Use OAuth2 URL with minimal scopes: `bot`, `applications.commands` (if needed).

## Configuration reference

| Path | Purpose |
|------|---------|
| `channels.discord.token` | Bot token |
| `channels.discord.dm.allowFrom` | DM user allowlist |
| `channels.discord.guilds.<id>.requireMention` | Require @mention |
| `channels.discord.guilds.<id>.channels` | Per-channel allow |

## Docker note (Clawfather)

Store token in `.env`. Never commit it.

## Links

* [Discord](https://docs.clawd.bot/channels/discord)
