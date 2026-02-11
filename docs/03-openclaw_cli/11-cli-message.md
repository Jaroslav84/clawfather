# openclaw message

Source: [docs.clawd.bot/cli/message](https://docs.clawd.bot/cli/message)

Single outbound command for **channel** messaging (WhatsApp, Telegram, Discord, Slack, Mattermost, Signal, iMessage, MS Teams). **Requires `--target`** for send/poll/read/etc.

## Usage

```bash
openclaw message <subcommand> [flags]
```

- `--channel` — required if more than one channel is configured. Values: `whatsapp|telegram|discord|googlechat|slack|mattermost|signal|imessage|msteams`
- `--target <dest>` — **required** for send/poll/read/etc. (target channel or user)
- `--targets <name>` — repeat; broadcast only
- `--json`, `--dry-run`, `--verbose`

## Target formats (`--target`)

| Channel | Format |
|---------|--------|
| WhatsApp | E.164 or group JID |
| Telegram | chat id or `@username` |
| Discord | `channel:<id>` or `user:<id>` (raw numeric = channel) |
| Google Chat | `spaces/<spaceId>` or `users/<userId>` |
| Slack | `channel:<id>` or `user:<id>` |
| Mattermost | `channel:<id>`, `user:<id>`, or `@username` |
| Signal | `+E.164`, `group:<id>`, `signal:+E.164`, `signal:group:<id>`, `username:<name>` |
| iMessage | handle, `chat_id:<id>`, `chat_guid:<guid>` |
| MS Teams | conversation id or `conversation:<id>` or `user:<aad-object-id>` |

## Core actions

- **send** — Required: `--target`, plus `--message` or `--media`. Optional: `--media`, `--reply-to`, `--thread-id`
- **poll** — Required: `--target`, `--poll-question`, `--poll-option` (repeat)
- **react** — Required: `--message-id`, `--target`. Optional: `--emoji`, `--remove`
- **read** — Required: `--target`
- **edit** — Required: `--message-id`, `--message`, `--target`
- **delete** — Required: `--message-id`, `--target`
- **pin** / **unpin** — Required: `--message-id`, `--target`
- **broadcast** — Required: `--targets` (repeat). Optional: `--message`, `--media`

## Examples

```bash
openclaw message send --channel discord --target channel:123 --message "hi" --reply-to 456
openclaw message send --channel msteams --target conversation:19:... --message "hi"
openclaw message poll --channel discord --target channel:123 --poll-question "Snack?" --poll-option Pizza --poll-option Sushi --poll-multi --poll-duration-hours 48
openclaw message react --channel slack --target C123 --message-id 456 --emoji "✅"
```
