# Post-Installation Security Hardening (Docker + Bridge Edition)

After setting up OpenClaw with Docker and Keyboard Maestro, use this guide to audit your security posture.

**Best practices applied**: Container capability dropping, no-new-privileges, bridge isolation, volume least-privilege, log management, and regular updates.

---

## 1. Bridge Security Audit (Keyboard Maestro)

Your bridge is the most critical surface area because it punches a hole from the container to your host.

### A. Test Auth Protection
Try to trigger a macro from your terminal *without* credentials:
```bash
curl "http://localhost:4490/action?TriggerValue=TestMacro"
```
*   **Safe Result**: `401 Unauthorized` or password prompt.
*   **Unsafe Result**: The macro executes. **Fix this in KM Preferences immediately.**

### B. Macro Audit
Open Keyboard Maestro and check the "Smart Group" or folder where you put AI-enabled macros.
*   Ensure **NO** macro with "Public Web Entry" triggers a raw shell script like `do shell script "..."`.
*   Ensure **NO** macro allows arbitrary input to be executed as code.

---

## 2. Docker Hardening Verification

Verify that your `docker-compose.yml` matches the hardened standards from [07-manual-install.md](../01-pre_install/07-manual-install.md).

### Checklist:
1.  **Capabilities**: `cap_drop: [ALL]` is present (or at minimum drop `CAP_SYS_ADMIN` and other dangerous caps).
2.  **Privilege**: `security_opt: [no-new-privileges:true]` is present.
3.  **God Mode**: `/var/run/docker.sock` is **COMMENTED OUT** (unless you are intentionally using it).
4.  **Network**: The container is on a bridge network, not `network_mode: host`.

### Best Practices (from industry standards)
* Run containers as non-root when possible.
* Use read-only root filesystem where the workload allows.
* Limit resource usage (CPU, memory) to contain blast radius.

---

## 3. Skill & Volume Audit

### 1. Skill Scanner
Run the security scanner inside the container to check your installed skills:
```bash
docker compose exec openclaw-gateway clawdhub run skill-scanner --all
```
If `clawdhub` is not available, use:
```bash
docker compose exec openclaw-gateway openclaw security audit --deep
```

### 2. Volume Exposure
Check what you have mounted in `docker-compose.yml`:
*   mapped `~/Projects`? -> **Risk**: Agent can read/write your code. Ensure `SANDBOX_MODE=true` and Safe Mode are enabled.
*   mapped `~/`? -> **CRITICAL RISK**: Unmount immediately. Never map your entire home directory.

---

## 4. Log Management

Logs inside the container can grow large or contain sensitive data.

### Check Logs
```bash
docker compose exec openclaw-gateway ls -lh /home/node/.openclaw/logs
```
Logs are typically in `./.openclaw/logs/gateway.log` and `./.openclaw/logs/openclaw.log` on the host.

### Purge Policy
If you find sensitive data (API keys, personal info) in logs:
```bash
# Truncate logs (preserves file, clears content)
: > ./.openclaw/logs/gateway.log
: > ./.openclaw/logs/openclaw.log
```

---

## 5. Maintenance & Updates

### Update Strategy
*   **Docker Image**: Run `docker compose pull` weekly to get the latest security patches for the Gateway.
*   **Bridge**: Keep Keyboard Maestro updated to the latest version.
*   **Skills**: Run `docker compose exec openclaw-gateway openclaw skill sync` and re-audit after updates.

---

## Docker Note (Clawfather)

All commands above use `openclaw-gateway` as the Clawfather service name. Run from your project directory where `docker-compose.yml` resides.

## Links

* [Docker Security Hardening](https://docs.docker.com/engine/security/)
* [Clawfather MANUAL_INSTALL](../01-pre_install/07-manual-install.md)
