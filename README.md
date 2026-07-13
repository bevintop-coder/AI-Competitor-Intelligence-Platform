# 🌟 AI Competitor Intelligence Platform (ACIP)

An enterprise-grade, autonomous competitor monitoring platform that continuously tracks competitor websites, detects **semantic content changes** using ONNX-powered sentence embeddings, evaluates business impact through a resilient cloud/local AI inference pipeline, and delivers real-time notifications via Slack, Email, Notion, and Airtable.

Designed with a **self-healing architecture**, ACIP automatically falls back between AI models to ensure uninterrupted analysis while operating efficiently within a **512 MB RAM footprint**.

---

# 🚀 Key Highlights

- 🔍 Intelligent competitor website monitoring
- 🧠 Semantic change detection using ONNX sentence embeddings
- 🤖 AI-powered business impact analysis
- 📊 Threat scoring and change classification
- 📧 Multi-channel notifications
- 🌐 Chrome Extension for one-click competitor registration
- ⚡ Self-healing cloud → local → heuristic inference pipeline
- 🐳 Docker & Railway deployment support
- 💾 Lightweight SQLite database
- 📈 Interactive React dashboard

---

# 🏗️ System Architecture

```text
                    Competitor Website
                           │
                           ▼
        ┌────────────────────────────────────┐
        │  Intelligent Web Scraper           │
        │  Axios • Cheerio • Puppeteer       │
        └────────────────────────────────────┘
                           │
                           ▼
        ┌────────────────────────────────────┐
        │ Semantic Change Detection          │
        │ ONNX Sentence Embeddings           │
        └────────────────────────────────────┘
                           │
                Cosine Similarity Check
                           │
                           ▼
        ┌────────────────────────────────────┐
        │ AI Inference Pipeline              │
        │ Gemini → Qwen → Heuristic          │
        └────────────────────────────────────┘
                           │
                           ▼
        ┌────────────────────────────────────┐
        │ Business Impact Analysis           │
        │ Threat Score • Summary • Action    │
        └────────────────────────────────────┘
                           │
                           ▼
        ┌────────────────────────────────────┐
        │ Notification Services              │
        │ Slack • Email • Notion • Airtable  │
        └────────────────────────────────────┘
```

---

# 🛠 Technology Stack

| Layer | Technologies | Purpose |
|--------|--------------|---------|
| **Frontend** | React, Vite, Tailwind CSS | Interactive analytics dashboard |
| **Backend** | Node.js, Express.js | REST APIs, scheduler, business logic |
| **Database** | SQLite | Lightweight local data storage |
| **Scraping** | Axios, Cheerio, Puppeteer | Static and dynamic website scraping |
| **AI & ML** | ONNX Transformers, Gemini 2.5 Flash, Qwen2.5 | Semantic detection and AI analysis |
| **Notifications** | Slack Webhooks, Nodemailer | Real-time alerts |
| **CRM Integration** | Notion API, Airtable REST API | Business workflow automation |
| **Extension** | Chrome Manifest V3 | Browser-based competitor tracking |
| **Deployment** | Docker, Railway | Production deployment |

---

# 🧠 AI Pipeline

## Stage 1 – Semantic Change Detection

Traditional text comparison tools generate numerous false positives by comparing characters instead of meaning.

ACIP uses **Xenova/all-MiniLM-L6-v2** running locally through ONNX Runtime to compare semantic similarity between two webpage versions.

```javascript
const { pipeline } = require("@huggingface/transformers");

const embedder = await pipeline(
  "feature-extraction",
  "Xenova/all-MiniLM-L6-v2"
);

const oldEmbedding = await embedder("Price is $100", {
    pooling: "mean",
    normalize: true
});

const newEmbedding = await embedder("Current Price: $100", {
    pooling: "mean",
    normalize: true
});

// Cosine Similarity ≈ 0.93
// Same semantic meaning → Alert suppressed
```

Instead of comparing text, the engine compares **meaning**.

---

## Stage 2 – AI Business Analysis

Once a meaningful change is detected, it enters a resilient AI inference pipeline.

```text
Gemini 2.5 Flash
        │
        ▼
Qwen2.5 Local Model
        │
        ▼
Rule-Based Heuristic Engine
```

The pipeline generates:

- Change Category
- Executive Summary
- Business Impact
- Threat Score (1–10)
- Supporting Evidence
- Recommended Actions

If the cloud model becomes unavailable due to network issues or rate limits, the system automatically switches to the local model. If local inference also fails, a rule-based engine ensures uninterrupted operation.

---

# 🌐 Chrome Extension

The Chrome Extension enables users to register competitor websites directly from their browser.

### Features

- One-click competitor registration
- Automatic URL detection
- Live notification badge
- Secure API authentication
- Configurable backend settings
- Monitoring scope selection

### Extension Structure

```text
extension/
├── manifest.json
├── popup.html
├── popup.js
├── options.html
├── options.js
├── background.js
├── icons/
```

---

# 🚀 Quick Start

## Prerequisites

- Node.js 18+
- npm 10+
- Windows, Linux, or macOS

---

## Clone Repository

```bash
git clone https://github.com/yourusername/AI-Competitor-Intelligence-Platform.git

cd AI-Competitor-Intelligence-Platform
```

---

## Install Dependencies

```bash
npm install

npm run install:all
```

---

## Configure Environment

Create a `.env` file.

```env
PORT=3000

NODE_ENV=development

GEMINI_API_KEY=YOUR_API_KEY

SLACK_WEBHOOK_URL=YOUR_SLACK_WEBHOOK
```

---

## Start Development Server

```bash
npm run dev
```

Frontend

```
http://localhost:5173
```

Backend

```
http://localhost:3000
```

---

# 📁 Project Structure

```text
AI-Competitor-Intelligence-Platform

├── client/
│   ├── src/
│   ├── public/
│   └── package.json
│
├── server/
│   ├── src/
│   │   ├── scraper.js
│   │   ├── detector.js
│   │   ├── llm.js
│   │   ├── queue.js
│   │   ├── crm.js
│   │   ├── db.js
│   │   └── index.js
│   └── package.json
│
├── extension/
│   ├── manifest.json
│   ├── popup.js
│   ├── options.js
│   └── background.js
│
├── Dockerfile
├── package.json
├── README.md
└── .env.example
```

---

# 🐳 Deployment

The application includes a production-ready Docker configuration compatible with Railway.

```bash
docker build -t ai-competitor-platform .

docker run -p 3000:3000 ai-competitor-platform
```

For Railway deployment:

1. Connect your GitHub repository.
2. Add environment variables.
3. Deploy automatically.

---

# ⚙️ Performance

| Metric | Value |
|---------|-------|
| Memory Usage | < 512 MB |
| Embedding Model | ~90 MB |
| Local LLM | ~382 MB |
| Average Detection Time | < 500 ms |
| AI Analysis | < 1.5 s |
| Database | SQLite |

---

# ⚠️ Limitations

- Initial startup downloads AI models before caching them locally.
- Some websites may restrict headless browser access.
- Sequential task execution is used to maintain low memory consumption.
- Cloud AI services may be rate limited; automatic fallback ensures uninterrupted processing.

---

# 📜 License

Licensed under the **MIT License**.

---

> **AI Competitor Intelligence Platform** combines modern web scraping, semantic AI, and automated business intelligence into a lightweight, production-ready solution for continuous competitor monitoring.
