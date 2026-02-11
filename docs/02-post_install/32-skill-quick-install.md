# Skill Quick-Install

Install and manage OpenClaw skills. Clawfather syncs curated skills; you can add more via clawhub or manual install.

## What it is

Skills extend the agent with tools and capabilities. Clawfather provides `./src/sync_skills.sh` to download curated skills; `openclaw skill sync` and clawhub install additional ones.

**Best practice**: Sync only needed skills; run skill-scanner periodically for security.

## When to use it

* Add capabilities (GitHub, email, browser)
* Install from ClawHub
* Update existing skills

## Prerequisites

* Gateway running
* Skills dir mounted (Clawfather: `./skills`)

## Instructions

### 1. Sync Clawfather skills

```bash
./src/sync_skills.sh
```

### 2. OpenClaw skill sync

```bash
docker compose exec openclaw-gateway openclaw skill sync
```

### 3. Install via clawhub

```bash
docker compose exec openclaw-gateway clawhub install <skill-name>
```

### 4. Skill scanner (security)

```bash
docker compose exec openclaw-gateway clawdhub run skill-scanner --all
```

## Docker note (Clawfather)

Skills in `./skills` are mounted. Install wizard can run sync; post-install use commands above.

## Links

* [Skills](https://docs.clawd.bot/tools/skills)
* [ClawHub](https://clawhub.ai)
* [README Included Skills](../README.md#included-skills)
