CREATE TABLE IF NOT EXISTS dialogues (
    id VARCHAR(100) PRIMARY KEY,
    npc_id VARCHAR(100) REFERENCES npcs(id) ON DELETE CASCADE,
    chapter_id VARCHAR(100) REFERENCES chapters(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    start_node_id VARCHAR(100) DEFAULT 'start',
    raw_nodes JSONB NOT NULL DEFAULT '{}',
    status VARCHAR(50) NOT NULL DEFAULT 'DRAFT', -- DRAFT, PUBLISHED, ARCHIVED
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_dialogues_npc ON dialogues(npc_id);
CREATE INDEX IF NOT EXISTS idx_dialogues_chapter ON dialogues(chapter_id);
CREATE INDEX IF NOT EXISTS idx_dialogues_status ON dialogues(status);
