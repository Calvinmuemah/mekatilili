const { query } = require('../config/db');

class ChapterRepository {
  async findAll({ status = null } = {}) {
    let sql = 'SELECT * FROM chapters';
    const params = [];
    if (status) {
      sql += ' WHERE status = $1';
      params.push(status);
    }
    sql += ' ORDER BY chapter_number ASC';
    const { rows } = await query(sql, params);
    return rows;
  }

  async findById(id) {
    const { rows } = await query('SELECT * FROM chapters WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async findByNumber(chapterNumber) {
    const { rows } = await query('SELECT * FROM chapters WHERE chapter_number = $1', [chapterNumber]);
    return rows[0] || null;
  }

  async create(data) {
    const {
      id, chapterNumber, title, subtitle, description, summary,
      historicalNote, scenePath, status = 'DRAFT', orderIndex = 1
    } = data;
    const { rows } = await query(
      `INSERT INTO chapters 
       (id, chapter_number, title, subtitle, description, summary, historical_note, scene_path, status, order_index)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [id, chapterNumber, title, subtitle, description, summary, historicalNote, scenePath, status, orderIndex]
    );
    return rows[0];
  }

  async update(id, data) {
    const fields = [];
    const params = [];
    let idx = 1;

    const mapping = {
      chapter_number: data.chapterNumber,
      title: data.title,
      subtitle: data.subtitle,
      description: data.description,
      summary: data.summary,
      historical_note: data.historicalNote,
      scene_path: data.scenePath,
      status: data.status,
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

    fields.push(`updated_at = CURRENT_TIMESTAMP`);
    params.push(id);
    const sql = `UPDATE chapters SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const { rows } = await query(sql, params);
    return rows[0] || null;
  }

  async archive(id) {
    const { rows } = await query(
      `UPDATE chapters SET status = 'ARCHIVED', updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *`,
      [id]
    );
    return rows[0] || null;
  }

  async delete(id) {
    const { rows } = await query('DELETE FROM chapters WHERE id = $1 RETURNING *', [id]);
    return rows[0] || null;
  }
}

module.exports = new ChapterRepository();
