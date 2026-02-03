# Post-Installation Security Hardening

After installing OpenClaw, use this guide to tighten security, audit your skills, and lock down your network configuration.

## 1. Audit Your Installed Skills

Just because a skill is in the repository doesn't mean it's safe for your specific environment.

### Run Security Scans
Use the built-in security skills to audit your downloaded skills:
```bash
# Scan for malicious patterns
npx clawdhub@latest run skill-scanner --path ./skills

# Perform an AI-powered security review
npx clawdhub@latest run skillvet --all
```

### Manual Spot Checks
- Check `SKILL.md` for any tools that run `system.run` or `spawn`.
- Ensure no skill is asking for your `~/.ssh` directory or global environment variables it doesn't need.

---

## 2. macOS Permission Audit (TCC)

Regularly review which permissions OpenClaw actually uses.

### Audit TCC Permissions
1. Go to **System Settings > Privacy & Security**.
2. Check the following sections:
    - **Accessibility**: Does it still need this? (Required for clicking/typing).
    - **Screen Recording**: Does it still need this? (Required for visual context).
    - **Full Disk Access**: **AVOID** granting this unless absolutely necessary.
3. Revoke permissions for any tools or agents you are no longer using.

---

## 3. Network Hardening

The OpenClaw Gateway can be exposed to the network if not configured correctly.

### Bind to Localhost Only
If you are running the Gateway locally and don't need remote access, ensure it only listens on the loopback interface:
```bash
# gateway-config.yaml
host: 127.0.0.1
port: 3000
```

### Use Secure Tunnels (SSH/Tailscale)
If you need remote access, **DO NOT** open ports on your router. Use a secure tunnel:
- **Tailscale**: The easiest way to access your Gateway from anywhere via a private mesh network.
- **SSH Tunneling**: 
  ```bash
  ssh -L 3000:localhost:3000 user@your-mac-ip
  ```

---

## 4. Log Management & Privacy

OpenClaw logs can contain sensitive information like file paths, URLs, and occasionally snippets of your documents.

### Purge Sensitive Logs
OpenClaw logs are usually located in `~/Library/Logs/OpenClaw/` (or your configured log path).
- Regularly clear logs: `rm -rf ~/Library/Logs/OpenClaw/*.log` (or use `trash`).
- Disable verbose logging in production.

---

## 5. Auto-Update Strategy

While staying updated is good for security patches, auto-updating can introduce new, unvetted skills.

### Recommended Strategy:
- **Core App**: Use `auto-updater` for security patches.
- **Skills**: Review changes in [ClawHub.ai](https://clawhub.ai) before updating critical skills manually.
