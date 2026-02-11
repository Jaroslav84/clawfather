# Security Guide & Risk Assessment

OpenClaw is a powerful AI assistant that interacts directly with your local machine and external services. Because it can execute arbitrary code via skills, understanding the security landscape is essential for safe operation.

## ⚠️ local Machine Risks

Running OpenClaw directly on your host machine (outside of a VM or Container) exposes you to several risks:

### 1. Malicious Skills
Skills are essentially Node.js/Python scripts. A malicious skill could:
- Exfiltrate sensitive files (SSH keys, environment variables, browser cookies).
- Install backdoors or crypto-miners.
- Delete or encrypt user data.
- **Mitigation**: Always audit skills using `skill-scanner` and only download from trusted sources like [ClawHub.ai](https://clawhub.ai). See [02-security-pre-install](02-security-pre-install.md) and [10-security-post-install](10-security-post-install.md).

### 2. Prompt Injection (jailbreaking)
An attacker (or even a malicious website the agent is browsing) could provide instructions that trick the agent into:
- Executing dangerous system commands (e.g., `rm -rf /`).
- Sending private data to an external URL.
- **Mitigation**: Use "Safe" versions of tools and require manual confirmation for destructive actions.

### 3. Entitlement & Permission Abuse
On macOS, OpenClaw requires TCC permissions (Screen Recording, Accessibility, Camera).
- If the agent is compromised, an attacker gains these same permissions.
- **Mitigation**: Grant the minimum necessary permissions and avoid running the Gateway as root.

### 4. Persistence
OpenClaw can manage its own background processes (launchd). A compromised agent could ensure its own persistence across reboots.

---

## 🏗️ Local vs. Docker Comparison

### Local Machine Installation
- **Isolation**: **None**. Agent has access to your `$HOME` and system.
- **Hardware Access**: **Direct**. Full access to GPU, Camera, Mic, UI.
- **macOS Integration**: **Deep**. Supports AppleScript, TCC, menu bar.
- **Persistent Data**: Lives in your standard app data folders.
- **Security Risk**: **High**. Escape to host is trivial (it's already there).

### Docker / Containerized
- **Isolation**: **High**. Filesystem is restricted to mapped volumes.
- **Hardware Access**: **Restricted**. Requires complex pass-through for UI/Hardware.
- **macOS Integration**: **Limited**. Hard to trigger native macOS UI/TCC.
- **Persistent Data**: Managed via Docker Volumes.
- **Security Risk**: **Medium**. Escape is much harder, but not impossible.

> [!TIP]
> **Conclusion**: If you are a developer testing macOS-specific UI features (like Canvas or Peekaboo), **local installation** is often necessary. If you are running the Gateway as a server for web/data tasks, **Docker** is the safer, recommended choice.

---

## ✅ Security Best Practices

1.  **Use skill-scanner**: Regularly run security audits on your installed skills.
2.  **Separate Workspaces**: Use dedicated folders for OpenClaw to limit filesystem exposure.
3.  **VM for isolation**: If you need macOS features with high safety, use a **macOS VM (Lume)** instead of your primary machine.
4.  **Audit Logs**: Monitor the Gateway logs to see exactly what commands the agent is running.
