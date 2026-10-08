const { query } = require('../config/db');

class NPCRepository {
  async findAll({ chapterId = null } = {}) {
    let sql = 'SELECT * FROM npcs WHERE is_active = TRUE';
    const params = [];
    if (chapterId) {
      sql += ' AND chapter_id = $1';
      params.push(chapterId);
    }
    sql += ' ORDER BY name ASC';
    const { rows } = await query(sql, params);
    return rows;
  }

  async findById(id) {
    const { rows } = await query('SELECT * FROM npcs WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async create(data) {
    const { id, name, description, role, portraitUrl, chapterId, locationName } = data;
    const { rows } = await query(
      `INSERT INTO npcs (id, name, description, role, portrait_url, chapter_id, location_name)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [id, name, description, role, portraitUrl, chapterId, locationName]
    );
    return rows[0];
  }

  async update(id, data) {
    const fields = [];
    const params = [];
    let idx = 1;

    const mapping = {
      name: data.name,
      description: data.description,
      role: data.role,
      portrait_url: data.portraitUrl,
      chapter_id: data.chapterId,
      location_name: data.locationName,
      is_active: data.isActive,
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
    const sql = `UPDATE npcs SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const { rows } = await query(sql, params);
    return rows[0] || null;
  }

  async delete(id) {
    const { rows } = await query('DELETE FROM npcs WHERE id = $1 RETURNING *', [id]);
    return rows[0] || null;
  }
}

module.exports = new NPCRepository();
