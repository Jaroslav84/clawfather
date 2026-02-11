# openclaw devices

Source: [docs.clawd.bot/cli/devices](https://docs.clawd.bot/cli/devices)

Manage device pairing requests and device-scoped tokens.

## Commands

### devices list

List pending pairing requests and paired devices.

```bash
openclaw devices list
openclaw devices list --json
```

### devices approve <requestId>

Approve a pending device pairing request.

```bash
openclaw devices approve <requestId>
```

### devices reject <requestId>

Reject a pending device pairing request.

```bash
openclaw devices reject <requestId>
```

### devices rotate

Rotate a device token for a role (optionally update scopes).

```bash
openclaw devices rotate --device <deviceId> --role operator --scope operator.read --scope operator.write
```

### devices revoke

Revoke a device token for a role.

```bash
openclaw devices revoke --device <deviceId> --role node
```

## Common options

- `--url <url>` — Gateway WebSocket URL
- `--token <token>`, `--password <password>`
- `--timeout <ms>`
- `--json` — JSON output (recommended for scripting)

**Note:** Token rotation returns a new token (sensitive). These commands require `operator.pairing` (or `operator.admin`) scope.
