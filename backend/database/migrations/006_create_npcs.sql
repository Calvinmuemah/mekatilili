CREATE TABLE IF NOT EXISTS npcs (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    role VARCHAR(100),
    portrait_url VARCHAR(255),
    chapter_id VARCHAR(100) REFERENCES chapters(id) ON DELETE SET NULL,
    location_name VARCHAR(150),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_npcs_chapter ON npcs(chapter_id);
