# openclaw config

Source: [docs.clawd.bot/cli/config](https://docs.clawd.bot/cli/config)

Config helpers: get/set/unset by path. Running `openclaw config` with no subcommand opens the configure wizard.

## Subcommands

- `config get <path>` — print value (dot or bracket path)
- `config set <path> <value>` — set (JSON5 or raw string; use `--json` to require JSON5)
- `config unset <path>` — remove

## Paths

Dot or bracket notation:

```bash
openclaw config get agents.defaults.workspace
openclaw config get agents.list[0].id
```

Use list index to target an agent:

```bash
openclaw config get agents.list
openclaw config set agents.list[1].tools.exec.node "node-id-or-name"
```

## Values

Values are parsed as JSON5 when possible; otherwise treated as strings. Use `--json` to require JSON5.

```bash
openclaw config set agents.defaults.heartbeat.every "0m"
openclaw config set gateway.port 19001 --json
openclaw config set channels.whatsapp.groups '["*"]' --json
```

**Restart the gateway after edits.**

## Examples

```bash
openclaw config get browser.executablePath
openclaw config set browser.executablePath "/usr/bin/google-chrome"
openclaw config set agents.defaults.heartbeat.every "2h"
openclaw config set agents.list[0].tools.exec.node "node-id-or-name"
openclaw config unset tools.web.search.apiKey
```
