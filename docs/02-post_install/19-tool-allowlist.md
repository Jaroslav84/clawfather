# Tool Allowlist

Control which tools the agent can use: exec, read, write, edit, apply_patch, browser, canvas. Restrict risky tools; gate elevated tools per channel.

## What it is

`tools.allow` and `tools.deny` define which tools are available. `elevated.allowFrom` restricts high-privilege tools (e.g. host exec) to specific channels/senders.

**Best practice**: Deny browser/canvas when not needed; restrict elevated to trusted channels.

## When to use it

* Reduce blast radius
* Work bot: deny elevated
* Dev bot: allow exec, read, write

## Prerequisites

* Access to `openclaw.json`

## Instructions

### 1. Allow/deny tools

```json
{
  "tools": {
    "allow": ["exec", "process", "read", "write", "edit", "apply_patch"],
    "deny": ["browser", "canvas"]
  }
}
```

### 2. Elevated (host exec) per channel

```json
{
  "tools": {
    "elevated": {
      "enabled": true,
      "allowFrom": {
        "whatsapp": ["+15551234567"],
        "telegram": ["123456789"],
        "webchat": ["session:demo"]
      }
    }
  }
}
```

### 3. Disable elevated entirely

```json
{
  "tools": {
    "elevated": {
      "enabled": false
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `tools.allow` | Allowed tools |
| `tools.deny` | Denied tools |
| `tools.elevated.enabled` | Enable elevated tools |
| `tools.elevated.allowFrom` | Per-channel allowlist |

## Docker note (Clawfather)

Clawfather install can set these via the Security checklist. Edit config in mounted OpenClaw dir.

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
* [Elevated Mode](https://docs.clawd.bot/tools/elevated)
