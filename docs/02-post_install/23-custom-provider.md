# Custom Provider

Add custom LLM providers (e.g. LiteLLM proxy, local API) via `models.providers`.

## What it is

`models.providers.<name>` lets you add providers with `baseUrl`, `apiKey`, and `models[]`. Use for self-hosted or proxy endpoints.

**Best practice**: Use env vars for API keys; set `models.mode: "merge"` to add alongside defaults.

## When to use it

* LiteLLM or local proxy
* Self-hosted ollama/other
* Vendor-specific endpoints

## Prerequisites

* Provider URL and API key (if required)

## Instructions

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "custom-proxy": {
        "baseUrl": "http://localhost:4000/v1",
        "apiKey": "${LITELLM_KEY}",
        "api": "openai-responses",
        "models": [{
          "id": "llama-3.1-8b",
          "name": "Llama 3.1 8B",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 128000,
          "maxTokens": 32000
        }]
      }
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `models.mode` | `merge` \| `replace` |
| `models.providers.<name>.baseUrl` | API base URL |
| `models.providers.<name>.apiKey` | Key (or `${VAR}`) |
| `models.providers.<name>.api` | `openai-responses` \| `anthropic-messages` etc. |

## Docker note (Clawfather)

Use `http://host.docker.internal` for local providers (e.g. ollama).

## Links

* [Configuration](https://docs.clawd.bot/gateway/configuration)
* [Providers](https://docs.clawd.bot/providers)
