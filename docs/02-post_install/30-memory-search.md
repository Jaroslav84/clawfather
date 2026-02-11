# Memory Search

Enable semantic search over agent memory. Uses embeddings (e.g. Gemini) to find relevant context.

## What it is

`agents.defaults.memorySearch` configures the embedding provider and optional `extraPaths` for knowledge base expansion. Enables RAG-style retrieval.

**Best practice**: Use for large knowledge bases; keep `extraPaths` scoped to non-sensitive docs.

## When to use it

* Long-running projects
* Team docs, shared notes
* Knowledge base retrieval

## Prerequisites

* Embedding provider (e.g. Gemini) and API key
* Optional: extra paths for indexing

## Instructions

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "gemini",
        "model": "gemini-embedding-001",
        "remote": {
          "apiKey": "${GEMINI_API_KEY}"
        },
        "extraPaths": ["../team-docs", "/srv/shared-notes"]
      }
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `agents.defaults.memorySearch.provider` | Embedding provider |
| `agents.defaults.memorySearch.model` | Embedding model |
| `agents.defaults.memorySearch.extraPaths` | Additional paths to index |

## Docker note (Clawfather)

`extraPaths` must be paths inside the container. Mount host dirs if needed.

## Links

* [Configuration Examples](https://docs.clawd.bot/gateway/configuration-examples)
* [Configuration](https://docs.clawd.bot/gateway/configuration)
