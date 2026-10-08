CREATE TABLE IF NOT EXISTS historical_references (
    id VARCHAR(100) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    source VARCHAR(255) NOT NULL,
    source_url VARCHAR(500),
    author VARCHAR(255),
    publication_date VARCHAR(100),
    notes TEXT,
    related_chapter_id VARCHAR(100) REFERENCES chapters(id) ON DELETE SET NULL,
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_hist_ref_chapter ON historical_references(related_chapter_id);
