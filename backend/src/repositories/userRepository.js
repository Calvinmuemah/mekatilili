const { query } = require('../config/db');

class UserRepository {
  async findById(id) {
    const { rows } = await query(
      'SELECT id, email, username, display_name, is_active, last_login_at, created_at, updated_at FROM users WHERE id = $1',
      [id]
    );
    return rows[0] || null;
  }

  async findByEmail(email) {
    const { rows } = await query(
      'SELECT * FROM users WHERE LOWER(email) = LOWER($1)',
      [email]
    );
    return rows[0] || null;
  }

  async findByUsername(username) {
    const { rows } = await query(
      'SELECT * FROM users WHERE LOWER(username) = LOWER($1)',
      [username]
    );
    return rows[0] || null;
  }

  async create({ email, username, passwordHash, displayName }) {
    const { rows } = await query(
      `INSERT INTO users (email, username, password_hash, display_name)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, username, display_name, is_active, created_at`,
      [email, username, passwordHash, displayName || username]
    );
    return rows[0];
  }

  async updateLastLogin(id) {
    await query(
      'UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE id = $1',
      [id]
    );
  }

  async listUsers({ limit = 50, offset = 0 } = {}) {
    const { rows } = await query(
      `SELECT u.id, u.email, u.username, u.display_name, u.is_active, u.last_login_at, u.created_at,
              COALESCE(p.current_chapter, 1) as current_chapter,
              COALESCE(p.progress_percentage, 0) as progress_percentage,
              COALESCE(p.community_unity, 0) as community_unity
       FROM users u
       LEFT JOIN player_progress p ON u.id = p.user_id
       ORDER BY u.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    const countRes = await query('SELECT COUNT(*) as count FROM users');
    return {
      users: rows,
      total: parseInt(countRes.rows[0].count, 10),
    };
  }
}

module.exports = new UserRepository();
