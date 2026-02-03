# Skills Requiring API Keys

Below are the skills in `skills/` that need keys or setup.

```text
+-----------------+-----+---------------------------+---------------------------+
| Skill           | Req | Variables                 | Notes                     |
+-----------------+-----+---------------------------+---------------------------+
| adhd-asst       | NO  | -                         | Needs soul-config         |
| ai-ci           | YES | GITHUB_TOKEN              | Actions setup             |
| alpha-fnd       | YES | X402_PRIVATE_KEY          | Poly alpha                |
| apple-mus       | YES | -                         | App perms                 |
| apple-nts       | YES | -                         | App perms                 |
| browser-u       | YES | BROWSER_USE_API_KEY       | Ctx config                |
| caldav          | NO  | -                         | vdirsyncer/khal           |
| clawnews        | YES | -                         | RSS config                |
| crypto-px       | NO  | COINGECKO_API_KEY         | Opt. speed                |
| exa-srch        | YES | EXA_API_KEY               | From exa.ai               |
| fin-news        | YES | -                         | Region config             |
| firefll         | YES | FIRECRAWLER_API_KEY       | firecrawler.dev           |
| founder         | NO  | -                         | Mindset coach             |
| github          | YES | GITHUB_TOKEN              | gh CLI auth               |
| gh-kb           | YES | GITHUB_TOKEN, KB_PATH     | Local KB path             |
| gh-ment         | YES | GITHUB_TOKEN              | Mention track             |
| gh-pr           | YES | GITHUB_TOKEN              | PR preview                |
| glab-mgr        | YES | GITLAB_TOKEN              | GL API access             |
| goog-srch       | YES | GOOGLE_API_KEY, CSE_ID    | Custom Search             |
| news-sum        | YES | OPENAI_API_KEY            | AI summaries              |
| nextcloud       | YES | NC_URL, NC_TOKEN          | Incl. User/Auth           |
| onchain         | YES | BINANCE_KEY, etc.         | Exchange keys             |
| peekaboo        | YES | -                         | Screen/Access             |
| penfield        | NO  | -                         | Persistence               |
| perplex         | YES | PERPLEXITY_API_KEY        | perplexity.ai             |
| poly-agt        | YES | POLYMARKET_KEY            | Polygon PK                |
| poly-odds       | NO  | -                         | No key needed             |
| roarin          | YES | ROARIN_API_KEY            | From roarin.ai            |
| simmer          | YES | SIMMER_API_KEY            | Simmer dash               |
| scanner         | NO  | -                         | Malware audit             |
| skillvet        | YES | ANTHROPIC_KEY             | Bot config                |
| skillz          | YES | SKILLZ_PRIVATE_KEY        | Wallet PK                 |
| ha-home         | YES | HA_TOKEN                  | HA Long Token             |
| stock-an        | YES | AUTH_TOKEN                | Data provider             |
| tavily          | YES | TAVILY_API_KEY            | From tavily.com           |
| things          | YES | THINGS_AUTH_TOKEN         | Automation                |
| trello          | YES | TRELLO_KEY, TOKEN         | Trello PowerUp            |
| unifai          | YES | UNIFAI_API_KEY            | Trading access            |
| youtube         | YES | TRANSCRIPT_KEY            | Transcript API            |
| yt-dl           | NO  | -                         | Needs yt-dlp              |
+-----------------+-----+---------------------------+---------------------------+
```

---
> [!TIP]
> Set keys in `.env` or `.zshrc`. See [PREPARATION.md](../OPENCLAW_PREPARATION.md).
