const request = require('supertest');
const app = require('../src/app');
const { getDb } = require('../src/database');

// Partial API integration tests — some gaps intentionally left

describe('User Registration API', () => {
  beforeEach(() => {
    const db = getDb();
    db.exec('DELETE FROM users');
  });

  it('POST /api/users/register — should create a user', async () => {
    const res = await request(app)
      .post('/api/users/register')
      .send({
        email: 'test@example.com',
        password: 'testPass123',
        name: 'Test User'
      });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.email).toBe('test@example.com');
  });

  it('POST /api/users/register — should return 400 for missing fields', async () => {
    const res = await request(app)
      .post('/api/users/register')
      .send({ email: 'test@example.com' });

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  // NOTE: No tests for:
  // - Duplicate email (409 response)
  // - Login endpoint
  // - GET /api/users/:id
  // - GET /api/users
});
