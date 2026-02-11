# OpenClaw Bridge

A lightweight HTTP server on your Mac that receives commands from the Docker container and runs AppleScript, shell, or Python. Most secure bridge option—you define exactly which commands are allowed.

## What it is

Docker containers cannot run macOS system features directly. The Bridge runs on the host, listens on a port (e.g. 8000), and executes only the commands you whitelist in code.

**Best practice**: Explicit allowlist of commands; no arbitrary exec. Bind to 127.0.0.1 only.

## When to use it

* Trigger AppleScript (Music, Mail, System Events)
* Run shell scripts or Python
* More flexibility than Keyboard Maestro macros

## Prerequisites

* Python or Node on Mac
* `host.docker.internal` reachable from container (default in Clawfather)

## Instructions

### 1. Create bridge script

Example (Python, port 8000):

```python
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import subprocess

ALLOWED = {"play_music": "osascript -e 'tell application \"Music\" to play'",
           "pause_music": "osascript -e 'tell application \"Music\" to pause'"}

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        q = parse_qs(urlparse(self.path).query)
        cmd = q.get("cmd", [None])[0]
        if cmd in ALLOWED:
            subprocess.run(ALLOWED[cmd], shell=True)
            self.send_response(200)
        else:
            self.send_response(403)
        self.end_headers()

HTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
```

### 2. Run on Mac

```bash
python3 bridge.py
```

### 3. Call from OpenClaw

Agent (or a skill) sends: `http://host.docker.internal:8000/run?cmd=play_music`

### 4. Add auth (recommended)

Add token check in handler; reject requests without valid `Authorization` header.

## Security

* Bind to `127.0.0.1`, not `0.0.0.0`
* Whitelist commands only
* Add token or IP allowlist
* Never pass user input directly to shell

## Docker note (Clawfather)

Container uses `host.docker.internal` to reach your Mac. Ensure the bridge runs on the host before testing.

## Links

* [05-bridge-options](../01-pre_install/05-bridge-options.md)
* [16-macos-docker-setup](16-macos-docker-setup.md)
* [17-keyboard-maestro-macos](17-keyboard-maestro-macos.md)
* [01-security-post-install](01-security-post-install.md)
