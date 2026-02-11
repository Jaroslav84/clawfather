# macOS Docker Setup (Security-Focused)

Run OpenClaw in Docker on macOS with security as the priority. Covers gateway bind, bridge options, volume safety, and TCC.

## What it is

Clawfather runs OpenClaw in Docker. This guide explains setup choices and their security implications.

**Best practice**: Loopback for gateway when possible; OpenClaw Bridge over Keyboard Maestro over SSH; minimal volume mounts.

## Gateway bind options

| Bind | Security | Use case |
|------|----------|----------|
| **Loopback** (127.0.0.1) | Highest | Localhost only; dashboard + TUI on this Mac |
| **LAN** (0.0.0.0) | Medium | Phone/other devices on network; use token auth |
| **Tailnet** | Medium | Tailscale devices only |
| **Auto** | Varies | Loopback → LAN fallback |

**Recommendation**: Use Loopback unless you need remote access; then prefer Tailnet over LAN.

## Bridge options (ranked by security)

| Option | Security | Flexibility |
|-------|----------|-------------|
| **OpenClaw Bridge** | Highest | Explicit allowlist of commands |
| **Keyboard Maestro** | Medium | Predefined macros only; MUST enable auth |
| **SSH tunneling** | Risky | Full shell; avoid unless necessary |

**Recommendation**: Use OpenClaw Bridge when possible; if KM, enable username/password and bind to 127.0.0.1.

## Volume mount safety

| Mount | Risk | Mitigation |
|-------|------|-------------|
| Workspace only | Low | Keep `chmod 700` |
| `~/Projects` | Medium | `SANDBOX_MODE=true`; Safe Mode |
| `~/` | Critical | Never mount entire home |

**Checklist**: `cap_drop`, `no-new-privileges`, no `docker.sock` unless intentional.

## host.docker.internal

On Mac, Docker provides `host.docker.internal` to reach the host. Bridge and KM run on the host; container calls `http://host.docker.internal:4490` (KM) or `:8000` (Bridge).

**Firewall**: Restrict KM Web Server to localhost; do not expose to LAN.

## TCC permissions

Keyboard Maestro Engine (not Docker) needs:
* **Accessibility**: Window/UI control
* **Automation**: Control other apps (Music, Mail)

System Settings → Privacy & Security → grant these to Keyboard Maestro Engine.

## Docker note (Clawfather)

All commands: `docker compose exec openclaw-gateway` or `docker compose run --rm openclaw-cli`.

## Links

* [02-security-pre-install](../01-pre_install/02-security-pre-install.md)
* [15-openclaw-bridge](15-openclaw-bridge.md)
* [17-keyboard-maestro-macos](17-keyboard-maestro-macos.md)
* [01-security-post-install](01-security-post-install.md)
