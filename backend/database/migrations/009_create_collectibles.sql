CREATE TABLE IF NOT EXISTS collectibles (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) DEFAULT 'CULTURAL_ARTIFACT',
    image_url VARCHAR(255),
    historical_context TEXT,
    chapter_id VARCHAR(100) REFERENCES chapters(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'PUBLISHED', -- DRAFT, PUBLISHED, ARCHIVED
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_collectibles_chapter ON collectibles(chapter_id);
CREATE INDEX IF NOT EXISTS idx_collectibles_status ON collectibles(status);
