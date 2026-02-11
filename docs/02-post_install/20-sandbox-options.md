# Sandbox Options

Restrict agent file access to the workspace (sandbox mode) or grant broader access. Configure sandbox behavior for sub-agents and non-main sessions.

## What it is

`agents.defaults.sandbox` controls where the agent can read/write. `mode: "non-main"` restricts sandbox to sub-agents; `workspaceRoot` sets the sandbox root.

**Best practice**: Keep sandbox enabled; use `SANDBOX_MODE=true` in Clawfather to prevent destructive commands.

## When to use it

* Restrict file access to workspace only
* Sub-agent isolation
* Docker sandbox (separate container per run)

## Prerequisites

* Access to `openclaw.json`

## Instructions

### 1. Sandbox mode

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",
        "perSession": true,
        "workspaceRoot": "~/.openclaw/sandboxes"
      }
    }
  }
}
```

### 2. Docker sandbox (optional)

For full isolation, use a Docker-based sandbox:

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "docker": {
          "image": "openclaw-sandbox:bookworm-slim",
          "workdir": "/workspace",
          "readOnlyRoot": true,
          "network": "none"
        }
      }
    }
  }
}
```

### 3. Clawfather Safe Mode

In `docker-compose.yml`, `SANDBOX_MODE=true` prevents `rm -rf` and similar. Works with workspace mount.

## Configuration reference

| Path | Purpose |
|------|---------|
| `agents.defaults.sandbox.mode` | `main` \| `non-main` |
| `agents.defaults.sandbox.workspaceRoot` | Sandbox root |
| `agents.defaults.sandbox.perSession` | Per-session sandbox |
| `agents.defaults.sandbox.docker` | Docker sandbox config |

## Docker note (Clawfather)

Workspace is mounted; sandbox restricts accesses within that mount. `SANDBOX_MODE` adds command-level safeguards.

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
* [Configuration Examples](https://docs.clawd.bot/gateway/configuration-examples)
