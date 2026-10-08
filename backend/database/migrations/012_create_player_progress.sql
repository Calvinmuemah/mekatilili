CREATE TABLE IF NOT EXISTS player_progress (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_chapter INT DEFAULT 1,
    current_scene VARCHAR(255) DEFAULT 'res://scenes/environments/VillageLevel.tscn',
    progress_percentage INT DEFAULT 0,
    community_unity INT DEFAULT 0,
    player_position JSONB DEFAULT '{"x": 430, "y": 400}',
    raw_save_data JSONB DEFAULT '{}',
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS player_quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    quest_id VARCHAR(100) REFERENCES quests(id) ON DELETE CASCADE,
    state INT DEFAULT 0,
    current_objective_index INT DEFAULT 0,
    objectives_data JSONB DEFAULT '[]',
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, quest_id)
);

CREATE TABLE IF NOT EXISTS player_collectibles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    collectible_id VARCHAR(100) REFERENCES collectibles(id) ON DELETE CASCADE,
    collected_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, collectible_id)
);

CREATE TABLE IF NOT EXISTS story_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    flag_key VARCHAR(100) NOT NULL,
    flag_value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, flag_key)
);

CREATE INDEX IF NOT EXISTS idx_player_quests_user ON player_quests(user_id);
CREATE INDEX IF NOT EXISTS idx_player_collectibles_user ON player_collectibles(user_id);
CREATE INDEX IF NOT EXISTS idx_story_flags_user ON story_flags(user_id);
