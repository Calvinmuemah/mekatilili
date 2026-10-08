const jwt = require('jsonwebtoken');
const { query } = require('../config/db');
const { error } = require('../utils/response');

async function authenticateUser(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return error(res, 'Authentication token required', 'UNAUTHORIZED', 401);
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'super_secret_mekatilili_jwt_key_2026');
    if (decoded.type !== 'user') {
      return error(res, 'Invalid token type for player access', 'FORBIDDEN', 403);
    }

    const { rows } = await query(
      'SELECT id, email, username, display_name, is_active FROM users WHERE id = $1',
      [decoded.id]
    );

    if (rows.length === 0 || !rows[0].is_active) {
      return error(res, 'User account inactive or not found', 'UNAUTHORIZED', 401);
    }

    req.user = rows[0];
    next();
  } catch (err) {
    return error(res, 'Invalid or expired token', 'UNAUTHORIZED', 401);
  }
}

async function authenticateAdmin(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return error(res, 'Administrator authentication required', 'UNAUTHORIZED', 401);
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'super_secret_mekatilili_jwt_key_2026');
    if (decoded.type !== 'admin') {
      return error(res, 'Invalid token type for admin access', 'FORBIDDEN', 403);
    }

    const { rows } = await query(
      'SELECT id, email, name, role, is_active FROM admins WHERE id = $1',
      [decoded.id]
    );

    if (rows.length === 0 || !rows[0].is_active) {
      return error(res, 'Administrator account inactive or not found', 'UNAUTHORIZED', 401);
    }

    req.admin = rows[0];
    next();
  } catch (err) {
    return error(res, 'Invalid or expired admin token', 'UNAUTHORIZED', 401);
  }
}

function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.admin) {
      return error(res, 'Admin authentication required', 'UNAUTHORIZED', 401);
    }
    if (!allowedRoles.includes(req.admin.role)) {
      return error(res, `Requires one of roles: [${allowedRoles.join(', ')}]`, 'FORBIDDEN', 403);
    }
    next();
  };
}

module.exports = {
  authenticateUser,
  authenticateAdmin,
  requireRole,
};
