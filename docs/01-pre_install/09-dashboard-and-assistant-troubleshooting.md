# Dashboard & Assistant troubleshooting

## "Gateway token mismatch" / Dashboard won't connect

**Symptom:** Logs show `reason=token_mismatch` or "unauthorized: gateway token mismatch (open a tokenized dashboard URL or paste token in Control UI settings)".

**Cause:** The browser is connecting without the gateway token or with a wrong token (e.g. you opened `http://localhost:18789` instead of the URL that includes `?token=...`).

**Fix:**

1. **Open the dashboard with the token in the URL** (recommended):
   ```bash
   # Get the current gateway token from the container
   docker exec openclaw_core node dist/index.js config get gateway.auth.token
   ```
   Then open in your browser:
   ```
   http://localhost:18789/?token=<paste-the-token-here>
   ```
   The installer also prints this URL at the end (Verification Summary → Dashboard URL). Always use that full URL or the one from the Phase 4 step.

2. **Or paste the token in the Control UI:** If the dashboard loads but WebSocket fails, open Settings in the Control UI and paste the gateway token there.

---

## Assistant says "All models failed" / no reply in chat

**Symptom:** Smoke test (Phase 10) may show "OK", but in the Dashboard the Assistant never replies or logs show "Embedded agent failed before reply: All models failed".

**Cause:** The agent is configured with a **primary model + fallbacks**. When the primary fails, OpenClaw tries each fallback. Common cases:

| Error | Meaning |
|-------|--------|
| `No API key found for provider "ollama"` | OpenClaw requires a placeholder to enable Ollama. The installer sets `models.providers.ollama.apiKey` to `ollama-local`. If you configured Ollama by hand, run: `config set models.providers.ollama.apiKey "ollama-local"` (or set env `OLLAMA_API_KEY=ollama-local`). |
| `Your credit balance is too low` (Anthropic) | No credits on Anthropic; add credits or remove Anthropic from fallbacks. |
| `429` / `RESOURCE_EXHAUSTED` (Gemini) | Free-tier quota exceeded; wait or enable billing, or remove Gemini from fallbacks. |

**Fix (use only local Ollama for now):**

1. Set the primary model to Ollama only and **clear fallbacks** so the agent doesn’t try Anthropic/Gemini:
   ```bash
   docker exec openclaw_core node dist/index.js config set agents.defaults.model --json '{"primary":"ollama/glm-4.7-flash","fallbacks":[]}'
   ```
2. Restart the gateway so config is applied:
   ```bash
   docker exec openclaw_core node dist/index.js gateway stop
   docker exec -d openclaw_core sh -c "node dist/index.js gateway > /home/node/.openclaw/logs/gateway.log 2>&1"
   ```
3. Ensure Ollama is running on the host and reachable from the container (e.g. `http://host.docker.internal:11434`). Your `config.yaml` is bridged to `models.providers.ollama.baseUrl` during install; that base URL must be correct for the container.

If you want to keep cloud fallbacks later, fix billing/quotas for those providers; until then, using only Ollama avoids "All models failed".

---

## Quick reference

- **Dashboard URL with token:** `http://localhost:18789/?token=<gateway-token>`
- **Get gateway token:** `docker exec openclaw_core node dist/index.js config get gateway.auth.token`
- **Ollama placeholder (fix "No API key for ollama"):** `docker exec openclaw_core node dist/index.js config set models.providers.ollama.apiKey "ollama-local"`
- **Set Ollama-only model (no fallbacks):** `docker exec openclaw_core node dist/index.js config set agents.defaults.model --json '{"primary":"ollama/deepseek-coder:6.7b","fallbacks":[]}'`
- **Restart gateway (in container):** stop then `docker exec -d openclaw_core sh -c "node dist/index.js gateway > /home/node/.openclaw/logs/gateway.log 2>&1"`
