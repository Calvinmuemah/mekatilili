const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const adminRepository = require('../repositories/adminRepository');

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_mekatilili_jwt_key_2026';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

class AdminAuthService {
  async login({ email, password }) {
    const admin = await adminRepository.findByEmail(email);
    if (!admin || !admin.is_active) {
      const err = new Error('Invalid administrator credentials');
      err.code = 'INVALID_CREDENTIALS';
      err.statusCode = 401;
      throw err;
    }

    const valid = await bcrypt.compare(password, admin.password_hash);
    if (!valid) {
      const err = new Error('Invalid administrator credentials');
      err.code = 'INVALID_CREDENTIALS';
      err.statusCode = 401;
      throw err;
    }

    const safeAdmin = {
      id: admin.id,
      email: admin.email,
      name: admin.name,
      role: admin.role,
      is_active: admin.is_active,
    };

    const token = jwt.sign(
      { id: admin.id, email: admin.email, role: admin.role, type: 'admin' },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    return { admin: safeAdmin, token };
  }
}

module.exports = new AdminAuthService();
