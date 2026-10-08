const { query } = require('../config/db');

class QuestRepository {
  async findAll({ chapterId = null, status = null } = {}) {
    let sql = 'SELECT * FROM quests WHERE 1=1';
    const params = [];
    let idx = 1;

    if (chapterId) {
      sql += ` AND chapter_id = $${idx}`;
      params.push(chapterId);
      idx++;
    }
    if (status) {
      sql += ` AND status = $${idx}`;
      params.push(status);
      idx++;
    }
    sql += ' ORDER BY order_index ASC';
    const { rows } = await query(sql, params);
    return rows;
  }

  async findById(id) {
    const { rows } = await query('SELECT * FROM quests WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async findObjectivesByQuestId(questId) {
    const { rows } = await query(
      'SELECT * FROM quest_objectives WHERE quest_id = $1 ORDER BY order_index ASC',
      [questId]
    );
    return rows;
  }

  async create(data) {
    const { id, chapterId, title, description, status = 'DRAFT', rewardText = '', orderIndex = 1 } = data;
    const { rows } = await query(
      `INSERT INTO quests (id, chapter_id, title, description, status, reward_text, order_index)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [id, chapterId, title, description, status, rewardText, orderIndex]
    );
    return rows[0];
  }

  async update(id, data) {
    const fields = [];
    const params = [];
    let idx = 1;

    const mapping = {
      chapter_id: data.chapterId,
      title: data.title,
      description: data.description,
      status: data.status,
      reward_text: data.rewardText,
      order_index: data.orderIndex,
    };

    for (const [col, val] of Object.entries(mapping)) {
      if (val !== undefined) {
        fields.push(`${col} = $${idx}`);
        params.push(val);
        idx++;
      }
    }

    if (fields.length === 0) return this.findById(id);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    params.push(id);
    const sql = `UPDATE quests SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const { rows } = await query(sql, params);
    return rows[0] || null;
  }

  async createObjective(data) {
    const { id, questId, title, description, objectiveType = 'CUSTOM', required = true, orderIndex = 1 } = data;
    const { rows } = await query(
      `INSERT INTO quest_objectives (id, quest_id, title, description, objective_type, required, order_index)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [id, questId, title, description, objectiveType, required, orderIndex]
    );
    return rows[0];
  }

  async delete(id) {
    const { rows } = await query('DELETE FROM quests WHERE id = $1 RETURNING *', [id]);
    return rows[0] || null;
  }
}

module.exports = new QuestRepository();
