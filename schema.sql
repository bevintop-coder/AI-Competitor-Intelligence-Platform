-- ============================================================
-- AI Competitor Intelligence Platform (ACIP)
-- SQLite Database Schema
-- ============================================================

PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. COMPETITORS
-- ============================================================

CREATE TABLE IF NOT EXISTS competitors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    name TEXT NOT NULL,
    website_url TEXT NOT NULL UNIQUE,

    description TEXT,

    monitoring_enabled INTEGER NOT NULL DEFAULT 1
        CHECK (monitoring_enabled IN (0, 1)),

    monitoring_interval INTEGER NOT NULL DEFAULT 3600
        CHECK (monitoring_interval > 0),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. MONITORED PAGES
-- ============================================================

CREATE TABLE IF NOT EXISTS monitored_pages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    competitor_id INTEGER NOT NULL,

    url TEXT NOT NULL,
    page_name TEXT,

    scraping_method TEXT DEFAULT 'axios'
        CHECK (
            scraping_method IN (
                'axios',
                'cheerio',
                'puppeteer'
            )
        ),

    active INTEGER NOT NULL DEFAULT 1
        CHECK (active IN (0, 1)),

    last_checked_at DATETIME,
    next_check_at DATETIME,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (competitor_id)
        REFERENCES competitors(id)
        ON DELETE CASCADE,

    UNIQUE (competitor_id, url)
);


-- ============================================================
-- 3. PAGE SNAPSHOTS
-- Stores previous versions of competitor pages
-- ============================================================

CREATE TABLE IF NOT EXISTS page_snapshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    page_id INTEGER NOT NULL,

    content TEXT NOT NULL,
    content_hash TEXT NOT NULL,

    embedding_model TEXT DEFAULT 'Xenova/all-MiniLM-L6-v2',

    embedding_generated INTEGER NOT NULL DEFAULT 1
        CHECK (embedding_generated IN (0, 1)),

    captured_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (page_id)
        REFERENCES monitored_pages(id)
        ON DELETE CASCADE
);


-- ============================================================
-- 4. DETECTED CHANGES
-- ============================================================

CREATE TABLE IF NOT EXISTS detected_changes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    page_id INTEGER NOT NULL,

    old_snapshot_id INTEGER,
    new_snapshot_id INTEGER NOT NULL,

    similarity_score REAL
        CHECK (
            similarity_score >= 0
            AND similarity_score <= 1
        ),

    change_detected INTEGER NOT NULL DEFAULT 1
        CHECK (change_detected IN (0, 1)),

    change_type TEXT,

    detection_method TEXT DEFAULT 'semantic',

    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (page_id)
        REFERENCES monitored_pages(id)
        ON DELETE CASCADE,

    FOREIGN KEY (old_snapshot_id)
        REFERENCES page_snapshots(id)
        ON DELETE SET NULL,

    FOREIGN KEY (new_snapshot_id)
        REFERENCES page_snapshots(id)
        ON DELETE CASCADE
);


-- ============================================================
-- 5. AI ANALYSIS
-- ============================================================

CREATE TABLE IF NOT EXISTS ai_analysis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    change_id INTEGER NOT NULL,

    model_provider TEXT NOT NULL,

    model_name TEXT NOT NULL,

    change_category TEXT,

    executive_summary TEXT,

    business_impact TEXT,

    threat_score INTEGER
        CHECK (
            threat_score >= 1
            AND threat_score <= 10
        ),

    supporting_evidence TEXT,

    recommended_actions TEXT,

    inference_status TEXT DEFAULT 'success'
        CHECK (
            inference_status IN (
                'success',
                'failed',
                'fallback'
            )
        ),

    processing_time_ms INTEGER,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (change_id)
        REFERENCES detected_changes(id)
        ON DELETE CASCADE
);


-- ============================================================
-- 6. AI INFERENCE LOG
-- Tracks Gemini → Qwen → Heuristic fallback
-- ============================================================

CREATE TABLE IF NOT EXISTS inference_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    change_id INTEGER,

    provider TEXT NOT NULL,

    model_name TEXT NOT NULL,

    status TEXT NOT NULL
        CHECK (
            status IN (
                'success',
                'failed',
                'timeout',
                'rate_limited'
            )
        ),

    error_message TEXT,

    processing_time_ms INTEGER,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (change_id)
        REFERENCES detected_changes(id)
        ON DELETE SET NULL
);


-- ============================================================
-- 7. NOTIFICATION CHANNELS
-- ============================================================

CREATE TABLE IF NOT EXISTS notification_channels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    channel_type TEXT NOT NULL
        CHECK (
            channel_type IN (
                'slack',
                'email',
                'notion',
                'airtable'
            )
        ),

    channel_name TEXT,

    configuration TEXT NOT NULL,

    enabled INTEGER NOT NULL DEFAULT 1
        CHECK (enabled IN (0, 1)),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 8. NOTIFICATION LOG
-- ============================================================

CREATE TABLE IF NOT EXISTS notification_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    change_id INTEGER NOT NULL,
    channel_id INTEGER NOT NULL,

    status TEXT NOT NULL
        CHECK (
            status IN (
                'sent',
                'failed',
                'pending'
            )
        ),

    message TEXT,

    error_message TEXT,

    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (change_id)
        REFERENCES detected_changes(id)
        ON DELETE CASCADE,

    FOREIGN KEY (channel_id)
        REFERENCES notification_channels(id)
        ON DELETE CASCADE
);


