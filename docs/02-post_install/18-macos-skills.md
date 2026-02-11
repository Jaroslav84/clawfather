# macOS Skills

Skills that integrate with macOS: peekaboo (UI capture), apple-mail, accli (Calendar), apple-reminders, homebrew, mac-tts, moltbot-ha (Home Assistant).

## What it is

OpenClaw skills can control macOS apps when the agent runs with access to the host (e.g. via Bridge or when host is the runtime). Some skills need host-side tools (e.g. `accli` for Calendar).

**Best practice**: Use Bridge or KM to expose macOS actions; install only skills you need.

## When to use it

* Calendar, Mail, Reminders automation
* UI capture (peekaboo)
* Home Assistant control
* Package management (Homebrew)

## Prerequisites

* Skills synced (`./src/sync_skills.sh` or install wizard)
* Bridge or host access for macOS-specific tools
* Some skills need host binaries (e.g. `accli`)

## Instructions

### 1. Sync skills

```bash
./src/sync_skills.sh
```

Or via Docker:
```bash
docker compose exec openclaw-gateway openclaw skill sync
```

### 2. macOS skill examples

| Skill | Purpose |
|------|---------|
| peekaboo | Capture UI, automate |
| apple-mail | Read/send emails |
| accli | Calendar events |
| apple-reminders | Todo lists |
| homebrew | Packages & casks |
| mac-tts | Text-to-speech |
| moltbot-ha | Home Assistant |

### 3. Host dependencies

Some skills expect tools on the host. For Docker, the agent runs inside the container—macOS tools must be invoked via Bridge or KM.

Example: "Open Calendar" → KM macro that opens Calendar app.

### 4. Install skill deps

```bash
docker compose exec openclaw-gateway npm install -g <pkg>
```

## Docker note (Clawfather)

Agent runs in container; macOS-specific tools run on host via Bridge or KM. Configure skills that need host access accordingly.

## Links

* [README Included Skills](../README.md#included-skills)
* [ClawHub](https://clawhub.ai)
