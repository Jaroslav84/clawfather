# OpenClaw Ultimate Installation Guide (Docker Edition)

> [!NOTE]
> This guide is tailored for a **macOS Host** running OpenClaw inside **Docker**, with a **Local-First 6-Model Strategy** (DeepSeek Local as Primary, Cloud as Backup).

---

## 1. Requirements

Terminal :)

---

## 2. Directory & Environment Setup

Create a clean workspace for OpenClaw.

```bash
# 1. Create the project directory
mkdir -p ~/clawfather
cd ~/clawfather

# 2. Create the skills directory (mapped to container)
mkdir -p skills .openclaw/logs
```

### The All-Important `.env` File
Create a `.env` file to store your secrets.

```bash
touch .env
```

**Edit `.env` and add your keys:**

```ini
# --- Providers ---
# --- Cloud Providers (Backups / Specialists) ---
# 1. Cloud General (Z.ai Light)
ZAI_API_KEY=your_zai_key_here

# 2. Cloud Coding (Sonnet 3.5) & Cloud Backups (Gemini)
ANTHROPIC_API_KEY=sk-ant-xxx
GEMINI_API_KEY=your_google_ai_key_here

# 3. LOCAL PROVIDERS (PRIMARY)
# "host.docker.internal" is the magic address to reach your Mac From Docker.
OLLAMA_BASE_URL=http://host.docker.internal:11434

# --- System ---
# Preventing the agent from deleting your stuff (Safety)
SAFE_MODE=true
```

---

## 3. The `docker-compose.yml`

Create a `docker-compose.yml` file. This defines how your OpenClaw container runs.

```yaml
version: '3.8'

services:
  openclaw:
    image: openclaw/gateway:latest
    container_name: openclaw_core
    restart: unless-stopped
    
    # Enable access to Host (Your Mac) for Ollama
    extra_hosts:
      - "host.docker.internal:host-gateway"

    environment:
      - SANDBOX_MODE=true
      - TERM=${TERM:-xterm-256color}
      - COLUMNS=${COLUMNS:-80}
      - LINES=${LINES:-24}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - ZAI_API_KEY=${ZAI_API_KEY}
      - OLLAMA_BASE_URL=${OLLAMA_BASE_URL}
      - WORKSPACE_DIR=/root/Projects

    volumes:
      # Map your local Projects folder so you can edit/add them from Mac
      - ~/Projects:/root/Projects
      # Map your local skills folder so you can edit/add them from Mac
      - ./skills:/home/node/.openclaw/skills
      # Logs directory (in .openclaw)
      - ./.openclaw:/home/node/.openclaw
      # (Cool Tweak #2) Persist command history across reboots
      - openclaw_history:/root/.local/share/history
      
      # (Important) Map the model configuration file
      - ./config.yaml:/app/config.yaml
      
      # (Cool Tweak #6) God Mode: Grant agent Docker control (Comment out to disable)
      # - /var/run/docker.sock:/var/run/docker.sock
    
    working_dir: /root/Projects

    # (Cool Tweak #3) Aesthetic Terminal Mode
    tty: true
    stdin_open: true

volumes:
  openclaw_history:
```

---

## 4. Configuring the Local-First 6-Model Strategy

OpenClaw supports "Profiles". You need to tell it which model to use for which task.

In this setup, we prioritize **Local (Free/Private)** models, and fallback to **Cloud (Paid/Smarter)** models only when needed.

Create a file named `config.yaml` in your folder:

```yaml
models:
  default: "ollama/deepseek-coder:6.7b" # Default to local
  
  roles:
    # 1. Coding Tasks
    coding: 
      # Primary: DeepSeek 6.7b (Local)
      provider: ollama
      model: deepseek-coder:6.7b
      api_base: http://host.docker.internal:11434
      # Backup 1: Sonnet 3.5 (Cloud Specialist)
      fallback: anthropic/claude-3-5-sonnet-20240620
      # Backup 2: Gemini 3 Pro (Cloud Backup)
      fallback_secondary: google/gemini-3-pro

    # 2. General Chat / Quick Tasks
    chat:
      # Primary: DeepSeek 1.3b (Local - Super Fast)
      provider: ollama
      model: deepseek-coder:1.3b
      api_base: http://host.docker.internal:11434
      # Backup 1: Z.ai Light (Cloud Fast)
      fallback: zai/light-v1
      # Backup 2: Gemini 3 Flash (Cloud Backup)
      fallback_secondary: google/gemini-3-flash
```

---

## 5. Installing the Essential Tools

Run the container once to initialize everything:

```bash
docker-compose up -d
```

Now, enter the execution shell:

```bash
docker exec -it openclaw_core /bin/bash
```

### A. Skill Manager (`clawhub`)
Inside the container, install the ClawHub CLI to manage skills.

