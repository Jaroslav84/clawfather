# OpenClaw Cost Estimations

Running an autonomous agent involves API costs. This guide helps you choose the right balance between "intelligence" (reasoning) and "cost" (efficiency).

## ☁️ Supported Providers (Cloud Only)

OpenClaw supports any provider that offers an **OpenAI-compatible API** or has a direct driver.

```text
+----------------+--------------------+---------------------------------------+
| Provider       | Top Models         | Key Strength                          |
+----------------+--------------------+---------------------------------------+
| Anthropic      | Claude 3.5 Sonnet  | Best for coding & agent reliability.  |
| OpenAI         | GPT-4o, o1         | Excellent reasoning & tool calling.   |
| DeepSeek       | V3, R1             | Cost King. High logic for cents.      |
| Groq           | Llama 3.3 70B      | Speed King. Near-instant responses.   |
| OpenRouter     | All                | Aggregator (one key for everything).  |
+----------------+--------------------+---------------------------------------+
```

### ❓ Is Z.ai Supported?
**Yes.** Z.ai (Zhipu/GLM) provides an OpenAI-compatible API. 
*   **Results**: GLM-4 models are very capable (comparable to GPT-4).
*   **Verdict**: Good results for general automation, though Claude 3.5 Sonnet remains superior for complex Shell/CLI tasks.

---

## 💰 Cost Comparison (per 1M Tokens)

```text
+------------------+-------------------+-------+--------+---------------------+
| Tier             | Model             | Input | Output | Daily Vibe          |
+------------------+-------------------+-------+--------+---------------------+
| Intelligence     | Claude 3.5 Sonnet | $3.00 | $15.00 | Pro, reliable       |
| Standard         | GPT-4o / GLM-4    | $2.50 | $10.00 | Solid all-rounder   |
| Mid-Tier         | GLM-4 Air         | $0.20 | $1.10  | Performance / Price |
| Budget           | DeepSeek V3       | $0.14 | $0.28  | 95% cheaper         |
| Mini             | GPT-4o mini       | $0.15 | $0.60  | Simple tasks        |
+------------------+-------------------+-------+--------+---------------------+
```

---

## 🛠️ Cost Examples

### 1. Daily Automation (Low Usage)
*Task: Check emails, summarize news, sync 2-3 calendar events.*
- **Claude 3.5 Sonnet**: ~$0.05 - $0.10 / day
- **GLM-4 Air**: ~$0.01 - $0.02 / day
- **DeepSeek V3**: **<$0.01 / day**

### 2. Project: "AI Chatbot Website with Business Knowledge"
*Goal: Build a landing page + a chatbot backend that answers questions based on a provided `business_info.md` file.*

Estimated tokens: **800,000 to 1,200,000** (Reasoning + Code Gen + Debugging).

```text
+-----------------------+------------+------------+-------------+-------------+
| Development Phase     | Sonnet 3.5 | GLM-4 Air  | DeepSeek V3 | GLM-4 Pro   |
+-----------------------+------------+------------+-------------+-------------+
| 1. Architecture/Specs | $0.40      | $0.04      | $0.03       | $0.35       |
| 2. Frontend (HTML/JS) | $1.80      | $0.15      | $0.12       | $1.20       |
| 3. RAG/Knowledge Log. | $1.20      | $0.10      | $0.08       | $0.90       |
| 4. Final Debugging    | $0.80      | $0.08      | $0.05       | $0.60       |
+-----------------------+------------+------------+-------------+-------------+
| **ESTIMATED TOTAL**   | **~$4.20** | **~$0.37** | **~$0.28**  | **~$3.05**  |
+-----------------------+------------+------------+-------------+-------------+

---

## 👥 Real-World Community Reports

What do people actually spend? Based on reports from Reddit (r/OpenAI, r/ClaudeAI) and developer forums:

| Persona | Avg. Spend | Primary Model | Typical Use Case |
| :--- | :--- | :--- | :--- |
| **The Free Tier Hero** | **$0.00** | Llama 3 (Groq) | Simple Q&A, light summaries |
| **The Casual Assistant**| **<$2 / mo** | GPT-4o mini | Email checks, calendar sync |
| **The Daily Power User**| **$5 - $15 / mo** | GPT-4o / GLM-4 | 24/7 news tracking, web search |
| **The Pro Developer** | **$100 - $200 / mo**| Claude 3.5 Sonnet | Heavy coding & project builds |
| **The "Opus" Whale**   | **$500+ / mo** | Claude 3 Opus | Complex reasoning & long context |

### 💡 Community Tips for Saving
- **"The 90/10 Rule"**: Use **DeepSeek** or **GPT-4o mini** for 90% of tasks, and only swap in **Claude 3.5 Sonnet** for the final 10% of high-stakes coding.
- **Credit Sweeping**: Many users use OpenRouter to automatically route to the "cheapest provider" for the same model.
- **Conversation Reset**: Don't keep one conversation thread alive for weeks. Start a new one daily to keep token costs per turn at their minimum.
```

*Note: Claude 3.5 Sonnet usually builds it in fewer "turns," which might actually save you money vs. models that hallucinate and require more retries.*

---

## 🧐 "That seems too cheap! Is the math right?"

It feels low because we are used to **$20/mo subscriptions** (ChatGPT Plus) or **$100/hr humans). 

**Why API usage is different:**
1.  **Usage vs. Subscription**: You only pay for the milliseconds the "brain" is working. If an agent takes 30 seconds to write 200 lines of code, it only costs you for those ~2,000 output tokens and the surrounding "context."
2.  **Prompt Caching**: Modern providers (Anthropic, DeepSeek) now **cache** the parts of the prompt that don't change (like your project files). This can reduce costs by **up to 90%** for long conversations.
3.  **Stateless Billing**: You aren't paying for "downtime."

### ⚠️ When Costs Spiral (Watch out!)
The estimate of $4 can easily become **$40** if:
- **Infinite Loops**: The agent repeatedly tries a command that fails, reading the same logs over and over.
- **Massive Context**: You ask the agent to "Read the entire `node_modules` folder" (NEVER do this).
- **Long History**: If a conversation goes on for 100+ turns, every single turn becomes more expensive because the "brain" has to re-read the entire history.

---

## 🏆 Recommendations

- **Daily Tasks**: Use **DeepSeek V3**. It is effectively "free" compared to western models.
- **Coding & Architecture**: Use **Claude 3.5 Sonnet**. Fewer terminal errors, saves time.
- **Zero Cost**: Use **Groq** free tier (within rate limits).

---
> [!TIP]
> Use **OpenRouter** to switch between these models instantly without changing your code, just by swapping the model string in your config.
