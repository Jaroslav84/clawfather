# Session Reset Rules

Control when conversation sessions expire or reset. Tune idle timeouts and reset triggers to match your usage (support vs. long-term engagement).

## What it is

OpenClaw supports `session.reset` with modes: `daily` (reset at a fixed hour), `idle` (reset after N minutes of inactivity), or manual via triggers like `/new` and `/reset`. Per-channel overrides available.

**Best practice**: Match timeout to task complexity—5–15 min for quick support, 30–60 min for complex tasks, 24h for long engagement.

## When to use it

* Limit context bloat in long-running chats
* Enforce fresh context at day boundaries
* Different cadence per channel (e.g. Discord vs WhatsApp)

## Prerequisites

* Access to `openclaw.json` config

## Instructions

### 1. Configure session reset

Edit `~/.openclaw/openclaw.json` (or use `config.patch`):

```json
{
  "session": {
    "reset": {
      "mode": "daily",
      "atHour": 4,
      "idleMinutes": 60
    },
    "resetTriggers": ["/new", "/reset"]
  }
}
```

### 2. Modes

| Mode | Description |
|------|-------------|
| `daily` | Reset at `atHour` (0–23) each day |
| `idle` | Reset after `idleMinutes` of no activity |
| Manual | User sends `/new` or `/reset` |

### 3. Per-channel override

```json
{
  "session": {
    "resetByChannel": {
      "discord": {
        "mode": "idle",
        "idleMinutes": 10080
      }
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `session.reset.mode` | `daily` or `idle` |
| `session.reset.atHour` | Hour (0–23) for daily reset |
| `session.reset.idleMinutes` | Minutes before idle reset |
| `session.resetTriggers` | Slash commands that trigger reset |
| `session.resetByChannel.<channel>` | Per-channel overrides |

## Docker note (Clawfather)

Config is in the mounted OpenClaw dir. Restart gateway after changes: `docker compose restart openclaw-gateway`.

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
* [Configuration Examples](https://docs.clawd.bot/gateway/configuration-examples)
