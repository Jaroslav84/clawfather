# Health Check & Doctor

Verify gateway health and config with `openclaw doctor` and `openclaw security audit`.

## What it is

`openclaw doctor` checks config, migrations, and runtime. `openclaw security audit` audits security posture. Use after config changes or for troubleshooting.

**Best practice**: Run `doctor` and `audit --deep` periodically; apply `--fix` when safe.

## When to use it

* After config edits
* Before going to production
* Troubleshooting startup failures

## Instructions

### 1. Doctor

```bash
docker compose exec openclaw-gateway openclaw doctor
```

Fix issues:
```bash
docker compose exec openclaw-gateway openclaw doctor --fix
```

### 2. Security audit

```bash
docker compose exec openclaw-gateway openclaw security audit
docker compose exec openclaw-gateway openclaw security audit --deep
```

Apply fixes:
```bash
docker compose exec openclaw-gateway openclaw security audit --fix
```

### 3. Health (gateway)

```bash
docker compose exec openclaw-gateway openclaw gateway health
```

## Docker note (Clawfather)

All commands via `openclaw-gateway`. Gateway must be running for health checks.

## Links

* [06-cli-health](../03-openclaw_cli/06-cli-health.md) · [07-cli-security](../03-openclaw_cli/07-cli-security.md)
* [Doctor](https://docs.clawd.bot/gateway/doctor)
* [Health Checks](https://docs.clawd.bot/gateway/health)
* [Security Audit](https://docs.clawd.bot/cli/security)
