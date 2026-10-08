const { query } = require('../config/db');

class DialogueRepository {
  async findAll({ npcId = null, chapterId = null, status = null } = {}) {
    let sql = `
      SELECT d.*, n.name as npc_name, n.portrait_url as npc_portrait
      FROM dialogues d
      LEFT JOIN npcs n ON d.npc_id = n.id
      WHERE 1=1
    `;
    const params = [];
    let idx = 1;

    if (npcId) {
      sql += ` AND d.npc_id = $${idx}`;
      params.push(npcId);
      idx++;
    }
    if (chapterId) {
      sql += ` AND d.chapter_id = $${idx}`;
      params.push(chapterId);
      idx++;
    }
    if (status) {
      sql += ` AND d.status = $${idx}`;
      params.push(status);
      idx++;
    }

    sql += ' ORDER BY d.created_at DESC';
    const { rows } = await query(sql, params);
    return rows;
  }

  async findById(id) {
    const { rows } = await query(
      `SELECT d.*, n.name as npc_name, n.portrait_url as npc_portrait
       FROM dialogues d
       LEFT JOIN npcs n ON d.npc_id = n.id
       WHERE d.id = $1`,
      [id]
    );
    return rows[0] || null;
  }

  async create(data) {
    const { id, npcId, chapterId, title, startNodeId = 'start', rawNodes = {}, status = 'DRAFT' } = data;
    const { rows } = await query(
      `INSERT INTO dialogues (id, npc_id, chapter_id, title, start_node_id, raw_nodes, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [id, npcId, chapterId, title, startNodeId, JSON.stringify(rawNodes), status]
    );
    return rows[0];
  }

  async update(id, data) {
    const fields = [];
    const params = [];
    let idx = 1;

    const mapping = {
      npc_id: data.npcId,
      chapter_id: data.chapterId,
      title: data.title,
      start_node_id: data.startNodeId,
      raw_nodes: data.rawNodes ? JSON.stringify(data.rawNodes) : undefined,
      status: data.status,
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
    const sql = `UPDATE dialogues SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const { rows } = await query(sql, params);
    return rows[0] || null;
  }

  async delete(id) {
    const { rows } = await query('DELETE FROM dialogues WHERE id = $1 RETURNING *', [id]);
    return rows[0] || null;
  }
}

module.exports = new DialogueRepository();
