# Security

Source: [docs.clawd.bot/gateway/security](https://docs.clawd.bot/gateway/security)

## Quick check

```bash
openclaw security audit
openclaw security audit --deep
openclaw security audit --fix
```

`--fix` applies: tighten `groupPolicy` to allowlist where appropriate, set `logging.redactSensitive` to `tools`, chmod `~/.openclaw` (700), config (600), credentials/auth files.

## What the audit checks

- **Inbound access** — DM/group policies, allowlists
- **Tool blast radius** — elevated tools + open rooms
- **Network exposure** — bind, auth, Tailscale, weak tokens
- **Browser control** — remote nodes, relay ports
- **Disk** — permissions, symlinks, config includes
- **Plugins** — allowlist
- **Model** — legacy/small model warnings

## Credential storage (audit/backup)

- WhatsApp: `~/.openclaw/credentials/whatsapp/<accountId>/creds.json`
- Telegram/Discord/Slack: config or env
- Pairing allowlists: `~/.openclaw/credentials/<channel>-allowFrom.json`
- Model auth: `~/.openclaw/agents/<agentId>/agent/auth-profiles.json`
- Sessions: `~/.openclaw/agents/<agentId>/sessions/*.jsonl`

## Security checklist (priority order)

1. Lock down “open” + tools (pairing/allowlists, then tool policy/sandbox).
2. Fix public network exposure (LAN bind, Funnel, missing auth).
3. Browser control: tailnet-only, pair nodes deliberately.
4. Permissions: state/config/credentials not group/world readable.
5. Plugins: only load trusted; prefer explicit allowlist.
6. Model: prefer modern, instruction-hardened for tool-enabled bots.

## Control UI

- `gateway.controlUi.allowInsecureAuth: true` — token-only auth, no device pairing (downgrade). Prefer HTTPS or 127.0.0.1.
- `gateway.controlUi.dangerouslyDisableDeviceAuth` — disables device identity checks (severe downgrade).

## Reverse proxy

Set `gateway.trustedProxies` (e.g. `["127.0.0.1"]`) so client IP is taken from `X-Forwarded-For`. Proxy must **overwrite** (not append) that header.

## DM policies

- `pairing` (default) — unknown senders get pairing code; approve via `openclaw pairing list <channel>`, `openclaw pairing approve <channel> <code>`.
- `allowlist` — only allowlisted.
- `open` — allow all (requires allowlist to include `"*"`).
- `disabled` — ignore DMs.

## Secure DM mode (multi-user)

```json
{ "session": { "dmScope": "per-channel-peer" } }
```

Per channel+sender isolated context. Multi-account: `per-account-channel-peer`.

## Network

- `gateway.bind: "loopback"` — only local.
- Non-loopback: use token/password and firewall. Prefer Tailscale Serve over LAN bind.
- Never expose unauthenticated on `0.0.0.0`.

## Gateway auth

```json
{
  "gateway": {
    "auth": { "mode": "token", "token": "your-long-random-token" }
  }
}
```

`gateway.remote.token` is for **remote CLI** only; it does not protect local WS.

## mDNS/Bonjour

- `discovery.mdns.mode: "minimal"` (default) — omit cliPath, sshPort from TXT.
- `discovery.mdns.mode: "off"` — disable. Or `OPENCLAW_DISABLE_BONJOUR=1`.

## Secure baseline (copy/paste)

```json
{
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789,
    "auth": { "mode": "token", "token": "your-long-random-token" }
  },
  "channels": {
    "whatsapp": {
      "dmPolicy": "pairing",
      "groups": { "*": { "requireMention": true } }
    }
  }
}
```

## Incident response

1. **Contain** — stop gateway, set bind to loopback, tighten DM/group policies.
2. **Rotate** — gateway auth, remote client secrets, provider credentials.
3. **Audit** — logs, transcripts, config changes; `openclaw security audit --deep`.

## Sandboxing

- **Tool sandbox** — `agents.defaults.sandbox` (Docker-isolated tools). Scope: `agent` or `session`; avoid `shared` for isolation.
- **Full Gateway in Docker** — see Docker install docs.
- `tools.elevated` — host exec; keep `tools.elevated.allowFrom` tight.
