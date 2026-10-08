CREATE TABLE IF NOT EXISTS journal_entries (
    id VARCHAR(100) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'STORY', -- STORY, HISTORY, CULTURAL, CHARACTER
    chapter_id VARCHAR(100) REFERENCES chapters(id) ON DELETE SET NULL,
    image_url VARCHAR(255),
    reference_source TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'PUBLISHED', -- DRAFT, PUBLISHED, ARCHIVED
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_journal_category ON journal_entries(category);
CREATE INDEX IF NOT EXISTS idx_journal_status ON journal_entries(status);
