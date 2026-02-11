# openclaw agent

Source: [docs.clawd.bot/cli/agent](https://docs.clawd.bot/cli/agent)

Run one agent turn via the Gateway (use `--local` for embedded). Use `--agent <id>` to target a configured agent.

## Required

- `--message <text>` — message to send to the agent (LLM)

## Options

- `--agent <id>` — target agent (e.g. `main`)
- `--to <dest>` — session key and optional delivery
- `--session-id <id>` — reuse existing session
- `--thinking off|minimal|low|medium|high|xhigh` — (GPT-5.2 + Codex models)
- `--verbose on|full|off`
- `--channel whatsapp|telegram|discord|slack|mattermost|signal|imessage|msteams`
- `--local` — embedded (no Gateway)
- `--deliver` — send reply through a provider
- `--json` — structured output
- `--timeout <seconds>`

## Examples

```bash
openclaw agent --to +15555550123 --message "status update" --deliver
openclaw agent --agent main --message "Summarize logs"
openclaw agent --session-id 1234 --message "Summarize inbox" --thinking medium
openclaw agent --agent ops --message "Generate report" --deliver --reply-channel slack --reply-to "#reports"
```

**Note:** For “send to LLM and get response” (e.g. smoke test), use `agent`, not `message send`. `message send` is for **channel** messaging and requires `--target`.
