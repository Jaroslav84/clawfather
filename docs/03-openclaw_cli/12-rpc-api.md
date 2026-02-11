# RPC Adapters

Source: [docs.clawd.bot/reference/rpc](https://docs.clawd.bot/reference/rpc)

OpenClaw integrates external CLIs via JSON-RPC. Two patterns:

## Pattern A: HTTP daemon (e.g. signal-cli)

- Daemon with JSON-RPC over HTTP.
- Event stream: SSE (e.g. `/api/v1/events`).
- Health probe (e.g. `/api/v1/check`).
- OpenClaw can own lifecycle when `channels.signal.autoStart=true`.

## Pattern B: stdio child process (e.g. legacy imsg)

- OpenClaw spawns `imsg rpc` as child.
- JSON-RPC line-delimited over stdin/stdout (one JSON object per line).
- No TCP port, no daemon.

Core methods (imsg): `watch.subscribe`, `watch.unsubscribe`, `send`, `chats.list`.

## Adapter guidelines

- Gateway owns process (start/stop tied to provider lifecycle).
- Keep RPC clients resilient: timeouts, restart on exit.
- Prefer stable IDs (e.g. `chat_id`) over display strings.

## Gateway RPC (from CLI)

Use `openclaw gateway call <method>` for low-level RPC, e.g.:

- `config.get` — get config + hash
- `config.apply` — full config + restart (params: `raw`, `baseHash`, …)
- `config.patch` — partial merge + restart (params: `raw`, `baseHash`, …)
- `logs.tail` — params e.g. `{"sinceMs": 60000}`
- `status` — gateway status

Pass `--params '{"key": "value"}'` for method arguments. When using `--url`, also pass `--token` or `--password`.
