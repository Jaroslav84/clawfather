# Background Exec

Run long-running commands in the background. Configure timeout and cleanup for exec tool.

## What it is

The exec tool can run commands in the background. `tools.exec.backgroundMs`, `timeoutSec`, and `cleanupMs` control behavior.

**Best practice**: Set reasonable timeouts; enable cleanup to avoid orphan processes.

## When to use it

* Long-running scripts
* Servers or watchers
* Batch jobs

## Prerequisites

* `tools.allow` includes `exec`
* Elevated if needed for host access

## Instructions

```json
{
  "tools": {
    "exec": {
      "backgroundMs": 10000,
      "timeoutSec": 1800,
      "cleanupMs": 1800000
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `tools.exec.backgroundMs` | Max background duration (ms) |
| `tools.exec.timeoutSec` | Timeout per exec |
| `tools.exec.cleanupMs` | Cleanup interval |

## Docker note (Clawfather)

Exec runs inside the container. For host commands, use Bridge or KM.

## Links

* [Exec Tool](https://docs.clawd.bot/tools/exec)
* [Background Process](https://docs.clawd.bot/gateway/background-process)