-- ============================================================
-- 9. CRM INTEGRATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS crm_integrations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    integration_type TEXT NOT NULL
        CHECK (
            integration_type IN (
                'notion',
                'airtable'
            )
        ),

    workspace_name TEXT,

    configuration TEXT NOT NULL,

    enabled INTEGER NOT NULL DEFAULT 1
        CHECK (enabled IN (0, 1)),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 10. SCHEDULED MONITORING TASKS
-- ============================================================

CREATE TABLE IF NOT EXISTS monitoring_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    page_id INTEGER NOT NULL,

    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'running',
                'completed',
                'failed'
            )
        ),

    scheduled_at DATETIME NOT NULL,

    started_at DATETIME,
    completed_at DATETIME,

    error_message TEXT,

    FOREIGN KEY (page_id)
        REFERENCES monitored_pages(id)
        ON DELETE CASCADE
);


-- ============================================================
-- 11. SYSTEM EVENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS system_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    event_type TEXT NOT NULL,

    component TEXT NOT NULL,

    message TEXT,

    severity TEXT DEFAULT 'info'
        CHECK (
            severity IN (
                'info',
                'warning',
                'error',
                'critical'
            )
        ),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_competitors_enabled
ON competitors(monitoring_enabled);


CREATE INDEX IF NOT EXISTS idx_pages_competitor
ON monitored_pages(competitor_id);


CREATE INDEX IF NOT EXISTS idx_pages_next_check
ON monitored_pages(next_check_at);


CREATE INDEX IF NOT EXISTS idx_snapshots_page
ON page_snapshots(page_id);


CREATE INDEX IF NOT EXISTS idx_snapshots_hash
ON page_snapshots(content_hash);


CREATE INDEX IF NOT EXISTS idx_changes_page
ON detected_changes(page_id);


CREATE INDEX IF NOT EXISTS idx_changes_date
ON detected_changes(detected_at);


CREATE INDEX IF NOT EXISTS idx_analysis_change
ON ai_analysis(change_id);


CREATE INDEX IF NOT EXISTS idx_analysis_threat
ON ai_analysis(threat_score);


CREATE INDEX IF NOT EXISTS idx_notifications_change
ON notification_logs(change_id);


CREATE INDEX IF NOT EXISTS idx_tasks_status
ON monitoring_tasks(status);


CREATE INDEX IF NOT EXISTS idx_tasks_schedule
ON monitoring_tasks(scheduled_at);


-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT OR IGNORE INTO competitors
    (name, website_url, description)
VALUES
    (
        'Example Competitor',
        'https://example.com',
        'Sample competitor for ACIP monitoring'
    );


INSERT OR IGNORE INTO monitored_pages
    (competitor_id, url, page_name, scraping_method)
VALUES
    (
        1,
        'https://example.com/pricing',
        'Pricing Page',
        'axios'
    );


-- ============================================================
-- SAMPLE NOTIFICATION CHANNEL
-- ============================================================

INSERT INTO notification_channels
    (channel_type, channel_name, configuration)
VALUES
    (
        'slack',
        'ACIP Alerts',
        '{"webhook_url":"YOUR_SLACK_WEBHOOK_URL"}'
    );


-- ============================================================
-- SAMPLE QUERIES
-- ============================================================

-- View all competitors
SELECT *
FROM competitors;


-- View monitored competitor pages
SELECT
    c.name AS competitor,
    m.page_name,
    m.url,
    m.last_checked_at,
    m.next_check_at
FROM competitors c
JOIN monitored_pages m
    ON c.id = m.competitor_id;


-- View detected changes
SELECT
    c.name AS competitor,
    m.url,
    d.similarity_score,
    d.change_type,
    d.detected_at
FROM detected_changes d
JOIN monitored_pages m
    ON d.page_id = m.id
JOIN competitors c
    ON m.competitor_id = c.id
ORDER BY d.detected_at DESC;


-- View high-threat changes
SELECT
    c.name AS competitor,
    m.url,
    a.change_category,
    a.business_impact,
    a.threat_score,
    a.recommended_actions
FROM ai_analysis a
JOIN detected_changes d
    ON a.change_id = d.id
JOIN monitored_pages m
    ON d.page_id = m.id
JOIN competitors c
    ON m.competitor_id = c.id
WHERE a.threat_score >= 7
ORDER BY a.threat_score DESC;


-- Dashboard summary
SELECT
    COUNT(DISTINCT c.id) AS total_competitors,
    COUNT(DISTINCT m.id) AS monitored_pages,
    COUNT(DISTINCT d.id) AS detected_changes,
    COUNT(DISTINCT CASE
        WHEN a.threat_score >= 7 THEN a.id
    END) AS high_threat_changes
FROM competitors c
LEFT JOIN monitored_pages m
    ON c.id = m.competitor_id
LEFT JOIN detected_changes d
    ON m.id = d.page_id
LEFT JOIN ai_analysis a
    ON d.id = a.change_id;
