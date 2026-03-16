const bcrypt = require('bcrypt');
const { getDb } = require('../database');

class UserService {
  /**
   * Register a new user account.
   *
   * @param {object} userData
   * @param {string} userData.email    — must be a valid email address
   * @param {string} userData.password — minimum 8 characters, must contain a number
   * @param {string} userData.name     — user's display name (1-100 chars)
   * @returns {object} The newly created user (without password hash)
   * @throws {Error} If validation fails or email already exists
   */
  static async register({ email, password, name }) {
    // --- Input validation ---
    if (!email || !password || !name) {
      throw new Error('Email, password, and name are required');
    }

    // Email format check
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new Error('Invalid email format');
    }

    // Password strength
    if (password.length < 8) {
      throw new Error('Password must be at least 8 characters');
    }
    if (!/\d/.test(password)) {
      throw new Error('Password must contain at least one number');
    }

    // Name length
    if (name.length > 100) {
      throw new Error('Name must be 100 characters or fewer');
    }

    // --- Check for duplicate email ---
    const db = getDb();
    const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email.toLowerCase());
    if (existing) {
      throw new Error('An account with this email already exists');
    }

    // --- Create the user ---
    const passwordHash = await bcrypt.hash(password, 10);
    const result = db.prepare(
      'INSERT INTO users (email, password_hash, name) VALUES (?, ?, ?)'
    ).run(email.toLowerCase(), passwordHash, name);

    return {
      id: result.lastInsertRowid,
      email: email.toLowerCase(),
      name,
      createdAt: new Date().toISOString()
    };
  }

  /**
   * Authenticate a user by email and password.
   */
  static async login(email, password) {
    if (!email || !password) {
      throw new Error('Email and password are required');
    }

    const db = getDb();
    const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email.toLowerCase());

    if (!user) {
      throw new Error('Invalid email or password');
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      throw new Error('Invalid email or password');
    }

    return { id: user.id, email: user.email, name: user.name };
  }

  /**
   * Get user by ID.
   */
  static getById(id) {
    const db = getDb();
    const user = db.prepare('SELECT id, email, name, bio, created_at FROM users WHERE id = ?').get(id);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  }

  /**
   * Update a user's profile.
   */
  static updateProfile(id, { name, bio }) {
    const db = getDb();
    db.prepare('UPDATE users SET name = ?, bio = ? WHERE id = ?').run(name, bio, id);
    return UserService.getById(id);
  }

  /**
   * List all users (admin).
   */
  static listAll() {
    const db = getDb();
    return db.prepare('SELECT id, email, name, created_at FROM users').all();
  }
}

module.exports = UserService;
