# Matrix Channel

Connect OpenClaw to Matrix (decentralized, E2EE-capable). Requires the Matrix plugin; supports DMs, rooms, threads, and encryption.

## What it is

OpenClaw connects as a Matrix user on any homeserver. Supports DMs, rooms, threads, media, reactions, and E2EE. Implemented as a plugin (not bundled).

**Best practice**: Use E2EE when possible; verify the bot device from another client (Element). Backup credentials and crypto storage.

## When to use it

* Privacy-focused or self-hosted setups
* Beeper or Element users
* E2EE groups and DMs

## Prerequisites

* Matrix account (homeserver)
* Access token or userId + password
* Matrix plugin installed

## Instructions

### 1. Install plugin

```bash
docker compose exec openclaw-gateway openclaw plugins install @openclaw/matrix
```

### 2. Get access token

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"your-username"},"password":"your-password"}' \
  https://matrix.example.org/_matrix/client/v3/login
```

Use `access_token` from the response.

### 3. Add config

```json
{
  "channels": {
    "matrix": {
      "enabled": true,
      "homeserver": "https://matrix.example.org",
      "accessToken": "syt_...",
      "encryption": true,
      "dm": { "policy": "pairing" }
    }
  }
}
```

### 4. E2EE device verification

On first connection with `encryption: true`, verify the bot device in Element (or another client) to enable key sharing.

### 5. Restart gateway

```bash
docker compose restart openclaw-gateway
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `channels.matrix.homeserver` | Homeserver URL |
| `channels.matrix.accessToken` | Access token |
| `channels.matrix.encryption` | Enable E2EE |
| `channels.matrix.dm.policy` | `pairing` \| `allowlist` \| `open` |
| `channels.matrix.groups` | Room allowlist |

## Docker note (Clawfather)

Install plugin inside `openclaw-gateway`. Credentials and crypto state in `~/.openclaw/credentials/matrix/` and `~/.openclaw/matrix/`.

## Links

* [Matrix](https://docs.clawd.bot/channels/matrix)
* [Matrix E2EE](https://matrix.org/docs/matrix-concepts/end-to-end-encryption)
