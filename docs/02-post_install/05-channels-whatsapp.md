# WhatsApp Channel

Connect OpenClaw to WhatsApp via Baileys (WhatsApp Web). Use a dedicated number when possible; allowlist trusted contacts.

## What it is

OpenClaw connects as a WhatsApp Web client. The Gateway owns the session. DMs and groups supported with `dmPolicy` (pairing/allowlist/open) and `groupPolicy`.

**Best practice**: Use `allowlist` and `allowFrom` with E.164 numbers. Avoid VoIP numbers—WhatsApp blocks them.

## When to use it

* Chat with your AI assistant from your phone
* Receive heartbeat/cron output on WhatsApp
* Multi-user setups with explicit allowlist

## Prerequisites

* Real mobile number (eSIM or prepaid SIM; avoid TextNow, Google Voice)
* Gateway running

## Instructions

### 1. Add config

Edit `~/.openclaw/openclaw.json`:

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+15551234567"]
    }
  }
}
```

### 2. Login (QR scan)

```bash
docker compose exec -it openclaw-gateway openclaw channels login
```

Scan the QR with WhatsApp (Settings → Linked Devices). Credentials stored in `~/.openclaw/credentials/whatsapp/`.

### 3. Groups (optional)

```json
{
  "channels": {
    "whatsapp": {
      "groupPolicy": "allowlist",
      "groups": {
        "*": { "requireMention": true }
      },
      "groupAllowFrom": ["+15551234567"]
    }
  }
}
```

### 4. Pairing mode (optional)

Use `dmPolicy: "pairing"` for unknown senders. Approve with:

```bash
docker compose exec openclaw-gateway openclaw pairing list whatsapp
docker compose exec openclaw-gateway openclaw pairing approve whatsapp <code>
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `channels.whatsapp.dmPolicy` | `pairing` \| `allowlist` \| `open` \| `disabled` |
| `channels.whatsapp.allowFrom` | E.164 allowlist (e.g. `["+15551234567"]`) |
| `channels.whatsapp.selfChatMode` | true if using your personal number |
| `channels.whatsapp.groupPolicy` | `allowlist` \| `open` \| `disabled` |
| `channels.whatsapp.groups["*"].requireMention` | Require @mention in groups |

## Docker note (Clawfather)

Run `openclaw channels login` inside `openclaw-gateway`. Credentials persist in the mounted OpenClaw config dir.

## Links

* [WhatsApp](https://docs.clawd.bot/channels/whatsapp)
* [Pairing](https://docs.clawd.bot/start/pairing)

## Troubleshooting

**Not linked**: Run `openclaw channels login` and scan QR.

**Linked but disconnected**: Restart gateway; relink if needed.
