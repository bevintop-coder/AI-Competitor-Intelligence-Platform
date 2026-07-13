# 🌟 ACIE: Autonomous Competitor Intelligence Engine

An autonomous, self-healing competitor monitoring engine designed to scrape target sites, detect semantic content changes using in-memory ONNX embeddings, score business threat levels via a tiered cloud/local LLM chain, and route real-time alerts to Slack, Email, and Notion/Airtable CRMs—**all engineered to operate within a tight 512MB RAM footprint.**

---

## 🛠️ System Architecture & Workflow

[ Competitor Site ]
│
▼
┌────────────────────────────────────────┐
│  1. Double-Engine Scraper              │ ──► [Axios / Puppeteer Headless]
└────────────────────────────────────────┘
│
▼
┌────────────────────────────────────────┐
│  2. Semantic Change Detector           │ ──► [Xenova/all-MiniLM-L6-v2 ONNX]
└────────────────────────────────────────┘
│ (Cosine Similarity < 0.90)
▼
┌────────────────────────────────────────┐
│  3. Tiered Inference Pipeline          │ ──► [Gemini 2.5 Flash] ──► [Qwen 2.5 GGUF] ──► [Heuristics]
└────────────────────────────────────────┘
│
▼
┌────────────────────────────────────────┐
│  4. Idempotent Queue & Sync            │ ──► [Slack Webhook] / [SMTP Email] / [Notion & Airtable]
└────────────────────────────────────────┘


| Layer | Technology Stack | Core Purpose |
| :--- | :--- | :--- |
| **Scraping** | Axios + Cheerio / Puppeteer | Headless engine handles SPAs; static fallback ensures high uptime. |
| **Vector Engine** | `@huggingface/transformers` (ONNX) | Local `all-MiniLM-L6-v2` embeddings for sub-half-second similarity checks. |
| **Analysis** | Gemini 2.5 Flash API / Qwen2.5-0.5B | Unified scoring (1–10) and context extraction via cloud or local CPU runtime. |
| **Sink Adapters** | Notion SDK, Airtable REST, Nodemailer | Idempotent multi-channel alerts with local SQLite retry state. |

---

## 🧬 Deep Dive: The In-Memory ML Pipeline

### 🧠 Stage 1: Semantic Change Detection (ONNX)
Traditional string differences (`diff`) flag simple layout shifts or spacing fixes as false positives. ACIE uses an in-memory execution wrapper around a minimized ONNX transformer pipeline to judge changes by structural meaning.

```javascript
const { pipeline } = require('@huggingface/transformers');

const embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');

const oldEmbed = await embedder("Price is $100", { pooling: 'mean', normalize: true });
const newEmbed = await embedder("Current Price: $100", { pooling: 'mean', normalize: true });

// Cosine similarity output: ~0.93 -> Meaning matches perfectly -> Suppress Alert ✅
📊 Stage 2: Resilient Tiered Inference Chain
If semantic drift crosses your threshold, the structural difference passes into a resilient, self-healing classification tier.

[Gemini 2.5 Flash API] ──(Network/Rate Limit Error)──► [Local Qwen2.5-0.5B GGUF via llama-cli] ──(Binary Failure)──► [Local RegEx Rule Heuristic]
Cloud Engine: Gemini 2.5 Flash parses the differences directly against a strict structured JSON schema.

Local Fallback: If offline or rate-limited, the system forks a sub-process executing Qwen2.5-0.5B-Instruct via a tiny local GGUF binary over CPU cores.

Heuristic Safety Net: If system memory pressure restricts the binary execution, a native RegEx classification scan scores the delta based on keywords (pricing, hiring, features).

🧩 Chrome Extension: Browser-Integrated Tracking
The native Manifest V3 Chrome Extension transforms your daily browsing routine into an active ingest vector.

Extension File Architecture
📂 extension/
├── manifest.json          # MV3 Configuration, minimal background background permissions
├── popup.html / popup.js  # Dynamic DOM extraction & active context injection
├── options.html / options.js # Crypto-secured localStorage token bindings
└── background.js          # Low-overhead 60-second polling worker for live alert counts
Features
One-Click Ingestion: Automatically strips URL patterns, guesses competitor naming models, and inserts new targets directly into the active SQLite processing loop.

Live Intelligence Badge: The background service worker pulls active status variations every 60 seconds, lighting up a high-visibility cyan counter over the extension icon when fresh business threat updates hit your stack.

🚀 Quick Start Guide
Prerequisites
Node.js v18+

NPM v10+

Operating System: Linux, macOS, or Windows (WSL2 recommended)

1. Installation
Clone the workspace and run the automated nested dependency linker:

Bash
git clone [https://github.com/NitheshK4/Autonomous-Competitor-Intelligence-Engine.git](https://github.com/NitheshK4/Autonomous-Competitor-Intelligence-Engine.git)
cd Autonomous-Competitor-Intelligence-Engine
npm install
npm run install:all
Note: No local Python setup required. All underlying models run natively through optimized C++/WASM wrappers inside the Node sub-process layout.

2. Configuration (.env)
Create a .env block inside your server root root directory:

Code snippet
PORT=3000
NODE_ENV=development

# Core Cloud API Keys (Optional - Fallbacks kick in automatically)
GEMINI_API_KEY=AIzaSyYourKeyHere...

# Downstream Notification Outlets
SLACK_WEBHOOK_URL=[https://hooks.slack.com/services/T00/B00/Xyz](https://hooks.slack.com/services/T00/B00/Xyz)...
3. Execution
Fire up the local database system, the continuous cron tracking worker, and the React client dashboard concurrently:

Bash
npm run dev
Backend Platform Gateway: http://localhost:3000

React Interactive Dashboard: http://localhost:5173

📂 Repository Layout
📦 Autonomous-Competitor-Intelligence-Engine
├── 📂 client/                        # React 18 + Vite 5 Interactive Frontend Web UI
│   └── 📂 src/
│       ├── App.jsx                   # Centralized state manager & dashboard view
│       └── main.jsx                  # Virtual DOM node mounting entry
├── 📂 server/                        # Express Core Engine
│   └── 📂 src/
│       ├── index.js                  # Master server scheduling loops & API routing
│       ├── scraper.js                # Double-headed Puppeteer/Axios extractor
│       ├── detector.js               # Local ONNX vector similarity framework
│       ├── llm.js                    # Resilient inference fallback logic
│       ├── crm.js                    # Notion/Airtable API structural adapters
│       └── db.js                     # SQLite abstraction interface
├── 📂 extension/                     # Manifest V3 browser integration source
└── Dockerfile                        # Multi-stage Linux production layout
🐳 Production Deployment (Railway / Docker)
The included production Dockerfile uses a multi-stage compilation strategy. It handles system-level dependencies for headless Chromium (Puppeteer) and bundles runtime dependencies cleanly under 512MB RAM constraints by implementing sequential queueing logic.

To host on Railway:

Connect this repository to your Railway control board.

Inject your production environment variables (GEMINI_API_KEY, etc.).

Railway automatically parses the Dockerfile to pull runtime dependencies, download the cached model formats, compile the production Vite distribution assets, and expose your network port.

📋 Operational Guardrails & Limitations
Model Warmups: The initialization phase downloads down raw models (~90MB for ONNX, ~382MB for local GGUF architectures). These are written to a localized storage directory to bypass network operations on subsequent process startups.

Concurrency Lock: To maintain the 512MB RAM SLA, scraping and inference workflows are kept on a strict sequential queue (queue.js). Sites evaluate one by one to avoid memory leakage or garbage collector spikes.
