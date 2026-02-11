# CLI Reference

Source: [docs.clawd.bot/cli](https://docs.clawd.bot/cli)

## Global flags

- `--dev` — isolate state under `~/.openclaw-dev`, shift default ports
- `--profile <name>` — isolate state under `~/.openclaw-<name>`
- `--no-color` — disable ANSI colors
- `--update` — shorthand for `openclaw update` (source installs only)
- `-V`, `--version`, `-v` — print version and exit

## Command tree (summary)

```
openclaw [--dev] [--profile <name>] <command>
  setup, onboard, configure
  config get|set|unset
  doctor, security audit|audit --deep|audit --fix
  reset, uninstall, update
  channels list|status|logs|add|remove|login|logout
  skills list|info|check
  plugins list|info|install|enable|disable|doctor
  memory status|index|search
  message send|poll|react|reactions|read|edit|delete|pin|unpin|...
  agent (--agent <id> --message <text> ...)
  agents list|add|delete
  acp, status, health, sessions
  gateway (run)|call|health|status|probe|discover|install|uninstall|start|stop|restart|run
  logs
  system event|heartbeat last|enable|disable|presence
  models list|status|set|set-image|aliases|fallbacks|scan|auth add|setup-token|paste-token
  sandbox list|recreate|explain
  cron status|list|add|edit|rm|enable|disable|runs|run
  nodes status|list|pending|approve|reject|invoke|run|notify|camera|canvas|...
  devices list|approve|reject|rotate|revoke
  approvals get|set|allowlist add|remove
  browser status|start|stop|tabs|open|screenshot|snapshot|navigate|...
  docs [query...]
  dns setup
  tui
```

## Security

- `openclaw security audit` — audit config + local state
- `openclaw security audit --deep` — best-effort live Gateway probe
- `openclaw security audit --fix` — tighten safe defaults, chmod state/config

## Config (non-interactive)

- `config get <path>` — print value (dot or bracket path)
- `config set <path> <value>` — set (JSON5 or raw string)
- `config unset <path>` — remove

## Gateway RPC (common)

- `gateway call config.get` — get config + hash
- `gateway call config.apply` — validate + write full config + restart (needs `baseHash`)
- `gateway call config.patch` — merge partial update + restart (needs `baseHash`)
- `gateway call update.run` — run update + restart

When calling config.set / config.apply / config.patch, pass `baseHash` from `config.get` if a config already exists.

## Useful Commands with Clawfather

These commands are printed when the install wizard completes. Run from the project directory.

### Docker Management

| Purpose        | Command |
|----------------|---------|
| Gateway logs   | `docker compose logs -f openclaw-gateway` |
| Gateway log file | `./.openclaw/logs/gateway.log` |
| Log file       | `./.openclaw/logs/openclaw.log` |
| CLI (exec)     | `docker compose exec openclaw-gateway node dist/index.js <command>` |
| Stop           | `docker compose stop` |
| Update         | `docker compose pull && docker compose up -d` |
| Shell          | `docker compose exec -it openclaw-gateway sh` |
| Stats          | `docker stats $(docker compose ps -q openclaw-gateway)` |
| Container OS   | `docker compose exec openclaw-gateway cat /etc/os-release` |

### Gateway (exec — no new containers)

| Purpose     | Command |
|-------------|---------|
| TUI (chat)  | `docker compose exec -it openclaw-gateway node dist/index.js tui` |
| Help       | `docker compose exec openclaw-gateway node dist/index.js --help` |
| Config get | `docker compose exec openclaw-gateway node dist/index.js config get <key>` |
| Config set | `docker compose exec openclaw-gateway node dist/index.js config set <key> <value>` |
| Gateway stop | `docker compose exec openclaw-gateway node dist/index.js gateway stop` |
| Audit Deep | `docker compose exec openclaw-gateway node dist/index.js security audit --deep` |
| Audit Fix  | `docker compose exec openclaw-gateway node dist/index.js security audit --fix` |
| Sync Skills | `docker compose exec openclaw-gateway node dist/index.js skill sync` |
| Scan Models | `docker compose exec openclaw-gateway node dist/index.js model scan` |
| Environment | `docker compose exec openclaw-gateway node dist/index.js env` |
| Status     | `docker compose exec openclaw-gateway node dist/index.js status --all` |
| Version    | `docker compose exec openclaw-gateway node dist/index.js --version` |
