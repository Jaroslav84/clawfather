# Keyboard Maestro + macOS Setup

Use Keyboard Maestro's Web Server as a bridge so OpenClaw (in Docker) can trigger macros on your Mac.

## What it is

KM runs on the host; OpenClaw sends HTTP requests to `http://host.docker.internal:4490/action?TriggerValue=MacroName`. Zero code on host—only macro definitions.

**Best practice**: Enable authentication; restrict to localhost; expose only safe macros.

## When to use it

* Trigger Play Music, Open App, Resize Window
* Quick automation without writing a bridge script
* KM-heavy workflows

## Prerequisites

* Keyboard Maestro installed
* Docker OpenClaw running
* `host.docker.internal` available (default in Clawfather)

## Instructions

### 1. Enable KM Web Server

1. Keyboard Maestro → Preferences → Web Server
2. Enable Web Server
3. Set **Username** and **Password** (required for security)
4. Prefer binding to 127.0.0.1 if your KM version supports it

### 2. Create macro with Public Web Entry

1. New Macro → Add Trigger → Public Web Entry
2. Set `Trigger Value` (e.g. `PlayMusic`)
3. Add Actions (e.g. Play Music, Open App)

### 3. TCC permissions

System Settings → Privacy & Security:
* **Accessibility**: Keyboard Maestro Engine
* **Automation**: Keyboard Maestro Engine

### 4. Test from Docker

```bash
docker compose exec openclaw-gateway sh -c 'curl -u user:pass "http://host.docker.internal:4490/action?TriggerValue=PlayMusic"'
```

* **401**: Auth working (correct)
* **200**: Macro executed
* **Connection refused**: KM Web Server not running or wrong port

### 5. Security checklist

* [ ] Username and password set
* [ ] Unauthenticated curl returns 401
* [ ] No macros with raw `do shell script` exposed
* [ ] No macros that accept arbitrary input

## Unsafe macros

* "Run Shell Script" with user-provided input
* "Delete File"
* "Type Keystroke" with variable content

## Docker note (Clawfather)

Container calls `host.docker.internal:4490`. Ensure KM is running on the host.

## Links

* [05-bridge-options](../01-pre_install/05-bridge-options.md)
* [15-openclaw-bridge](15-openclaw-bridge.md)
* [16-macos-docker-setup](16-macos-docker-setup.md)
* [01-security-post-install](01-security-post-install.md)
