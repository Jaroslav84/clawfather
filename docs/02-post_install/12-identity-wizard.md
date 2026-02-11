# Identity Wizard

Set the agent's name, theme, emoji, and avatar. Affects how the bot presents itself in channels.

## What it is

`identity` config defines the agent's persona: name, theme (e.g. "helpful assistant"), emoji, and optional avatar. Workspace files like `IDENTITY.md` and `SOUL.md` provide deeper personality.

**Best practice**: Keep identity consistent; use `SOUL.md` for behavioral guidelines.

## When to use it

* Personalize the bot's voice
* Match brand or role (e.g. "Ops Bot", "Research Assistant")

## Prerequisites

* Access to `openclaw.json` or workspace files

## Instructions

### 1. Config identity

```json
{
  "identity": {
    "name": "Clawd",
    "theme": "helpful assistant",
    "emoji": "🦞",
    "avatar": "avatars/openclaw.png"
  }
}
```

### 2. IDENTITY.md (workspace)

Create `IDENTITY.md` in workspace root:

```markdown
- **Name:** Clawd
- **Creature:** AI assistant
- **Vibe:** sharp, concise
- **Emoji:** 🦞
- **Avatar:** avatars/openclaw.png
```

### 3. SOUL.md (personality)

`SOUL.md` defines behavioral guidelines—helpfulness, boundaries, tone. Edit as you evolve the agent.

## Configuration reference

| Path | Purpose |
|------|---------|
| `identity.name` | Display name |
| `identity.theme` | Short descriptor |
| `identity.emoji` | Signature emoji |
| `identity.avatar` | Path or URL |

## Docker note (Clawfather)

Workspace is mounted; `IDENTITY.md` and `SOUL.md` live in the workspace dir (project root).

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
