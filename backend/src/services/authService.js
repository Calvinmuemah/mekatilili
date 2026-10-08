const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_mekatilili_jwt_key_2026';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

class AuthService {
  async register({ email, username, password, displayName }) {
    const existingEmail = await userRepository.findByEmail(email);
    if (existingEmail) {
      const err = new Error('Email is already registered');
      err.code = 'EMAIL_EXISTS';
      err.statusCode = 409;
      throw err;
    }

    const existingUsername = await userRepository.findByUsername(username);
    if (existingUsername) {
      const err = new Error('Username is already taken');
      err.code = 'USERNAME_EXISTS';
      err.statusCode = 409;
      throw err;
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await userRepository.create({
      email,
      username,
      passwordHash,
      displayName: displayName || username,
    });

    const token = this.generateToken(user);
    return { user, token };
  }

  async login({ emailOrUsername, password }) {
    let user = await userRepository.findByEmail(emailOrUsername);
    if (!user) {
      user = await userRepository.findByUsername(emailOrUsername);
    }

    if (!user) {
      const err = new Error('Invalid credentials');
      err.code = 'INVALID_CREDENTIALS';
      err.statusCode = 401;
      throw err;
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      const err = new Error('Invalid credentials');
      err.code = 'INVALID_CREDENTIALS';
      err.statusCode = 401;
      throw err;
    }

    await userRepository.updateLastLogin(user.id);

    const safeUser = {
      id: user.id,
      email: user.email,
      username: user.username,
      display_name: user.display_name,
      is_active: user.is_active,
    };

    const token = this.generateToken(safeUser);
    return { user: safeUser, token };
  }

  generateToken(user) {
    return jwt.sign(
      { id: user.id, username: user.username, type: 'user' },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );
  }
}

module.exports = new AuthService();
