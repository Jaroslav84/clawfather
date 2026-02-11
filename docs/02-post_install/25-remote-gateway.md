# Remote Gateway

Connect to a gateway running on another machine (e.g. home server) via `gateway.remote`.

## What it is

`gateway.remote` configures the URL and token for connecting to a remote gateway. Used when the CLI or app runs away from the gateway host.

**Best practice**: Use Tailscale or VPN for remote; never expose raw WebSocket to the internet without auth.

## When to use it

* CLI on laptop, gateway on server
* Multi-machine setups
* Centralized gateway

## Prerequisites

* Remote gateway URL (ws:// or wss://)
* Remote gateway token

## Instructions

```json
{
  "gateway": {
    "remote": {
      "url": "ws://gateway.tailnet:18789",
      "token": "remote-token"
    }
  }
}
```

For wss (TLS):

```json
{
  "gateway": {
    "remote": {
      "url": "wss://openclaw.example.com",
      "token": "remote-token"
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `gateway.remote.url` | WebSocket URL |
| `gateway.remote.token` | Auth token |

## Docker note (Clawfather)

Use when running `openclaw-cli` and pointing at a gateway elsewhere. Set in `openclaw.json` or env.

## Links

* [Remote Gateway](https://docs.clawd.bot/gateway/remote-gateway-readme)
* [Remote Access](https://docs.clawd.bot/gateway/remote)
