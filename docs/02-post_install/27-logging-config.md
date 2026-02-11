# Logging Configuration

Configure log level, file path, console output, and redaction of sensitive data.

## What it is

`logging` controls where and how the gateway logs. `redactSensitive` limits exposure of tokens and secrets in logs.

**Best practice**: Use `redactSensitive: "tools"`; avoid logging full payloads in production.

## When to use it

* Debug without leaking secrets
* Redirect logs to file
* Tune verbosity

## Prerequisites

* Access to `openclaw.json`

## Instructions

```json
{
  "logging": {
    "level": "info",
    "file": "/home/node/.openclaw/logs/openclaw.log",
    "consoleLevel": "info",
    "consoleStyle": "pretty",
    "redactSensitive": "tools"
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `logging.level` | Log level |
| `logging.file` | File path |
| `logging.consoleLevel` | Console level |
| `logging.redactSensitive` | `off` \| `tools` |

## Docker note (Clawfather)

Logs go to `./.openclaw/logs/openclaw.log` and `./.openclaw/logs/gateway.log`. `redactSensitive: "tools"` is default.

## Links

* [Logging](https://docs.clawd.bot/gateway/logging)
* [Configuration](https://docs.clawd.bot/gateway/configuration)
