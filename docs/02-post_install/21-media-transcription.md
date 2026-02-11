# Media & Transcription

Enable audio and video transcription. Agent can process voice notes and video content via Whisper/Gemini.

## What it is

`tools.media.audio` and `tools.media.video` enable transcription of inbound media. Uses OpenAI Whisper or Gemini for video.

**Best practice**: Set `maxBytes` and `timeoutSeconds`; use cheaper models for high volume.

## When to use it

* Voice notes (WhatsApp, Telegram)
* Video understanding
* Accessibility

## Prerequisites

* API keys for transcription providers

## Instructions

```json
{
  "tools": {
    "media": {
      "audio": {
        "enabled": true,
        "maxBytes": 20971520,
        "models": [{ "provider": "openai", "model": "gpt-4o-mini-transcribe" }],
        "timeoutSeconds": 120
      },
      "video": {
        "enabled": true,
        "maxBytes": 52428800,
        "models": [{ "provider": "google", "model": "gemini-3-flash-preview" }]
      }
    }
  }
}
```

## Configuration reference

| Path | Purpose |
|------|---------|
| `tools.media.audio.enabled` | Enable audio transcription |
| `tools.media.audio.maxBytes` | Max file size |
| `tools.media.video.enabled` | Enable video |

## Docker note (Clawfather)

Requires API keys in `.env` (OPENAI, GEMINI).

## Links

* [Configuration Examples](https://docs.clawd.bot/gateway/configuration-examples)
* [Audio and Voice Notes](https://docs.clawd.bot/nodes/audio)
