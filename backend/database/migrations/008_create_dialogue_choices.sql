CREATE TABLE IF NOT EXISTS dialogue_choices (
    id VARCHAR(100) PRIMARY KEY,
    dialogue_id VARCHAR(100) REFERENCES dialogues(id) ON DELETE CASCADE,
    node_id VARCHAR(100) NOT NULL,
    choice_text TEXT NOT NULL,
    next_node_id VARCHAR(100),
    condition_flag VARCHAR(100),
    story_effect JSONB DEFAULT '{}',
    order_index INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_choices_dialogue ON dialogue_choices(dialogue_id);
