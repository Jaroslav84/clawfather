# Local macOS vs. Docker Compatibility

This guide breaks down every skill and whether it can run inside a standard Docker container (Linux) or if it requires a native macOS host.

**OK**: Can run in Docker.
**NOT OK**: Requires a native macOS host (for apps, TCC permissions, or macOS APIs).

```text
+----------------------+-----------+-----------------------------------+
| Skill Name           | Docker    | Requirement / Reason              |
+----------------------+-----------+-----------------------------------+
| ai-skill-scanner     | OK        | Logic-based                       |
| hivefence            | OK        | Security logic                    |
| security-hardening   | OK        | System audit                      |
| skill-scanner        | OK        | Malware audit                     |
+----------------------+-----------+-----------------------------------+
| founder-coach        | OK        | LLM / Chat                        |
+----------------------+-----------+-----------------------------------+
| code-roaster         | OK        | CLI / Logic                       |
| coding-agent-3nd     | OK        | CLI / Source                      |
| roast-gen            | OK        | CLI / Logic                       |
+----------------------+-----------+-----------------------------------+
| crypto-price         | OK        | API / Network                     |
| skillzmarket         | OK        | API / Wallet                      |
| stock-analysis       | OK        | API / Finance                     |
+----------------------+-----------+-----------------------------------+
| accli                | NOT OK    | Needs macOS CLI auth              |
| apple-mail           | NOT OK    | Needs Mail.app                    |
| mail-search-safe     | NOT OK    | Needs Mail.app                    |
| apple-music          | NOT OK    | Needs Music.app                   |
| apple-photos         | NOT OK    | Needs Photos.app                  |
| apple-reminders      | NOT OK    | Needs Reminders.app               |
| homebrew             | NOT OK    | Needs macOS Brew                  |
| mac-tts              | NOT OK    | Needs macOS 'say'                 |
| peekaboo             | NOT OK    | Needs Screen Recording            |
+----------------------+-----------+-----------------------------------+
| agents-manager       | OK        | Logic                             |
| agnxi-search         | OK        | API                               |
| auto-updater         | OK        | CLI / Network                     |
| clawhub-sync         | OK        | CLI / API                         |
| skillcraft           | OK        | Logic                             |
| skills-search        | OK        | Logic                             |
| skillvet             | OK        | Logic                             |
| task-monitor         | OK        | Logic                             |
+----------------------+-----------+-----------------------------------+
| openclaw-mcp         | OK        | Protocol / Logic                  |
+----------------------+-----------+-----------------------------------+
| persistent-memory    | OK        | Data / JSON                       |
| penfield             | OK        | Data / Logic                      |
+----------------------+-----------+-----------------------------------+
| clawnews             | OK        | RSS / API                         |
| finance-news         | OK        | RSS / API                         |
| hn / hn-digest       | OK        | API / Network                     |
| news-aggregator      | OK        | API / Network                     |
| news-summary         | OK        | API / Network                     |
+----------------------+-----------+-----------------------------------+
| caldav-calendar      | OK        | CLI (Linux compat)                |
| nextcloud            | OK        | API (WebDAV/CalDAV)               |
+----------------------+-----------+-----------------------------------+
| better-polymarket    | OK        | API / Scraping                    |
| pm-odds              | OK        | API / Scraping                    |
| polyclaw             | OK        | API / Logic                       |
| polymarket (all)     | OK        | API / Trader logic                |
| unifai-suite         | OK        | API / Trading                     |
+----------------------+-----------+-----------------------------------+
| adhd-assistant       | OK        | Logic / Chat                      |
| personas             | OK        | Logic / Chat                      |
| proactive-agent      | OK        | Logic                             |
| procrastination      | OK        | Logic                             |
+----------------------+-----------+-----------------------------------+
| moltbot-ha           | OK        | Network / Token                   |
+----------------------+-----------+-----------------------------------+
| ai-ci                | OK        | API / Git                         |
| gitclaw              | OK        | CLI / Git                         |
| github (all)         | OK        | API / Git                         |
| gitlab (all)         | OK        | API / Git                         |
| backup-optimized     | OK        | CLI / File                        |
+----------------------+-----------+-----------------------------------+
| browser-use          | OK        | Network / Headless                |
| browser-use-api      | OK        | Network / API                     |
+----------------------+-----------+-----------------------------------+
| youtube (all)        | OK        | API / yt-dlp                      |
| yt-video-down        | OK        | CLI / yt-dlp                      |
+----------------------+-----------+-----------------------------------+
```

---

## 🚫 Host-Specific Limitations

In Docker/Linux, you lose access to these **macOS-exclusive** capabilities:

- **Native App Control**: No integration with Apple Mail, Notes, Music, or Reminders.
- **Screen Vision (Peekaboo)**: The agent cannot take screenshots or automate the desktop.
- **System Audio**: Native high-quality voices (`say`) and Microphone access are restricted.
- **Branded CLI**: Certain macOS-specific CLI tools (like `openclaw` app hooks) won't work.

**💡 Tip**: Use a **Hybrid Setup** (Remote Gateway + Local Mac Node) to get the best of both worlds.
