# openclaw security

Source: [docs.clawd.bot/cli/security](https://docs.clawd.bot/cli/security)

Security tools: audit and optional fixes.

## Audit

```bash
openclaw security audit
openclaw security audit --deep
openclaw security audit --fix
```

- **audit** — config + local state checks.
- **--deep** — best-effort live Gateway probe.
- **--fix** — apply safe guardrails (tighten groupPolicy, redactSensitive, chmod state/config).

The audit warns when multiple DM senders share the main session and recommends **secure DM mode**: `session.dmScope="per-channel-peer"` (or `per-account-channel-peer` for multi-account). It also warns when small models (<=300B) are used without sandboxing and with web/browser tools enabled.

Related: [Security](https://docs.clawd.bot/gateway/security)
