const { query } = require('../config/db');

class AdminRepository {
  async findById(id) {
    const { rows } = await query(
      'SELECT id, email, name, role, is_active, created_at, updated_at FROM admins WHERE id = $1',
      [id]
    );
    return rows[0] || null;
  }

  async findByEmail(email) {
    const { rows } = await query(
      'SELECT * FROM admins WHERE LOWER(email) = LOWER($1)',
      [email]
    );
    return rows[0] || null;
  }

  async create({ email, passwordHash, name, role = 'CONTENT_EDITOR' }) {
    const { rows } = await query(
      `INSERT INTO admins (email, password_hash, name, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, name, role, is_active, created_at`,
      [email, passwordHash, name, role]
    );
    return rows[0];
  }

  async listAdmins() {
    const { rows } = await query(
      'SELECT id, email, name, role, is_active, created_at FROM admins ORDER BY created_at ASC'
    );
    return rows;
  }
}

module.exports = new AdminRepository();
