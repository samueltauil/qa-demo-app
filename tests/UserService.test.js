const UserService = require('../src/services/UserService');
const { getDb } = require('../src/database');

// --- Partial test coverage (intentionally incomplete for Copilot demo) ---
// Missing: duplicate email, unicode names, long emails, password edge cases

describe('UserService', () => {
  beforeEach(() => {
    const db = getDb();
    db.exec('DELETE FROM users');
  });

  describe('register', () => {
    it('should register a new user with valid data', async () => {
      const user = await UserService.register({
        email: 'alice@example.com',
        password: 'securePass1',
        name: 'Alice Johnson'
      });

      expect(user).toHaveProperty('id');
      expect(user.email).toBe('alice@example.com');
      expect(user.name).toBe('Alice Johnson');
      expect(user).not.toHaveProperty('password');
      expect(user).not.toHaveProperty('password_hash');
    });

    it('should reject registration without an email', async () => {
      await expect(
        UserService.register({ password: 'securePass1', name: 'Bob' })
      ).rejects.toThrow('Email, password, and name are required');
    });

    it('should reject registration with invalid email format', async () => {
      await expect(
        UserService.register({ email: 'not-an-email', password: 'securePass1', name: 'Bob' })
      ).rejects.toThrow('Invalid email format');
    });

    
    // ⬇️  NOTICE: The following edge cases are NOT tested ⬇️
    //
    // - Duplicate email registration
    // - Password with exactly 8 characters (boundary)
    // - Password with no digits
    // - Name with 101 characters (boundary)
    // - Email with uppercase letters (should normalize)
    // - Unicode characters in name
    // - Very long email addresses
    // - Empty string inputs
    // - SQL injection attempts in inputs
    //
    // These gaps are intentional — Copilot will suggest them during the demo.
  });

// --- No tests for getById, login, or  updateProfile — intentional gaps for Copilot demo ---

  describe('getById', () => {
    it('should retrieve a user by ID', async () => {
      const created = await UserService.register({
        email: 'charlie@example.com',
        password: 'pass12345',
        name: 'Charlie'
      });

      const user = UserService.getById(created.id);
      expect(user.email).toBe('charlie@example.com');
      expect(user.name).toBe('Charlie');
    });

    it('should throw when user is not found', () => {
      expect(() => UserService.getById(99999)).toThrow('User not found');
    });
  });

  // NOTE: login() and updateProfile() have NO tests at all.
  // This is intentional for the Copilot demo — it will suggest these.
});
