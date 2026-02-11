# Model Role Routing

Route tasks to different models: general (chat), light (heartbeat/subagents), heavy (coding/complex). Clawfather uses `config.yaml` as the source of truth for provider and agent setup.

## What it is

`config.yaml` defines model routing. OpenClaw uses `agents.defaults.model` and role-specific overrides.

**Best practice**: Use cheap models for heartbeat/cron; reserve expensive models for coding.

## When to use it

* Cost optimization
* Task-appropriate model selection
* Fallback chains

## Prerequisites

* `config.yaml` in project root
* API keys in `.env`

## Instructions

### 1. config.yaml (Clawfather)

```yaml
# Provider and agent setup (general/light/heavy)
models:
  agents:
    general:
      primary: zai/glm-4.7
      fallbacks:
        - google/gemini-3-pro-preview
    light:
      primary: zai/glm-4.7-flash
      fallbacks:
        - google/gemini-3-flash-preview
    heavy:
      primary: zai/glm-4.7
      fallbacks:
        - google/gemini-3-pro-preview
```

### 2. openclaw.json

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "zai/glm-4.7-flash",
        "fallbacks": ["google/gemini-3-pro-preview"]
      }
    }
  }
}
```

### 3. Per-agent override

```json
{
  "agents": {
    "list": [{
      "id": "ops",
      "model": "anthropic/claude-haiku-4-5"
    }]
  }
}
```

## Docker note (Clawfather)

`config.yaml` is mounted and used as the source of truth. Edit it and re-run install to apply changes.

## Links

* [Providers](https://docs.clawd.bot/providers)
* [01-configuration](../03-openclaw_cli/01-configuration.md)
* [config.yaml](../config.yaml)
