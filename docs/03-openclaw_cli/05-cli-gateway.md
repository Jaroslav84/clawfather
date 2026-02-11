# openclaw gateway

Source: [docs.clawd.bot/cli/gateway](https://docs.clawd.bot/cli/gateway)

Gateway = WebSocket server (channels, nodes, sessions, hooks).

## Run the Gateway

```bash
openclaw gateway
# or
openclaw gateway run
```

- By default the Gateway refuses to start unless `gateway.mode=local` in `~/.openclaw/openclaw.json`. Use `--allow-unconfigured` for ad-hoc runs.
- Non-loopback bind without auth is blocked.

## Options (run)

- `--port <port>` — default from config/env (often 18789)
- `--bind loopback|lan|tailnet|auto|custom`
- `--auth token|password` — auth mode
- `--token <token>`, `--password <password>`
- `--tailscale off|serve|funnel`
- `--allow-unconfigured`, `--dev`, `--reset`, `--force`
- `--verbose`, `--ws-log auto|full|compact`, `--raw-stream`, `--raw-stream-path <path>`

## Query a running Gateway

Shared options: `--url`, `--token`, `--password`, `--timeout`, `--json`, `--no-color`.  
When you set `--url`, you must pass `--token` or `--password` explicitly.

### gateway health

```bash
openclaw gateway health --url ws://127.0.0.1:18789
```

### gateway status

Shows service (launchd/systemd/schtasks) and optional RPC probe.

- `--no-probe` — skip RPC probe
- `--deep` — scan system-level services

### gateway probe

Probes configured remote and localhost. Options: `--ssh user@host`, `--ssh-identity <path>`, `--ssh-auto`, `--json`.

### gateway call <method>

Low-level RPC:

```bash
openclaw gateway call status
openclaw gateway call logs.tail --params '{"sinceMs": 60000}'
```

## Service lifecycle

```bash
openclaw gateway install
openclaw gateway start
openclaw gateway stop
openclaw gateway restart
openclaw gateway uninstall
```

`gateway install` supports `--port`, `--runtime`, `--token`, `--force`, `--json`.

## Discovery (Bonjour)

```bash
openclaw gateway discover
openclaw gateway discover --timeout 4000
openclaw gateway discover --json | jq '.beacons[].wsUrl'
```

- `--timeout <ms>` — default 2000
- `--json` — machine output
