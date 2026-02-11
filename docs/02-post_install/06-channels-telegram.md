# Telegram Channel

Connect OpenClaw to Telegram. Use a bot token, restrict DMs with allowlist or pairing, and secure tokens.

## What it is

OpenClaw connects as a Telegram bot. Supports DMs, groups, threads, reactions, and media. Configure via `channels.telegram` in config.

**Best practice**: Store bot token in env (`TELEGRAM_BOT_TOKEN`) or secrets—never in public code. Use allowlist for DMs.

## When to use it

* Chat with your AI from Telegram
* Receive cron/heartbeat output on Telegram
* Group chats with @mention activation

## Prerequisites

* Telegram bot token (from [@BotFather](https://t.me/BotFather))
* Gateway running

## Instructions

### 1. Create bot and get token

1. Message [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow prompts
3. Copy the token

### 2. Add config

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "YOUR_BOT_TOKEN",
      "allowFrom": ["123456789"],
      "groups": {
        "*": { "requireMention": true }
      }
    }
  }
}
```

Or use env: `TELEGRAM_BOT_TOKEN`.

### 3. Restrict DMs

* `allowFrom`: Telegram user IDs (numeric)
* `dmPolicy`: `pairing` \| `allowlist` \| `open` \| `disabled`

### 4. Restart gateway

```bash
docker compose restart openclaw-gateway
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `channels.telegram.botToken` | Bot token (or `TELEGRAM_BOT_TOKEN`) |
| `channels.telegram.allowFrom` | User ID allowlist |
| `channels.telegram.dmPolicy` | DM access control |
| `channels.telegram.groups["*"].requireMention` | Require @mention in groups |

## Docker note (Clawfather)

Store token in `.env` and reference via `TELEGRAM_BOT_TOKEN`. Never commit `.env`.

## Links

* [Telegram](https://docs.clawd.bot/channels/telegram)

## Troubleshooting

**Webhook conflicts**: If using long-polling elsewhere, ensure only one client uses the token.
