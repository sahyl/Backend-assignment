# Backend Assignment — README

**Live deployment:** [https://backend-assignment-1-rlyv.onrender.com](https://backend-assignment-1-rlyv.onrender.com)

This README is written to match the *Backend Engineer Hiring Assignment* and explains how to set up, run, test (Postman / curl), and dockerize the service. It also documents endpoints, rule logic, AI prompt design, and troubleshooting tips.

---

## Table of contents

1. Project summary
2. Features & endpoints
3. Environment variables
4. Local setup (dev & prod)
5. Testing with Postman (step-by-step)
6. Example requests (curl)
7. Rule layer & AI prompt (how scoring works)
8. Exporting results as CSV
9. Dockerizing (step-by-step guide)
10. docker-compose example
11. .dockerignore
12. Troubleshooting
13. Notes & credits

---

## 1) Project summary

This service accepts a product/offer (`POST /offer`) and a CSV of leads (`POST /leads/upload`), runs a two-layer scoring pipeline (Rule Layer + AI Layer) and exposes endpoints to run scoring (`POST /score`) and retrieve results (`GET /results`). It was implemented to satisfy the Backend Engineer Hiring Assignment.

Live base URL: `https://backend-assignment-1-rlyv.onrender.com`

---

## 2) Features & endpoints

**Base URL**

```
https://backend-assignment-1-rlyv.onrender.com
```

### Endpoints

* `POST /offer`

  * Accepts JSON with product/offer details.
  * Example body:

```json
{
  "name": "AI Outreach Automation",
  "value_props": ["24/7 outreach", "6x more meetings"],
  "ideal_use_cases": ["B2B SaaS mid-market"]
}
```

* `POST /leads/upload`

  * Accepts a CSV file (form-data `file`) with columns: `name,role,company,industry,location,linkedin_bio`.

* `POST /score`

  * Runs scoring pipeline on the most recently uploaded leads and stored offer (or on leads currently in memory/storage).

* `GET /results`

  * Returns JSON array of scored leads. Format follows the assignment:

```json
[
  {
    "name": "Ava Patel",
    "role": "Head of Growth",
    "company": "FlowMetrics",
    "intent": "High",
    "score": 85,
    "reasoning": "Fits ICP SaaS mid-market and role is decision maker."
  }
]
```

* (Optional) `GET /results/export` or similar

  * Returns CSV of results (if implemented as extra credit). Check your routes file to confirm the exact path.

---

## 3) Required environment variables

Create a `.env` file in the project root with the following variables (examples):

```
PORT=3000
GEMINI_API_KEY=sk-....
# If you use other AI providers, add relevant keys
```

**Render deployment note:** set the same environment variables in the Render dashboard for your service.

---

## 4) Local setup (dev & prod)

> Assumes Node.js (v18+) and npm installed. If your project uses pnpm/yarn, replace `npm` with the appropriate package manager.

1. Clone repository

```bash
git clone <https://github.com/sahyl/Backend-assignment>
cd <https://github.com/sahyl/Backend-assignment>
```

2. Install dependencies

```bash
npm install
```

3. Create `.env` using the template in the repo (if present) or using the variables above.

4. Development (if project uses `dev` script)

```bash
npm run dev
# or if ts-node is used for dev:
# npm run dev:ts
```

5. Production build & start (if TypeScript project)

```bash
npm run build
npm start
```

6. Confirm server is running at `http://localhost:3000` (or `PORT` in your .env)

---

## 5) Testing with Postman (step-by-step)

### A — Basic Postman setup

1. Open Postman → New → Request.
2. Set request method and URL (see endpoints above).
3. For JSON requests (`POST /offer`) set `Headers` → `Content-Type: application/json` and paste JSON body in the Body → raw tab.
4. For CSV upload (`POST /leads/upload`) select `Body` → `form-data`, add a key named `file` (type: File), and attach `leads.csv`.

### B — Example test flow

1. **Create an offer**

   * Method: `POST`
   * URL: `https://backend-assignment-1-rlyv.onrender.com/offer`
   * Headers: `Content-Type: application/json`
   * Body (raw JSON): same as example in section 2

2. **Upload leads CSV**

   * Method: `POST`
   * URL: `https://backend-assignment-1-rlyv.onrender.com/leads/upload`
   * Body: form-data → key `file` → upload `leads.csv` file.

   **Sample `leads.csv` content**

   ```csv
   name,role,company,industry,location,linkedin_bio
   Ava Patel,Head of Growth,FlowMetrics,SaaS,San Francisco,"Growth leader at FlowMetrics"
   John Doe,Engineer,AcmeCorp,Manufacturing,Chicago,"Senior engineer focused on supply chain"
   ```

3. **Run scoring**

   * Method: `POST`
   * URL: `https://backend-assignment-1-rlyv.onrender.com/score`
   * No body required (or check implementation if it accepts optional params)

4. **Get results**

   * Method: `GET`
   * URL: `https://backend-assignment-1-rlyv.onrender.com/results`

---

## 6) Example curl commands

**Create offer**

```bash
curl -X POST "https://backend-assignment-1-rlyv.onrender.com/offer" \
  -H "Content-Type: application/json" \
  -d '{"name":"AI Outreach Automation","value_props":["24/7 outreach"],"ideal_use_cases":["B2B SaaS mid-market"]}'
```

**Upload leads CSV**

```bash
curl -X POST "https://backend-assignment-1-rlyv.onrender.com/leads/upload" \
  -F "file=@leads.csv"
```

**Trigger scoring**

```bash
curl -X POST "https://backend-assignment-1-rlyv.onrender.com/score"
```

**Get results**

```bash
curl "https://backend-assignment-1-rlyv.onrender.com/results"
```

---

## 7) Rule layer & AI prompt (scoring details)

**Rule Layer (max 50 points)**

* Role relevance (up to 20):

  * decision maker → +20
  * influencer → +10
  * else → 0

* Industry match (up to 20):

  * exact ICP → +20
  * adjacent → +10
  * else → 0

* Data completeness (up to 10):

  * all fields present → +10

**AI Layer (max 50 points)**

* The service sends prospect + offer context to the AI provider and asks the model to classify intent (High/Medium/Low) and explain in 1–2 sentences.
* Mapping: High → 50, Medium → 30, Low → 10

**Final score** = `rule_score` + `ai_points` (0–100). The README documents the prompt used. Example prompt used in the project:

> "You are an expert sales analyst. Given the product offer and a prospect's details (name, role, company, industry, LinkedIn bio), classify the prospect's buying intent as High, Medium, or Low and provide a 1–2 sentence reasoning focused on fit to the product's ideal use cases and the prospect role. Return only the label and one short sentence explanation."

(Adjust the exact prompt in your code where the AI integration happens.)

---

## 8) Exporting results as CSV (extra credit)

If your project implements a CSV export endpoint, the README documents the path and how to call it. Example:

```
GET /results/export
```

It should return `Content-Type: text/csv` with a header row.

---



## 12) Troubleshooting

* **Missing AI key / 401 from OpenAI**: confirm `GEMINI_API_KEY` is set in `.env` and provided via `--env-file` or Render secrets.
* **CSV upload fails**: ensure you send `form-data` with key `file` and content type `text/csv`.

