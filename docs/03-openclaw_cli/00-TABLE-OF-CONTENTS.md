# OpenClaw Reference — Table of Contents

Local copy of **commands, config, and API** from [docs.clawd.bot](https://docs.clawd.bot/). No overview or quick start—only the bits useful for scripting and Cursor.

→ [Pre-install TOC](../01-pre_install/00-TABLE-OF-CONTENTS.md) · [Post-install TOC](../02-post_install/00-TABLE-OF_CONTENTS.md)

| # | Doc | What it covers |
|---|-----|----------------|
| 01 | [Configuration](01-configuration.md) | Config file, paths, RPC apply/patch, key options |
| 02 | [Security](02-security.md) | Audit, checklist, hardening, credential storage |
| 03 | [CLI Reference](03-cli-reference.md) | Command tree, global flags, all CLI commands |
| 04 | [CLI config](04-cli-config.md) | `config get/set/unset` — config by path |
| 05 | [CLI gateway](05-cli-gateway.md) | `gateway run` — WebSocket server, channels, nodes |
| 06 | [CLI health](06-cli-health.md) | `health` — gateway health probe |
| 07 | [CLI security](07-cli-security.md) | `security audit` — config + state checks, fix |
| 08 | [CLI devices](08-cli-devices.md) | `devices list/approve/reject` — pairing |
| 09 | [CLI models](09-cli-models.md) | `models status/set/scan` — model discovery, auth |
| 10 | [CLI agent](10-cli-agent.md) | `agent` — run one LLM turn |
| 11 | [CLI message](11-cli-message.md) | `message send/poll/react` — channel ops (needs `--target`) |
| 12 | [RPC API](12-rpc-api.md) | Gateway RPC, adapters, config.apply/patch |
