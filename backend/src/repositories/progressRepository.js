const { query, pool } = require('../config/db');

class ProgressRepository {
  async findByUserId(userId) {
    const progRes = await query('SELECT * FROM player_progress WHERE user_id = $1', [userId]);
    const questRes = await query('SELECT * FROM player_quests WHERE user_id = $1', [userId]);
    const colRes = await query('SELECT * FROM player_collectibles WHERE user_id = $1', [userId]);
    const flagRes = await query('SELECT * FROM story_flags WHERE user_id = $1', [userId]);

    const flags = {};
    for (const r of flagRes.rows) {
      flags[r.flag_key] = r.flag_value;
    }

    return {
      progress: progRes.rows[0] || null,
      quests: questRes.rows,
      collectibles: colRes.rows.map(r => r.collectible_id),
      storyFlags: flags,
    };
  }

  async upsertFullSync(userId, syncData) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const {
        chapter = 1,
        scene = 'res://scenes/environments/VillageLevel.tscn',
        progressPercentage = 0,
        communityUnity = 0,
        playerPosition = { x: 430, y: 400 },
        rawSaveData = {},
        quests = {},
        collectibles = [],
        storyFlags = {}
      } = syncData;

      // 1. Progress record
      await client.query(`
        INSERT INTO player_progress 
          (user_id, current_chapter, current_scene, progress_percentage, community_unity, player_position, raw_save_data, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id) DO UPDATE SET
          current_chapter = EXCLUDED.current_chapter,
          current_scene = EXCLUDED.current_scene,
          progress_percentage = EXCLUDED.progress_percentage,
          community_unity = EXCLUDED.community_unity,
          player_position = EXCLUDED.player_position,
          raw_save_data = EXCLUDED.raw_save_data,
          updated_at = CURRENT_TIMESTAMP;
      `, [userId, chapter, scene, progressPercentage, communityUnity, JSON.stringify(playerPosition), JSON.stringify(rawSaveData)]);

      // 2. Collectibles
      if (Array.isArray(collectibles)) {
        for (const c of collectibles) {
          const colId = typeof c === 'string' ? c : (c.id || '');
          if (colId) {
            await client.query(`
              INSERT INTO player_collectibles (user_id, collectible_id)
              VALUES ($1, $2)
              ON CONFLICT (user_id, collectible_id) DO NOTHING;
            `, [userId, colId]);
          }
        }
      }

      // 3. Story Flags
      if (typeof storyFlags === 'object' && storyFlags !== null) {
        for (const [k, v] of Object.entries(storyFlags)) {
          await client.query(`
            INSERT INTO story_flags (user_id, flag_key, flag_value, updated_at)
            VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, flag_key) DO UPDATE SET
              flag_value = EXCLUDED.flag_value,
              updated_at = CURRENT_TIMESTAMP;
          `, [userId, k, JSON.stringify(v)]);
        }
      }

      await client.query('COMMIT');
      return true;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
}

module.exports = new ProgressRepository();
