## 🌉 Bridging Docker to macOS Host

Since Docker containers are isolated, they cannot directly run AppleScript (`osascript`) or control macOS system features. However, you can create a "Bridge" to allow your OpenClaw agent to reach out and control the host.

Here are the three best options, ranked by flexibility and ease of use.

## Option 1: The "OpenClaw Bridge"
Run a lightweight HTTP server on your Mac (outside Docker) that listens for commands.

**How it works:**
1.  **Host**: A simple Python/Node script runs on your Mac, listening on port `8000`.
2.  **Docker**: OpenClaw sends HTTP requests to `http://host.docker.internal:8000/run?cmd=play_music`.
3.  **Host**: The script receives the request and executes the corresponding `osascript` or shell command.

**Pros:**
*   ✅ **Very Secure**: You define exactly which commands are allowed in the server code.
*   ✅ **Easy to Debug**: It's just HTTP requests.
*   ✅ **Flexible**: Can trigger AppleScript, shell scripts, or Python functions.

**Cons:**
*   ⚠️ Requires running a terminal window or background service on your Mac.

---

## Keyboard Maestro Web Server
If you primarily want to trigger Keyboard Maestro macros, use its built-in web server.

**How it works:**
1.  In Keyboard Maestro, enable the **Web Server** in preferences.
2.  Set up triggers for your macros using the "Public Web Entry" trigger.
3.  OpenClaw simply requesting a URL: `http://host.docker.internal:4490/action?TriggerValue=PlayMusic`

**Pros:**
*   ✅ **Zero Code**: No custom scripts to write on the host side.
*   ✅ **Native KM Support**: Best for Keyboard Maestro heavy users.

**Cons:**
*   ⚠️ **Limited**: Can only trigger pre-defined macros, not arbitrary commands.
*   ⚠️ **Security**: Anyone on your local network could potentially trigger macros if not authenticated.

---

## Danger Option : SSH Tunneling
Give the Docker container SSH access to your host machine.

**How it works:**
1.  Enable "Remote Login" in macOS System Settings > Sharing.
2.  Mount your SSH keys (or a specific dedicated key) into the Docker container.
3.  OpenClaw runs commands like: `ssh user@host.docker.internal "osascript -e 'set volume output volume 50'"`

**Pros:**
*   ✅ **Powerful**: Full shell access to the host.
*   ✅ **Native**: Uses standard SSH protocols.

**Cons:**
*   🛑 **Security Risk**: If the container is compromised, the attacker has full SSH access to your Mac.
*   🛑 **Complexity**: Managing SSH keys and `known_hosts` inside Docker can be annoying.

---