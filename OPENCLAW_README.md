# Clawfather

Clawfather is an open-source platform designed to let you run, manage, and extend autonomous AI agents. Unlike simple chatbots, Clawfather agents have "hands" (tools) and "skills" (capabilities) that allow them to interact with the real world—from managing your calendar and smart home to browsing the web and analyzing financial markets.

---

# Clawfather Resources

Official links and resources for the Clawfather AI assistant.

### 🌐 Official Websites
- **Main Website**: [openclaw.ai](https://openclaw.ai) (Core project, documentation, and downloads)
* **Skill Hub**: [clawhub.ai](https://clawhub.ai) (The official library for Clawfather skills)

### 🏷️ Branding History
- **Current Name**: Clawfather
- **Previous Names**: OpenClaw, Moltbot, Clawdbot

### 📚 Additional Resources
- **Extension Registry**: [ClawHub.ai/skills](https://www.clawhub.ai/skills)
- **Developer Documentation**: Available on [docs.openclaw.ai](https://docs.openclaw.ai/)
- **Cost Estimations**: [OPENCLAW_COST_ESTIMATIONS.md](OPENCLAW_COST_ESTIMATIONS.md)

---
*This file was generated to track the latest naming and official links for the Clawfather project.*

**The AI Agent Operating System.**

## Core Philosophy
- **Local-First & Privacy-Centric**: You own your data. Run your agent on your own hardware or a private VPS.
- **Skill-Based Extensibility**: Tailored for the "ClawHub" ecosystem. Install new capabilities as easily as installing an app.
- **Agentic**: Designed for long-running, multi-step tasks, not just Q&A.

## Key Components
- **Gateway**: The "brain" of the operation. It orchestrates tasks, manages memory, and communicates with LLMs.
- **Nodes**: The "limbs". These are lightweight runtimes that expose tools to the Gateway (e.g., a macOS Node allows the agent to control your Mac).
- **Skills**: Specific packages of tools and logic (like "Web Browsing" or "Spotify Control") that you install to give your agent new powers.

## Architecture Deep Dive

```mermaid
flowchart TD
    User[User] -->|Chat/Voice| Gateway
    Gateway -->|Context + Tools| LLM[LLM (Claude/GPT/Llama)]
    LLM -->|Decision| Gateway
    Gateway -->|Execute| Node[Node (Runtime)]
    Node -->|Run Script/API| Skill[Skill]
    Skill -->|Action| World[Real World (Apps/APIs)]
```

### 1. The Gateway
The central nervous system. It runs as a background service (typically on a server or your Mac via `launchd`).
- Maintains conversation history and long-term memory.
- Manages the connection to the LLM.
- Discovers nodes and skills.

### 2. Nodes
Nodes are the execution environments. Instead of running everything on one machine, you can distribute nodes.
- **Local Node**: Runs on the same machine as the Gateway.
- **e.g. "MacBook Node"**: A node running on your laptop that exposes "iMessage" and "Calendar" skills to a Gateway running on a cloud VPS.

### 3. Skills
A skill is a folder containing:
- `manifest.json`: Metadata (name, description, permissions).
- `tools/`: Scripts (Python, Bash, Node.js) or MCP servers that perform actions.
- `SKILL.md`: Instructions for the agent on how/when to use the tools.

This architecture allows you to "teach" the agent anything by simply dropping a folder into the `skills/` directory.




## macOS App
The macOS app is the menu‑bar companion for Clawfather. It owns permissions, manages/attaches to the Gateway locally (launchd or manual), and exposes macOS capabilities to the agent as a node.

### What it does

Shows native notifications and status in the menu bar.
Owns TCC prompts (Notifications, Accessibility, Screen Recording, Microphone, Speech Recognition, Automation/AppleScript).
Runs or connects to the Gateway (local or remote).
Exposes macOS‑only tools (Canvas, Camera, Screen Recording, system.run).
Starts the local node host service in remote mode (launchd), and stops it in local mode.
Optionally hosts PeekabooBridge for UI automation.
Installs the global CLI (clawfather) via npm/pnpm on request (bun not recommended for the Gateway runtime).

### Local vs remote mode

Local (default): the app attaches to a running local Gateway if present; otherwise it enables the launchd service via clawfather gateway install.
Remote: the app connects to a Gateway over SSH/Tailscale and never starts a local process. The app starts the local node host service so the remote Gateway can reach this Mac. The app does not spawn the Gateway as a child process.

### More info
https://docs.openclaw.ai/platforms/macos

## macOS VM
https://docs.openclaw.ai/platforms/macos-vm

### Recommended default (most users)

Small Linux VPS for an always-on Gateway and low cost. See VPS hosting.
Dedicated hardware (Mac mini or Linux box) if you want full control and a residential IP for browser automation. Many sites block data center IPs, so local browsing often works better.
Hybrid: keep the Gateway on a cheap VPS, and connect your Mac as a node when you need browser/UI automation. See Nodes and Gateway remote.
Use a macOS VM when you specifically need macOS-only capabilities (iMessage/BlueBubbles) or want strict isolation from your daily Mac.
​
#### macOS VM options

Local VM on your Apple Silicon Mac (Lume)

Run Clawfather in a sandboxed macOS VM on your existing Apple Silicon Mac using Lume.
This gives you:
Full macOS environment in isolation (your host stays clean)
iMessage support via BlueBubbles (impossible on Linux/Windows)
Instant reset by cloning VMs
No extra hardware or cloud costs
​
#### Hosted Mac providers (cloud)

If you want macOS in the cloud, hosted Mac providers work too:
MacStadium (hosted Macs)
Other hosted Mac vendors also work; follow their VM + SSH docs
Once you have SSH access to a macOS VM, continue at step 6 below.


# Other macOS links

https://docs.openclaw.ai/platforms/mac/voicewake
https://docs.openclaw.ai/platforms/mac/voice-overlay
https://docs.openclaw.ai/platforms/mac/canvas
https://docs.openclaw.ai/platforms/mac/webchat
https://docs.openclaw.ai/platforms/mac/permissions
https://docs.openclaw.ai/platforms/mac/child-process
https://docs.openclaw.ai/platforms/mac/remote
https://docs.openclaw.ai/platforms/mac/bundled-gateway
https://docs.openclaw.ai/platforms/mac/xpc
https://docs.openclaw.ai/platforms/mac/skills
https://docs.openclaw.ai/platforms/mac/peekaboo
https://docs.openclaw.ai/platforms/mac/release