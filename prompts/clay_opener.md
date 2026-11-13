# Clay AI column: personalized opener

**Use case:** Create or modify content (no web browsing)
**Model:** GPT 6 Luna (~0.1 credits per row)
**Inputs:** Full Name, Job Title, Company, LinkedIn summary (optional), company Evidence pulled from the account table

## Final prompt

```
Write a 2-sentence cold email opener to /Full Name, who is /Job Title at /Company.
Background on them: /Summary
How their company uses AI models: /Evidence
I sell Featherless, a serverless inference platform: one OpenAI-compatible API for 30,000+ open-source models (Llama, Qwen, Mistral and more), at a flat monthly price, with no GPUs to manage.
Rules:
- Sentence 1 refers to something specific about them or their company from the background provided.
- Sentence 2 connects it to one benefit of Featherless: cost predictability, model choice, or no GPU management.
- Under 50 words total.
- Plain and conversational. No hype, no exclamation marks.
- Do not invent facts. Use only the information provided.
- Return only the opener text.
- Never use these phrases: "stood out to me", "your vision", "I came across", "impressive", "building in the AI space".
- Never open with a compliment. Open with a specific fact about what their company does or ships.
- If the background is thin, mention the company's actual product by name instead of praising the person.
- When the company evidence mentions open-source or open-weight models, use that fact in sentence 1.
```

## Iterations

1. **v1:** Specific in places, but leaned on stock phrases ("Your vision...", "...stood out to me"), and one opener was generic.
2. **v2:** Banned clichés and required opening with a fact. Better, but thin profiles still produced weak lines.
3. **v3:** Pulled each company's open-model evidence from the account table. Every opener now led with a real, relevant fact (for example, a company already publishing fine-tuned open-weight models).
4. Made the LinkedIn summary an optional input so rows with blank profiles still ran.

**Process:** test on 5 rows → read the output → tighten → re-test → run the full list.
