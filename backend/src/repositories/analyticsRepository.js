const { query } = require('../config/db');

class AnalyticsRepository {
  async recordEvent({ userId = null, eventType, chapterId = null, questId = null, metadata = {} }) {
    const { rows } = await query(
      `INSERT INTO analytics_events (user_id, event_type, chapter_id, quest_id, metadata)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userId, eventType, chapterId, questId, JSON.stringify(metadata)]
    );
    return rows[0];
  }

  async getSummaryMetrics() {
    const totalUsers = await query('SELECT COUNT(*) as count FROM users');
    const activeUsers = await query(
      "SELECT COUNT(*) as count FROM users WHERE last_login_at >= NOW() - INTERVAL '30 days'"
    );
    const totalChapters = await query("SELECT COUNT(*) as count FROM chapters WHERE status = 'PUBLISHED'");
    const totalQuests = await query("SELECT COUNT(*) as count FROM quests WHERE status = 'PUBLISHED'");
    const totalNPCs = await query('SELECT COUNT(*) as count FROM npcs WHERE is_active = TRUE');
    const totalCollectibles = await query("SELECT COUNT(*) as count FROM collectibles WHERE status = 'PUBLISHED'");

    const eventCounts = await query(`
      SELECT event_type, COUNT(*) as count
      FROM analytics_events
      GROUP BY event_type
      ORDER BY count DESC
    `);

    const recentEvents = await query(`
      SELECT id, event_type, chapter_id, quest_id, metadata, created_at
      FROM analytics_events
      ORDER BY created_at DESC
      LIMIT 10
    `);

    return {
      totalPlayers: parseInt(totalUsers.rows[0].count, 10),
      activePlayers: parseInt(activeUsers.rows[0].count, 10),
      publishedChapters: parseInt(totalChapters.rows[0].count, 10),
      publishedQuests: parseInt(totalQuests.rows[0].count, 10),
      activeNPCs: parseInt(totalNPCs.rows[0].count, 10),
      publishedCollectibles: parseInt(totalCollectibles.rows[0].count, 10),
      eventDistribution: eventCounts.rows,
      recentEvents: recentEvents.rows,
    };
  }
}

module.exports = new AnalyticsRepository();