```bash
# Install ClawHub CLI globally
npm install -g clawdhub

# Verify
clawdhub --version
```

### B. Security Tools (`skill-scanner`)
Install the security scanner to audit any skill you download.

```bash
# Install Skill Scanner
clawdhub install skill-scanner

# Configuring the pre-install hook
# This ensures EVERY skill is scanned before installation
export CLAW_INSTALL_HOOK="skill-scanner scan \$1"
```

---

## 6. Cool Tweaks (Premium) 🎩

Here are the "Cool Tweaks" to make your setup professional.

### Tweak #1: The "Visualizer" Dashboard
Install the `task-monitor` skill. It launches a small local web server so you can see what the agent is doing without staring at logs.

```bash
# Inside the container
clawdhub install task-monitor
```
*Access it at `http://localhost:3000` (Make sure to map port 3000:3000 in docker-compose if you use this).*

### Tweak #2: Persistent Infinite History
We added the volume `openclaw_history`. This means even if you destroy the container and rebuild it, your agent's CLI history (commands it ran) is saved. It learns from its own past command failures.

### Tweak #4: "Matrix Mode" Logs
Instead of just `docker logs`, use this alias on your Mac for a prettier view:

```bash
alias clawlogs="docker logs -f openclaw_core | grep -v 'ping' | grep -v 'heartbeat'"
```

### Tweak #5: "The Shield" (Hardened Security)
Inspired by `llm-docker`, enabling these options makes your container significantly harder to break out of. It drops all root capabilities not explicitly needed.

Add these lines to your `docker-compose.yml` under the `openclaw` service:

```yaml
    # Drop all capabilities by default (Paranoid Mode)
    cap_drop:
      - ALL
    # Prevent the agent from gaining new privileges (Sudo prevention)
    security_opt:
      - no-new-privileges:true
```

### Tweak #6: "God Mode" (Docker Control)
We included this line in the main `docker-compose.yml` but **commented it out by default**:
```yaml
      # - /var/run/docker.sock:/var/run/docker.sock
```
This allows your agent to use the `docker` command *inside* the container to control your Mac's Docker.
**To enable it:** Simply remove the `#` in front of that line in your yaml file.

---

## 7. How to Run

1.  **Start the Setup**:
    ```bash
    cd ~/clawfather
    docker-compose up -d
    ```

2.  **Talk to the Agent**:
    ```bash
    docker exec -it openclaw_core claw
    ```

3.  **Update Skills**:
    ```bash
    # From your Mac (because we mapped the folder!)
    cd ~/clawfather/skills
    # You can now edit skill code in VS Code on your Mac!
    ```

4.  **Security Audit**:
    Periodically run this inside the container:
    ```bash
    clawdhub run skill-scanner --all
    ```

---

## 8. Security Breakdown 🛡️

Here is a summary of the security layers we have activated:

### 1. The "Glass Wall" (Containerization)
By running in Docker, OpenClaw cannot access your Mac's filesystem unless you explicitly mount it (like `~/Projects`).

### 2. Kernel Hardening
*   `cap_drop: [ALL]`: We drop all Linux "capabilities". Even if an attacker gets root inside the container, they cannot mount drives, change network settings, or load kernel modules.
*   `security_opt: [no-new-privileges:true]`: Prevents the agent (or any process) from using `sudo` or gaining new privileges during runtime.

### 3. Agent Constraints
*   `SAFE_MODE=true`: A special flag for OpenClaw. It prevents the agent from running destructive commands like `rm -rf /` or overwriting critical system files.
*   `network_mode: bridge`: The agent is on a private network. It can only reach the internet and `host.docker.internal` (Ollama), not your other local devices.

### 4. Optional Paranoia (Not Enabled by Default)
If you want to go even further, you can:
*   **Read-Only Mounts**: Change volumes to `:ro` (e.g., `- ./skills:/home/node/.openclaw/skills:ro`). *Warning: You won't be able to install new skills via chat.*
*   **Resource Limits**: Add `cpus: 0.5` and `mem_limit: 4g` to prevent the agent from crashing your Mac.

---

## 9. Pro Tips (Day 2 Operations) 🚀

### 1. The "Claw" Alias
Don't type `docker exec...` every time. Add this to your `~/.zshrc`:
```bash
alias claw="docker exec -it openclaw_core claw"
```
Now you just type `claw` to enter the matrix.

### 2. Updating OpenClaw
To get the latest version of the gateway:
```bash
cd ~/clawfather
docker-compose pull
docker-compose up -d
```

### 3. Instant Backup
Since all your important data is in mapped folders, backing up is a one-liner:
```bash
zip -r claw_backup_$(date +%F).zip .openclaw/ config.yaml .env
```
