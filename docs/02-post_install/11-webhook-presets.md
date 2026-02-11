# Webhook Presets

External HTTP endpoints that trigger OpenClaw (wake heartbeat or run an isolated agent turn). Use for Gmail, GitHub, or custom integrations.

## What it is

Gateway exposes `POST /hooks/wake` and `POST /hooks/agent`. Mappings let you add custom paths (e.g. `/hooks/gmail`). All requests require a shared token.

**Best practice**: Use Authorization header; keep endpoints behind loopback or trusted proxy; use a dedicated token (not gateway auth).

## When to use it

* Gmail Pub/Sub notifications
* GitHub webhooks
* Custom automation triggers

## Prerequisites

* `hooks.enabled: true` and `hooks.token` in config
* Gateway reachable (loopback, or via Tailscale/reverse proxy)

## Instructions

### 1. Enable hooks

```json
{
  "hooks": {
    "enabled": true,
    "token": "shared-secret",
    "path": "/hooks"
  }
}
```

### 2. Wake (main session)

```bash
curl -X POST http://127.0.0.1:18789/hooks/wake \
  -H "Authorization: Bearer shared-secret" \
  -H "Content-Type: application/json" \
  -d '{"text":"New email received","mode":"now"}'
```

### 3. Agent (isolated turn)

```bash
curl -X POST http://127.0.0.1:18789/hooks/agent \
  -H "x-openclaw-token: shared-secret" \
  -H "Content-Type: application/json" \
  -d '{"message":"Summarize inbox","name":"Email","wakeMode":"now","deliver":true,"channel":"last"}'
```

### 4. Gmail preset

```json
{
  "hooks": {
    "presets": ["gmail"],
    "gmail": {
      "account": "user@gmail.com",
      "hookUrl": "http://127.0.0.1:18789/hooks/gmail"
    }
  }
}
```

Run `openclaw webhooks gmail setup` for full Gmail Pub/Sub flow.

## Auth

* `Authorization: Bearer <token>` (recommended)
* `x-openclaw-token: <token>`

## Configuration reference

| Path | Purpose |
|------|---------|
| `hooks.enabled` | Enable webhook endpoints |
| `hooks.token` | Required shared secret |
| `hooks.path` | Base path (default: `/hooks`) |
| `hooks.presets` | Built-in mappings (e.g. `gmail`) |
| `hooks.mappings` | Custom path → action mappings |

## Docker note (Clawfather)

Port 18789 maps to host. Use `http://127.0.0.1:18789` or `http://host.docker.internal:18789` from inside Docker.

## Links

* [Webhooks](https://docs.clawd.bot/automation/webhook)
* [Gmail PubSub](https://docs.clawd.bot/automation/gmail-pubsub)
