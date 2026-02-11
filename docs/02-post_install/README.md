# Post-Install Configuration Guides

After hatching OpenClaw, use these guides to configure channels, automation, security, and more. **Start with 01-security-post-install.md.**

→ [00-TABLE-OF_CONTENTS](00-TABLE-OF_CONTENTS.md) · [Pre-install](../01-pre_install/00-TABLE-OF-CONTENTS.md) · [OpenClaw Reference](../03-openclaw_cli/00-TABLE-OF-CONTENTS.md)

## Step 1 (Priority)

| # | Guide | Description |
|---|-------|-------------|
| 01 | [Security Post-Install](01-security-post-install.md) | Bridge audit, Docker hardening, skill scanner, logs |

## Automation

| # | Guide | Description |
|---|-------|-------------|
| 02 | [Cron Jobs](02-cron-jobs.md) | Scheduled tasks, reminders, morning briefings |
| 03 | [Heartbeat Builder](03-heartbeat-builder.md) | Periodic checks, HEARTBEAT.md |
| 04 | [Session Reset Rules](04-session-reset-rules.md) | Idle timeout, daily reset, triggers |
| 11 | [Webhook Presets](11-webhook-presets.md) | Gmail, GitHub, custom webhooks |
| 33 | [Scheduled Backup](33-scheduled-backup.md) | Config and skills backup |

## Channels

| # | Guide | Description |
|---|-------|-------------|
| 05 | [WhatsApp](05-channels-whatsapp.md) | Baileys, allowlist, pairing |
| 06 | [Telegram](06-channels-telegram.md) | Bot token, DMs, groups |
| 07 | [Discord](07-channels-discord.md) | Bot token, guilds, DMs |
| 08 | [Slack](08-channels-slack.md) | Bot token, channels, slash commands |
| 09 | [Matrix](09-channels-matrix.md) | Plugin, E2EE, rooms |
| 10 | [Secure DM Mode](10-secure-dm-mode.md) | Multi-user session isolation |

## Identity & Personality

| # | Guide | Description |
|---|-------|-------------|
| 12 | [Identity Wizard](12-identity-wizard.md) | Name, theme, emoji, avatar |
| 13 | [Boot Personas](13-boot-personas.md) | BOOT.md, startup instructions |
| 14 | [Message Formatting](14-message-formatting.md) | Prefixes, reactions, typing |

## Host Bridge & macOS

| # | Guide | Description |
|---|-------|-------------|
| 15 | [OpenClaw Bridge](15-openclaw-bridge.md) | HTTP server, AppleScript, host commands |
| 16 | [macOS Docker Setup](16-macos-docker-setup.md) | Security-focused setup options |
| 17 | [Keyboard Maestro](17-keyboard-maestro-macos.md) | KM Web Server, macros, auth |
| 18 | [macOS Skills](18-macos-skills.md) | peekaboo, apple-mail, accli, etc. |

## Tools & Sandbox

| # | Guide | Description |
|---|-------|-------------|
| 19 | [Tool Allowlist](19-tool-allowlist.md) | exec, read, write, elevated |
| 20 | [Sandbox Options](20-sandbox-options.md) | Workspace restriction, Docker sandbox |
| 21 | [Media & Transcription](21-media-transcription.md) | Audio, video, Whisper, Gemini |

## Models

| # | Guide | Description |
|---|-------|-------------|
| 22 | [Model Role Routing](22-model-role-routing.md) | General, light, heavy, config.yaml |
| 23 | [Custom Provider](23-custom-provider.md) | LiteLLM, self-hosted |

## Remote & Network

| # | Guide | Description |
|---|-------|-------------|
| 24 | [Tailscale Setup](24-tailscale-setup.md) | Serve, Funnel |
| 25 | [Remote Gateway](25-remote-gateway.md) | Connect to remote gateway |
| 26 | [Discovery mDNS](26-discovery-mdns.md) | LAN discovery |

## Observability

| # | Guide | Description |
|---|-------|-------------|
| 27 | [Logging Config](27-logging-config.md) | Level, file, redaction |
| 28 | [Background Exec](28-background-exec.md) | Long-running commands |
| 29 | [Health & Doctor](29-health-doctor.md) | doctor, security audit |

## Advanced

| # | Guide | Description |
|---|-------|-------------|
| 30 | [Memory Search](30-memory-search.md) | Embeddings, RAG |
| 31 | [Queue & Routing](31-queue-routing.md) | Batching, mention patterns |
| 32 | [Skill Quick-Install](32-skill-quick-install.md) | Sync, clawhub, scanner |
