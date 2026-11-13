# GTM Engineering Project: From Warehouse to Pipeline

An end-to-end go-to-market pipeline built on free tiers to learn how modern sales teams find, qualify and work accounts:

**BigQuery → Hightouch → Clay → HubSpot**

The scenario: building a prospect list and pipeline for an open-model inference platform (serverless API access to open-source AI models at a flat monthly price), targeting US AI startups.

---

## Architecture

```
 ┌────────────┐    ┌────────────┐    ┌──────────────────────────┐    ┌──────────────────┐
 │  BigQuery  │ →  │ Hightouch  │ →  │           Clay           │ →  │     HubSpot      │
 │  segment   │    │ reverse ETL│    │ source · enrich · score  │    │ pipeline · report│
 │  with SQL  │    │  to Sheets │    │ find people · AI openers │    │                  │
 └────────────┘    └────────────┘    └──────────────────────────┘    └──────────────────┘
```

| Stage | Tool | What it does |
|---|---|---|
| 1. Model the data | BigQuery | SQL segments customers into value tiers |
| 2. Move the data | Hightouch | Reverse ETL syncs the segment out to business tools |
| 3. Build the list | Clay | Finds ICP companies, enriches them, AI-scores fit, finds decision makers and verified emails, writes openers |
| 4. Work the pipeline | HubSpot | Contacts and companies, staged deals, next steps, weighted forecast |

---

## 1. BigQuery: segment customers by value

- Used Google's public synthetic dataset `bigquery-public-data.thelook_ecommerce`.
- Joined users to order items, excluded cancelled and returned items, and calculated each customer's total orders and spend.
- Labeled customers **High** (≥ $300), **Medium** (≥ $100) or **Low** with a `CASE` statement.
- Result: **66,274 customers**: 5,427 High (8%), 22,343 Medium, 38,504 Low.
- Saved as a reusable view: `gtm_models.customer_value_tiers`.

SQL: [`sql/customer_value_tiers.sql`](sql/customer_value_tiers.sql)

## 2. Hightouch: reverse ETL

- Connected BigQuery as a source with a least-privilege service account.
- Built a model on the view with `user_id` as the primary key.
- Synced to a Google Sheets destination in **Mirror** mode: **66,274 rows in ~1 minute, 0 rejected**.
- Concepts: reverse ETL, primary keys, change detection, sync modes (Append / Mirror / Snapshot), Basic vs Lightning sync engines.

## 3. Clay: source, enrich, score and personalize

**Source.** Searched Clay's company database (48M+ companies) with ICP filters:
Software Development · 11–200 employees · United States · description mentions LLM / generative AI / AI agents.
→ ~2,074 matches; saved the top 25.

**Enrich.** Added headcount, founding year and LinkedIn followers.

**AI fit scoring.** A custom AI column visits each company's website and returns structured fields:
`Fit` (High / Medium / Low) · `Uses open models` (Yes / No / Unclear) · `Evidence`.
Prompt: [`prompts/clay_fit_scoring.md`](prompts/clay_fit_scoring.md)

- **Cost:** testing a smaller model on 5 rows before the full run cut the cost of this step from ~1.9 to ~0.1 credits per row (~95%).
- **Structured outputs:** the first run returned inconsistent formats, so I locked the output to fixed fields for sorting and filtering.
- **Caught a competitor:** one company scored Low because it runs its own inference service. A keyword search alone would have put it on the call list.
- **Checked the data:** one record had a Linktree link instead of the company site. After fixing it and re-running, the company dropped from Tier 1 to Tier 2.

**Tiering.** Tier 1 = High fit **and** clear evidence of open-model use → **7 accounts**.

**Find people.** Searched for CTO, Head of AI/ML, VP Engineering, Founder and CEO at Tier 1 accounts (2 per company) and filtered out non-decision-maker matches.

**Verified emails.** Clay's waterfall tried providers in sequence with a validation step after each. Once one provider returned a verified email, the rest were skipped, so cost was incurred only on the first verified match.

**AI openers.** A content-generation column writes a two-sentence opener per contact, using the LinkedIn summary plus the company's open-model evidence pulled from the account table.
Prompt and iteration notes: [`prompts/clay_opener.md`](prompts/clay_opener.md)

## 4. HubSpot: pipeline and forecast

- Cleaned the Clay export to HubSpot field names and derived **Company Domain Name** from email domains so contacts link to companies automatically.
- Multi-object import: **13 rows → 20 records (13 contacts + 7 companies), 13 associations, 0 errors**.
- Created a custom property for the AI opener and a segment for the Tier 1 list.
- Built a **simulated** 4-deal pipeline across stages: **$120,000 total, $50,400 weighted** (amount × stage probability).
- Logged a note and a dated next-step task on every deal, so no open deal has "no upcoming" activity.
- Built a sales-forecast-by-stage report (filtered by close date) on a pipeline dashboard.

---

## What I learned

- **Data quality beats volume.** Small input errors, like a wrong domain, change the output, so AI results need spot checks.
- **Cost is a design choice.** Model selection, waterfalls and testing on a few rows first keep enrichment cheap.
- **Structure enables action.** Fixed output fields and clean CRM properties are what make a list sortable, filterable and forecastable.
- **Forecast on weighted pipeline,** and set stage probabilities from real historical win rates, not CRM defaults.

## Notes

- All deals, amounts and activity notes are **simulated** for practice.
- No personal contact data is included in this repository.

## Screenshots

See [`screenshots/`](screenshots/).
