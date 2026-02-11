# Discovery (mDNS)

Advertise or discover gateways on the local network via mDNS.

## What it is

`discovery.mdns.mode` controls mDNS behavior: `minimal` (default), `full`, or `off`. Enables discovery of gateways on the LAN.

**Best practice**: Use `minimal` or `off` for privacy; `full` only when discovery is needed.

## When to use it

* Auto-discover gateways on LAN
* Multi-gateway environments
* Reduce manual config

## Prerequisites

* Gateway on a network that supports mDNS

## Instructions

```json
{
  "discovery": {
    "mdns": {
      "mode": "minimal"
    }
  }
}
```

| Mode | Behavior |
|------|----------|
| `minimal` | Default; limited advertisement |
| `full` | Full discovery |
| `off` | Disabled |

## Configuration reference

| Path | Purpose |
|------|---------|
| `discovery.mdns.mode` | `minimal` \| `full` \| `off` |

## Docker note (Clawfather)

Container network may affect mDNS. Bridge network typically allows host mDNS; verify in your setup.

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
