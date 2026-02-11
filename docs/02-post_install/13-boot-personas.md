# Boot Personas

Load custom instructions from `BOOT.md` (or `boot.md`) when the gateway starts. Use for startup tasks, personas, or system-wide prompts.

## What it is

The `boot-md` hook reads `BOOT.md` from the workspace and runs its instructions via the agent at gateway startup. Bundled hook; enable via `openclaw hooks enable boot-md`.

**Best practice**: Keep BOOT.md focused; avoid secrets (it becomes prompt context).

## When to use it

* Run startup checks
* Inject persona or project context
* Send a "ready" message to a channel

## Prerequisites

* `hooks.internal.enabled: true`
* `boot-md` hook enabled
* `workspace.dir` configured

## Instructions

### 1. Enable boot-md

```bash
docker compose exec openclaw-gateway openclaw hooks enable boot-md
```

### 2. Create BOOT.md

In workspace root (e.g. `./BOOT.md` or project root):

```markdown
# Startup instructions

1. Check that calendar and inbox skills are available.
2. If everything is ready, send a brief "Ready" message to the last channel.
```

### 3. Restart gateway

```bash
docker compose restart openclaw-gateway
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `hooks.internal.entries.boot-md.enabled` | Enable/disable |

## Docker note (Clawfather)

Workspace is mounted. Ensure `BOOT.md` is in the workspace root (project root).

## Links

* [Hooks](https://docs.clawd.bot/hooks)
* [boot-md bundled hook](https://docs.clawd.bot/hooks#boot-md)
