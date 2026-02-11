# Queue & Routing

Control how messages are queued and routed. `routing.queue` and `routing.groupChat` tune batching and mention behavior.

## What it is

`routing.queue` controls batching (collect vs immediate), debounce, and cap. `routing.groupChat` sets mention patterns and history limits.

**Best practice**: Use `collect` for high-volume channels; set `mentionPatterns` to avoid accidental triggers.

## When to use it

* High message volume
* Group chat behavior
* Reduce duplicate processing

## Prerequisites

* Access to `openclaw.json`

## Instructions

```json
{
  "routing": {
    "groupChat": {
      "mentionPatterns": ["@openclaw", "openclaw"],
      "historyLimit": 50
    },
    "queue": {
      "mode": "collect",
      "debounceMs": 1000,
      "cap": 20,
      "drop": "summarize",
      "byChannel": {
        "whatsapp": "collect",
        "telegram": "collect"
      }
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `routing.queue.mode` | `collect` \| `immediate` |
| `routing.queue.debounceMs` | Debounce interval |
| `routing.queue.cap` | Max batched messages |
| `routing.groupChat.mentionPatterns` | Patterns to trigger |
| `routing.groupChat.historyLimit` | Context limit |

## Docker note (Clawfather)

Config in mounted OpenClaw dir.

## Links

* [Configuration Examples](https://docs.clawd.bot/gateway/configuration-examples)
