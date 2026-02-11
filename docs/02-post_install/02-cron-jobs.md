# Cron Jobs

OpenClaw's built-in scheduler for time-based AI agent tasks. Use cron when you need **precise timing** (e.g. "7 AM every Monday"); use [Heartbeat](03-heartbeat-builder.md) when timing can drift.

## What it is

Cron runs inside the Gateway. Jobs persist under `~/.openclaw/cron/` so restarts don't lose schedules. Two execution styles: **main session** (uses heartbeat context) or **isolated** (fresh session, optional delivery to a channel).

## When to use it

* Morning briefings at 7 AM
* One-shot reminders ("poke me in 20 minutes")
* Weekly reports on Friday
* Hourly inbox checks (if exact timing matters)

**Best practice**: Use **cron** for time-sensitive operations; use **heartbeat** for periodic checks where exact timing is less critical.

## Prerequisites

* Gateway running
* `cron.enabled: true` (default)

## Instructions

### 1. One-shot reminder (main session)

```bash
docker compose exec openclaw-gateway openclaw cron add \
  --name "Reminder" \
  --at "2026-01-12T18:00:00Z" \
  --session main \
  --system-event "Reminder: submit expense report." \
  --wake now \
  --delete-after-run
```

Human-friendly duration:
```bash
docker compose exec openclaw-gateway openclaw cron add \
  --name "Calendar check" \
  --at "20m" \
  --session main \
  --system-event "Next heartbeat: check calendar." \
  --wake now
```

### 2. Recurring isolated job (deliver to channel)

```bash
docker compose exec openclaw-gateway openclaw cron add \
  --name "Morning status" \
  --cron "0 7 * * *" \
  --tz "America/Los_Angeles" \
  --session isolated \
  --message "Summarize inbox + calendar for today." \
  --announce \
  --channel whatsapp \
  --to "+15551234567"
```

### 3. List and manage jobs

```bash
docker compose exec openclaw-gateway openclaw cron list
docker compose exec openclaw-gateway openclaw cron run <job-id>
docker compose exec openclaw-gateway openclaw cron edit <job-id> --message "Updated prompt"
```

### 4. Immediate system event (no job)

```bash
docker compose exec openclaw-gateway openclaw system event --mode now --text "Next heartbeat: check battery."
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `cron.enabled` | Enable/disable (default: true) |
| `cron.store` | Job store path (default: `~/.openclaw/cron/jobs.json`) |
| `cron.maxConcurrentRuns` | Concurrency limit (default: 1) |

Disable cron: `cron.enabled: false` or `OPENCLAW_SKIP_CRON=1` (env).

## Schedule types

| Kind | Use case | Example |
|------|----------|---------|
| `at` | One-shot | `--at "2026-01-12T18:00:00Z"` or `--at "20m"` |
| `every` | Fixed interval | `schedule.everyMs: 3600000` (1h) |
| `cron` | 5-field expression | `--cron "0 7 * * *"` (7 AM daily) |

## Main vs isolated

* **Main**: Uses heartbeat prompt + main session context. Best for reminders that need your conversation history.
* **Isolated**: Fresh session, no prior context. Best for briefings, reports, or noisy tasks. Use `--announce` to deliver output to a channel.

## Docker note (Clawfather)

All commands use `openclaw-gateway`. Run from your project directory.

## Links

* [Cron Jobs](https://docs.clawd.bot/automation/cron-jobs)
* [Cron vs Heartbeat](https://docs.clawd.bot/automation/cron-vs-heartbeat)

## Troubleshooting

**Nothing runs**
* Check `cron.enabled` and `OPENCLAW_SKIP_CRON`
* Gateway must run continuously (cron runs inside it)
* Confirm timezone (`--tz`) vs host timezone
