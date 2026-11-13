# Clay AI column: open-model fit scoring

**Use case:** Web research (Claygent)
**Model:** GPT 6 Luna (tested on 5 rows first; ~0.1 credits per row vs ~1.9 on the default model)
**Input:** `/Domain` column

## Prompt

```
Visit the website /Domain and research this company.
1. Does it build a product that uses AI language models? (Yes/No)
2. Does it mention using or supporting open-source or open-weight models such as Llama, Mistral, Qwen, or Hugging Face? (Yes/No/Unclear)
3. Rate its fit as a customer for an open-model inference provider (serverless API access to thousands of open-source models at a flat monthly price): High, Medium, or Low. High = builds products on AI models and uses or could benefit from open models. Low = only consults on or resells AI, or clearly relies on one closed provider.
Give one short sentence of evidence.
```

## Output fields

| Field | Values |
|---|---|
| Fit | High / Medium / Low |
| Uses open models | Yes / No / Unclear |
| Evidence | one sentence |

## Lessons

- Without fixed output fields, answers came back in mixed formats. Defining fields made every row sortable.
- Tier 1 = `Fit = High` AND `Uses open models = Yes`.
- The AI is strict about wording. A site listing a Qwen model without saying "open-source" came back as Unclear, so borderline cases get a human review.
