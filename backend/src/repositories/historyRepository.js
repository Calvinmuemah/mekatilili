const { query } = require('../config/db');

class HistoryRepository {
  async findAll({ chapterId = null } = {}) {
    let sql = 'SELECT * FROM historical_references WHERE 1=1';
    const params = [];
    let idx = 1;

    if (chapterId) {
      sql += ` AND related_chapter_id = $${idx}`;
      params.push(chapterId);
      idx++;
    }

    sql += ' ORDER BY created_at ASC';
    const { rows } = await query(sql, params);
    return rows;
  }

  async findById(id) {
    const { rows } = await query('SELECT * FROM historical_references WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async create(data) {
    const id = data.id;
    const title = data.title;
    const description = data.description;
    const source = data.source;
    const sourceUrl = data.sourceUrl !== undefined ? data.sourceUrl : (data.source_url || '');
    const author = data.author || '';
    const publicationDate = data.publicationDate !== undefined ? data.publicationDate : (data.publication_date || '');
    const notes = data.notes || '';
    const relatedChapterId = data.relatedChapterId !== undefined ? data.relatedChapterId : (data.related_chapter_id || null);
    const isVerified = data.isVerified !== undefined ? data.isVerified : (data.is_verified !== undefined ? data.is_verified : true);
    const { rows } = await query(
      `INSERT INTO historical_references 
       (id, title, description, source, source_url, author, publication_date, notes, related_chapter_id, is_verified)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [id, title, description, source, sourceUrl, author, publicationDate, notes, relatedChapterId, isVerified]
    );
    return rows[0];
  }

  async update(id, data) {
    const fields = [];
    const params = [];
    let idx = 1;

    const mapping = {
      title: data.title,
      description: data.description,
      source: data.source,
      source_url: data.sourceUrl !== undefined ? data.sourceUrl : data.source_url,
      author: data.author,
      publication_date: data.publicationDate !== undefined ? data.publicationDate : data.publication_date,
      notes: data.notes,
      related_chapter_id: data.relatedChapterId !== undefined ? data.relatedChapterId : data.related_chapter_id,
      is_verified: data.isVerified !== undefined ? data.isVerified : data.is_verified,
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
    const sql = `UPDATE historical_references SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const { rows } = await query(sql, params);
    return rows[0] || null;
  }

  async delete(id) {
    const { rows } = await query('DELETE FROM historical_references WHERE id = $1 RETURNING *', [id]);
    return rows[0] || null;
  }
}

module.exports = new HistoryRepository();
