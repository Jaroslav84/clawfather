# Configuration

Source: [docs.clawd.bot/gateway/configuration](https://docs.clawd.bot/gateway/configuration)

OpenClaw reads optional **JSON5** config from `~/.openclaw/openclaw.json` (comments + trailing commas allowed). If missing, safe defaults (embedded agent, per-sender sessions, workspace `~/.openclaw/workspace`).

## Strict validation

Unknown keys or invalid values cause the Gateway to **refuse to start**. Run `openclaw doctor` to see issues; `openclaw doctor --fix` (or `--yes`) to apply migrations.

## Apply + restart (RPC)

- **config.apply** — validate + write **entire** config + restart. Params: `raw` (string), `baseHash` (from config.get, required when config exists), `sessionKey`, `note`, `restartDelayMs`.
- **config.patch** — merge partial update (JSON merge patch; `null` deletes key). Params: `raw`, `baseHash` (required), `sessionKey`, `note`, `restartDelayMs`.

Example (get hash then patch):

```bash
openclaw gateway call config.get --params '{}'
# use payload.hash as baseHash
openclaw gateway call config.patch --params '{"raw": "{ \"channels\": { \"telegram\": { \"groups\": { \"*\": { \"requireMention\": false } } } } }", "baseHash": "<hash>", "restartDelayMs": 1000}'
```

## Minimal config

```json
{
  "agents": { "defaults": { "workspace": "~/.openclaw/workspace" } },
  "channels": { "whatsapp": { "allowFrom": ["+15555550123"] } }
}
```

## Key config paths

| Path | Purpose |
|------|--------|
| `gateway.mode` | `local` required for Gateway to start (unless `--allow-unconfigured`) |
| `gateway.port` | WebSocket port (default 18789) |
| `gateway.bind` | `loopback|lan|tailnet|auto|custom` |
| `gateway.auth.mode` | `token` or `password` |
| `gateway.auth.token` | Bearer token |
| `gateway.controlUi.allowInsecureAuth` | `true` = token-only auth, skip device pairing (downgrade) |
| `agents.defaults.workspace` | Agent workspace directory |
| `agents.defaults.model.primary` | Default model (`provider/model`, e.g. `anthropic/claude-opus-4-5`) |
| `agents.defaults.model.fallbacks` | Array of fallback models |
| `agents.list[].id` | Agent id (e.g. `main`) |
| `agents.list[].workspace` | Per-agent workspace |
| `agents.list[].model` | Per-agent model (string or `{ primary, fallbacks }`) |
| `channels.whatsapp.allowFrom` | E.164 allowlist (DMs) |
| `channels.whatsapp.dmPolicy` | `pairing|allowlist|open|disabled` |
| `channels.whatsapp.groups["*"].requireMention` | Require mention in groups |
| `channels.telegram.botToken` | Bot token (or env `TELEGRAM_BOT_TOKEN`) |
| `channels.discord.token` | Bot token |
| `session.dmScope` | `main` (all DMs one session) or `per-channel-peer` (isolated) |
| `models.providers.<name>` | Custom provider (baseUrl, apiKey, models[]) |
| `models.mode` | `merge` (default) or `replace` for providers |
| `logging.file` | Log file path |
| `logging.redactSensitive` | `off` or `tools` (default) |
| `discovery.mdns.mode` | `minimal` (default), `full`, or `off` |

## Env and .env

- Loaded: process env, `.env` in cwd, `~/.openclaw/.env` (neither overrides existing).
- In config: `env.vars.<KEY>` or `env.<KEY>` for inline defaults (non-overriding).
- Substitution in config: `${VAR_NAME}` in any string value; only `[A-Z_][A-Z0-9_]*`. Escape as `$${VAR}`.

## Config includes

```json
{
  "agents": { "$include": "./agents.json5" },
  "broadcast": { "$include": ["./clients/a.json5", "./clients/b.json5"] }
}
```

- Single file: replaces the key’s value.
- Array: deep-merge in order. Relative paths resolved from the including file.

## Bindings (multi-agent)

`bindings[]`: route inbound to `agentId`. Match: `channel` (required), `accountId`, `peer`, `guildId`, `teamId`. First matching entry wins. Default agent: first with `default: true`, else first in list, else `"main"`.
