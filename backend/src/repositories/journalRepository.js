const { query } = require('../config/db');

class JournalRepository {
  async findAll({ category = null, status = null } = {}) {
    let sql = 'SELECT * FROM journal_entries WHERE 1=1';
    const params = [];
    let idx = 1;

    if (category) {
      sql += ` AND category = $${idx}`;
      params.push(category);
      idx++;
    }
    if (status) {
      sql += ` AND status = $${idx}`;
      params.push(status);
      idx++;
    }

    sql += ' ORDER BY created_at ASC';
    const { rows } = await query(sql, params);
    return rows;
  }

  async findById(id) {
    const { rows } = await query('SELECT * FROM journal_entries WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async create(data) {
    const id = data.id;
    const title = data.title;
    const content = data.content;
    const category = data.category || 'STORY';
    const chapterId = data.chapterId !== undefined ? data.chapterId : (data.chapter_id || null);
    const imageUrl = data.imageUrl !== undefined ? data.imageUrl : (data.image_url || '');
    const referenceSource = data.referenceSource !== undefined ? data.referenceSource : (data.reference_source || '');
    const status = data.status || 'PUBLISHED';
    const { rows } = await query(
      `INSERT INTO journal_entries (id, title, content, category, chapter_id, image_url, reference_source, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [id, title, content, category, chapterId, imageUrl, referenceSource, status]
    );
    return rows[0];
  }

  async update(id, data) {
    const fields = [];
    const params = [];
    let idx = 1;

    const mapping = {
      title: data.title,
      content: data.content,
      category: data.category,
      chapter_id: data.chapterId !== undefined ? data.chapterId : data.chapter_id,
      image_url: data.imageUrl !== undefined ? data.imageUrl : data.image_url,
      reference_source: data.referenceSource !== undefined ? data.referenceSource : data.reference_source,
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
    const sql = `UPDATE journal_entries SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const { rows } = await query(sql, params);
    return rows[0] || null;
  }

  async delete(id) {
    const { rows } = await query('DELETE FROM journal_entries WHERE id = $1 RETURNING *', [id]);
    return rows[0] || null;
  }
}

module.exports = new JournalRepository();
