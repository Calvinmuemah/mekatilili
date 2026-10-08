const { query } = require('../config/db');

class CollectibleRepository {
  async findAll({ status = null, chapterId = null } = {}) {
    let sql = 'SELECT * FROM collectibles WHERE 1=1';
    const params = [];
    let idx = 1;

    if (status) {
      sql += ` AND status = $${idx}`;
      params.push(status);
      idx++;
    }
    if (chapterId) {
      sql += ` AND chapter_id = $${idx}`;
      params.push(chapterId);
      idx++;
    }

    sql += ' ORDER BY created_at ASC';
    const { rows } = await query(sql, params);
    return rows;
  }

  async findById(id) {
    const { rows } = await query('SELECT * FROM collectibles WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async create(data) {
    const id = data.id;
    const name = data.name;
    const description = data.description;
    const category = data.category || 'CULTURAL_ARTIFACT';
    const imageUrl = data.imageUrl !== undefined ? data.imageUrl : (data.image_url || '');
    const historicalContext = data.historicalContext !== undefined ? data.historicalContext : (data.historical_context || '');
    const chapterId = data.chapterId !== undefined ? data.chapterId : (data.chapter_id || null);
    const status = data.status || 'PUBLISHED';
    const { rows } = await query(
      `INSERT INTO collectibles (id, name, description, category, image_url, historical_context, chapter_id, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [id, name, description, category, imageUrl, historicalContext, chapterId, status]
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
      category: data.category,
      image_url: data.imageUrl !== undefined ? data.imageUrl : data.image_url,
      historical_context: data.historicalContext !== undefined ? data.historicalContext : data.historical_context,
      chapter_id: data.chapterId !== undefined ? data.chapterId : data.chapter_id,
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
    const sql = `UPDATE collectibles SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const { rows } = await query(sql, params);
    return rows[0] || null;
  }

  async delete(id) {
    const { rows } = await query('DELETE FROM collectibles WHERE id = $1 RETURNING *', [id]);
    return rows[0] || null;
  }
}

module.exports = new CollectibleRepository();
