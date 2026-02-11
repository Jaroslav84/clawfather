# Scheduled Backup

Automate backups of config, skills, and workspace. Use cron or external scheduler.

## What it is

OpenClaw config and skills can be backed up on a schedule. Use a cron job (host or OpenClaw cron) to copy `openclaw.json`, `config.yaml`, and skills dir.

**Best practice**: Backup to a separate location; exclude credentials; test restore.

## When to use it

* Before major config changes
* Daily/weekly snapshots
* Disaster recovery

## Prerequisites

* Write access to backup destination
* Cron or scheduler

## Instructions

### 1. Host cron (example)

```bash
# Backup daily at 3 AM
0 3 * * * tar -czf ~/backups/openclaw-$(date +\%Y-\%m-\%d).tar.gz \
  ~/clawfather/.openclaw \
  ~/clawfather/config.yaml
```

### 2. OpenClaw cron (isolated job)

Create a cron job that runs a backup script:

```bash
docker compose exec openclaw-gateway openclaw cron add \
  --name "Daily backup" \
  --cron "0 3 * * *" \
  --tz "America/Los_Angeles" \
  --session isolated \
  --message "Run backup script: copy openclaw.json and config.yaml to backup dir"
```

### 3. What to backup

* `openclaw.json` (or `~/.openclaw/openclaw.json` in container)
* `config.yaml`
* `./skills`
* `./.openclaw` (config and logs)
* **Exclude**: `.env`, credentials dir, `device-auth.json`

## Docker note (Clawfather)

Backup paths are host-relative. Mount a backup volume or use host cron for simplicity.

## Links

* [02-cron-jobs](02-cron-jobs.md)
* [32-skill-quick-install](32-skill-quick-install.md)
* [update-plus skill](https://clawhub.ai) (config backups)
