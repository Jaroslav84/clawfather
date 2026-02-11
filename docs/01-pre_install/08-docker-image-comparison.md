# OpenClaw Docker Image Comparison

## Official & Popular Images

---

### `alpine/openclaw`

**Docker Hub:** [alpine/openclaw](https://hub.docker.com/r/alpine/openclaw)

| Feature | Details |
|---------|---------|
| **Size** | Not specified (claims Alpine but uses Debian) |
| **Last Updated** | 2026.1.30 |
| **Maintenance** | Active |
| **Configuration** | Manual |
| **Security** | Standard |
| **Setup** | Manual configuration required |
| **Best For** | Users familiar with Alpine/Debian |

**Pros:**
- Intended to be lightweight (Alpine-based)
- Tagged with version numbers (2026.1.30)

**Cons:**
- **Currently built on Debian** (not Alpine) due to musl library compatibility issues
- Misleading name (says Alpine but uses Debian)
- Older update compared to fourplayers

---

### `fourplayers/openclaw`

**Docker Hub:** [fourplayers/openclaw](https://hub.docker.com/r/fourplayers/openclaw)

| Feature | Details |
|---------|---------|
| **Size** | 1.3 GB |
| **Last Updated** | ~2 hours ago (as of Feb 3, 2026) |
| **Maintenance** | ✅ Actively maintained |
| **Configuration** | ✅ Zero-config startup |
| **Security** | ✅ HTTPS support built-in |
| **Setup** | ✅ Auto-configuration on first run |
| **Best For** | Production use, quick setup, security-conscious deployments |

**Pros:**
- Ready-to-run with no complex setup
- Most recently updated (active development)
- HTTPS support for secure bridge connections
- Auto-configuration reduces setup errors
- Well-suited for custom configurations (like Clawfather)

**Cons:**
- Larger size (1.3 GB)

**Clawfather behaviour:** When you select this image, Root Mode is **auto-enabled** and **hidden** from the Security checklist (the image requires root for its entrypoint). You see one fewer security toggle.

---

### `ghcr.io/phioranex/openclaw-docker`

**GitHub:** [phioranex/openclaw-docker](https://github.com/phioranex/openclaw-docker)

| Feature | Details |
|---------|---------|
| **Size** | Not specified |
| **Last Updated** | Daily automated builds |
| **Maintenance** | ✅ Automated (checks every 6 hours) |
| **Configuration** | Manual |
| **Security** | Standard |
| **Setup** | Manual configuration required |
| **Best For** | Users who want bleeding-edge updates |

**Pros:**
- Automatically builds daily
- Checks for new OpenClaw releases every 6 hours
- Always up-to-date with latest OpenClaw version
- GitHub Container Registry (good for CI/CD)

**Cons:**
- Requires manual configuration
- Less documentation than fourplayers
- May include unstable features

---

### `coollabsio/openclaw`

**Provider:** Coolify/Coolabs

| Feature | Details |
|---------|---------|
| **Size** | Not specified |
| **Last Updated** | Not specified |
| **Maintenance** | Community maintained |
| **Configuration** | Environment-based |
| **Security** | ✅ Nginx proxy included |
| **Setup** | Automated with environment variables |
| **Best For** | Coolify platform users, nginx proxy setups |

**Pros:**
- Fully featured with nginx proxy
- Environment-based configuration (good for Docker Compose)
- Designed for Coolify platform integration

**Cons:**
- May be overkill if you don't need nginx proxy
- Less frequently updated than fourplayers

---

### `1panel/openclaw`

**Docker Hub:** [1panel/openclaw](https://hub.docker.com/r/1panel/openclaw)

| Feature | Details |
|---------|---------|
| **Size** | 1011.6 MB (~1 GB) |
| **Last Updated** | 1 day ago (as of Feb 3, 2026) |
| **Maintenance** | ✅ Actively maintained |
| **Configuration** | Manual |
| **Security** | Standard |
| **Setup** | Manual configuration required |
| **Best For** | 1Panel platform users |

**Pros:**
- Smaller size than fourplayers
- Recently updated
- Optimized for 1Panel management platform

**Cons:**
- Designed for 1Panel ecosystem
- May not work well outside 1Panel
- Less documentation for standalone use

## Sandbox Images

OpenClaw uses specialized sandbox images for isolated code execution. These are typically used internally by OpenClaw and don't need to be specified in your `docker-compose.yml`.

### `openclaw-sandbox:bookworm-slim`

| Feature | Details |
|---------|---------|
| **Base** | Debian Bookworm Slim |
| **Purpose** | Basic sandbox for code execution |
| **Includes** | Minimal runtime environment |
| **Best For** | Lightweight code execution |

---

### `openclaw-sandbox-common:bookworm-slim`

| Feature | Details |
|---------|---------|
| **Base** | Debian Bookworm Slim |
| **Purpose** | Development sandbox |
| **Includes** | Node.js, Go, Rust, common build tools |
| **Best For** | Multi-language development tasks |

---

### `openclaw-sandbox-browser:bookworm-slim`

| Feature | Details |
|---------|---------|
| **Base** | Debian Bookworm Slim |
| **Purpose** | Browser automation sandbox |
| **Includes** | Chromium with Chrome DevTools Protocol (CDP) |
| **Best For** | Web scraping, browser automation, UI testing |

---

## Recommendation Matrix

| Use Case | Recommended Image | Why |
|----------|------------------|-----|
| **Production** | `fourplayers/openclaw` | Zero-config, HTTPS, actively maintained |
| **Bleeding Edge** | `ghcr.io/phioranex/openclaw-docker` | Daily builds, auto-updates |
| **Coolify Platform** | `coollabsio/openclaw` | Native Coolify integration |
| **1Panel Platform** | `1panel/openclaw` | Native 1Panel integration |
| **Smallest Size** | `1panel/openclaw` | 1 GB vs 1.3 GB |

---

## Clawfather Default

**Current:** `fourplayers/openclaw:latest`

This image is selected as the default for Clawfather because:
1. ✅ Zero-config startup works well with Clawfather's custom security settings
2. ✅ HTTPS support complements the OpenClaw Bridge
3. ✅ Most recently updated (active maintenance)
4. ✅ Auto-configuration reduces conflicts with custom volume mounts
5. ✅ Well-documented and community-tested

When this image is chosen, the installer automatically enables Root Mode and hides it from the Security step (fewer toggles).

---

## How to Change Images

Edit `src/docker-compose.yml`:

```yaml
services:
  openclaw:
    image: fourplayers/openclaw:latest  # Change this line
```

**Examples:**

```yaml
# Use phioranex for bleeding edge
image: ghcr.io/phioranex/openclaw-docker:latest

# Use 1panel for smaller size
image: 1panel/openclaw:latest

# Use coollabsio for nginx proxy
image: coollabsio/openclaw:latest
```

After changing, run:
```bash
docker compose pull
docker compose up -d
```
