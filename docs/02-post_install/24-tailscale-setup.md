# Tailscale Setup

Expose OpenClaw behind Tailscale for secure remote access from your devices.

## What it is

Tailscale creates a VPN mesh. Gateway can bind to `tailnet` or use `tailscale: serve` / `funnel` to expose endpoints. Install wizard offers: Off, Serve, Funnel.

**Best practice**: Use Serve for Tailnet-only; Funnel only if you need public access (higher risk).

## When to use it

* Access dashboard from phone
* Multi-device without port forwarding
* Secure remote gateway

## Prerequisites

* Tailscale installed on host
* Tailscale authenticated

## Instructions

### 1. Install wizard choice

During install, select Tailscale exposure: **Off** | **Serve** | **Funnel**.

### 2. Serve (Tailnet only)

```json
{
  "gateway": {
    "tailscale": {
      "mode": "serve",
      "resetOnExit": false
    }
  }
}
```

### 3. Funnel (public)

Use only if you need Public URL. Requires Tailscale auth; higher exposure.

### 4. Connect from another device

Install Tailscale on phone/tablet; join same Tailnet. Access via gateway Tailscale hostname.

## Docker note (Clawfather)

Tailscale typically runs on host. Container may need `--cap-add=NET_ADMIN` or similar for some modes. Check [Tailscale docs](https://docs.clawd.bot/gateway/tailscale).

## Links

* [Tailscale](https://docs.clawd.bot/gateway/tailscale)
* [Remote Gateway](https://docs.clawd.bot/gateway/remote-gateway-readme)
