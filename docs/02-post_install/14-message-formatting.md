# Message Formatting

Control prefixes, reactions, and typing behavior for inbound and outbound messages.

## What it is

`messages` and per-channel config control: message prefix (inbound), response prefix (outbound), acknowledgment reaction, and typing intervals.

**Best practice**: Use `ackReaction` for quick feedback; keep prefixes short.

## When to use it

* Customize how messages appear ("[Clawd]", ">")
* Auto-react on receipt (e.g. 👀)
* Per-channel nuance (e.g. different prefix for WhatsApp vs Telegram)

## Prerequisites

* Access to `openclaw.json`

## Instructions

### 1. Global message formatting

```json
{
  "messages": {
    "messagePrefix": "[openclaw]",
    "responsePrefix": ">",
    "ackReaction": "👀",
    "ackReactionScope": "group-mentions"
  }
}
```

### 2. Per-channel (WhatsApp)

```json
{
  "channels": {
    "whatsapp": {
      "ackReaction": {
        "emoji": "👀",
        "direct": true,
        "group": "mentions"
      }
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `messages.messagePrefix` | Inbound prefix |
| `messages.responsePrefix` | Outbound prefix |
| `messages.ackReaction` | Default ack emoji |
| `messages.ackReactionScope` | `group-mentions` etc. |
| `channels.<ch>.ackReaction` | Per-channel override |

## Docker note (Clawfather)

Config in mounted OpenClaw dir.

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
* [WhatsApp ackReaction](https://docs.clawd.bot/channels/whatsapp#acknowledgment-reactions)
