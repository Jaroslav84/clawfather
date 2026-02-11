# Secure DM Mode

Isolate DMs so each sender has their own session. Prevents context leakage when multiple people can message your bot.

## What it is

By default, `session.dmScope: "main"` shares one session across all DMs. Secure DM mode uses `session.dmScope: "per-channel-peer"` so each sender gets an isolated session.

**Best practice**: Enable when more than one person can DM your bot. Recommended for multi-user or sensitive setups.

## When to use it

* Multiple people in `allowFrom`
* Pairing mode with multiple approved senders
* `dmPolicy: "open"` (anyone can DM)
* Sensitivity to context leakage

## Prerequisites

* Access to `openclaw.json` config

## Instructions

### 1. Enable secure DM mode

Edit `~/.openclaw/openclaw.json`:

```json
{
  "session": {
    "dmScope": "per-channel-peer"
  },
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+15555550123", "+15555550124"]
    },
    "discord": {
      "dm": {
        "enabled": true,
        "allowFrom": ["alice", "bob"]
      }
    }
  }
}
```

### 2. Restart gateway

```bash
docker compose restart openclaw-gateway
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `session.dmScope` | `main` (shared) or `per-channel-peer` (isolated) |

**`main`**: All DMs share one session. Simple, but risky with multiple users.

**`per-channel-peer`**: Each channel + sender gets a separate session. No cross-user context.

## Docker note (Clawfather)

Config in mounted OpenClaw dir. Restart `openclaw-gateway` after changes.

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
* [Configuration Examples](https://docs.clawd.bot/gateway/configuration-examples) (Secure DM mode)
