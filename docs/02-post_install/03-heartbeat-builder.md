# Heartbeat Builder

Periodic agent turns in the main session so the model can surface anything that needs attention. Use heartbeat when timing can drift; use [Cron](02-cron-jobs.md) when you need precise scheduling.

## What it is

Heartbeat runs every N minutes (default 30m), reads `HEARTBEAT.md` if it exists, and either replies `HEARTBEAT_OK` (silent) or surfaces an alert. Best for background awareness: inbox, calendar, reminders—without spamming you.

**Best practice**: Keep `HEARTBEAT.md` small to avoid prompt bloat and token cost. Use active hours to avoid night-time runs.

## When to use it

* Batch multiple checks (inbox + calendar + notifications) in one turn
* When conversational context from recent messages helps
* When timing can drift slightly
* To reduce API calls by combining periodic checks

## Prerequisites

* Gateway running
* Heartbeat enabled (default: `every: "30m"`)

## Instructions

### 1. Create HEARTBEAT.md in workspace

In your agent workspace (project root or `~/.openclaw/workspace`), create `HEARTBEAT.md`:

```markdown
# Heartbeat checklist

- Quick scan: anything urgent in inboxes?
- If it's daytime, do a lightweight check-in if nothing else is pending.
- If a task is blocked, write down _what is missing_ and ask next time.
```

**Tip**: Keep it tiny. Empty or headers-only = OpenClaw skips the run to save API calls.

### 2. Configure heartbeat (optional)

Edit `~/.openclaw/openclaw.json` (or via gateway `config.patch`):

```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "30m",
        "target": "last",
        "activeHours": {
          "start": "09:00",
          "end": "22:00",
          "timezone": "America/New_York"
        }
      }
    }
  }
}
```

### 3. Manual wake (on-demand)

```bash
docker compose exec openclaw-gateway openclaw system event --text "Check for urgent follow-ups" --mode now
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `agents.defaults.heartbeat.every` | Interval (default: `30m`; `0m` disables) |
| `agents.defaults.heartbeat.target` | `last` \| `none` \| channel id |
| `agents.defaults.heartbeat.to` | Channel-specific recipient |
| `agents.defaults.heartbeat.activeHours` | `{ start, end, timezone }` |
| `agents.defaults.heartbeat.model` | Model override for heartbeat runs |
| `agents.defaults.heartbeat.includeReasoning` | Deliver Reasoning: message (default: false) |

## Response contract

* If nothing needs attention: reply `HEARTBEAT_OK` (stripped, no delivery if content ≤300 chars).
* For alerts: do **not** include `HEARTBEAT_OK`; return only the alert text.

## Docker note (Clawfather)

Config lives in the mounted OpenClaw dir. `HEARTBEAT.md` goes in the workspace (project root).

## Links

* [Heartbeat](https://docs.clawd.bot/gateway/heartbeat)
* [Cron vs Heartbeat](https://docs.clawd.bot/automation/cron-vs-heartbeat)

## Troubleshooting

**Cost too high**: Increase `every` (e.g. `1h`), use cheaper `model`, or set `target: "none"`.

**Alert spam**: Tighten `HEARTBEAT.md` or use `activeHours` to restrict runs.
