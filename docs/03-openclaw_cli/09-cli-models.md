# openclaw models

Source: [docs.clawd.bot/cli/models](https://docs.clawd.bot/cli/models)

Model discovery, scanning, and configuration (default model, fallbacks, auth profiles).

## Common commands

```bash
openclaw models status
openclaw models list
openclaw models set <model-or-alias>
openclaw models scan
```

- `models status` — resolved default/fallbacks + auth overview. Add `--probe` for live auth probes (can consume tokens).
- `--agent <id>` — inspect that agent’s model/auth state.
- `models set <model-or-alias>` accepts `provider/model` or an alias. Model refs split on the **first** `/` (e.g. `openrouter/moonshotai/kimi-k2`).

## models status options

- `--json`, `--plain`
- `--check` — exit 1=expired/missing, 2=expiring
- `--probe`, `--probe-provider <name>`, `--probe-profile <id>`, `--probe-timeout <ms>`, `--probe-concurrency <n>`, `--probe-max-tokens <n>`
- `--agent <id>`

## Aliases + fallbacks

```bash
openclaw models aliases list
openclaw models fallbacks list
```

## Auth profiles

```bash
openclaw models auth add
openclaw models auth login --provider <id>
openclaw models auth setup-token
openclaw models auth paste-token
```

- `setup-token` — prompt for setup-token (generate with `claude setup-token`).
- `paste-token` — accept token from elsewhere/automation.
