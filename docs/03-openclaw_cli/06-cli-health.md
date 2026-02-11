# openclaw health

Source: [docs.clawd.bot/cli/health](https://docs.clawd.bot/cli/health)

Fetch health from the running Gateway.

```bash
openclaw health
openclaw health --json
openclaw health --verbose
```

- `--verbose` — run live probes, print per-account timings when multiple accounts exist.
- Output includes per-agent session stores when multiple agents are configured.
