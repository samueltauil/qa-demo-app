const express = require('express');
const router = express.Router();
const UserService = require('../services/UserService');

// POST /api/users/register
router.post('/register', async (req, res) => {
  try {
    const user = await UserService.register(req.body);
    res.status(201).json(user);
  } catch (err) {
    const status = err.message.includes('already exists') ? 409 : 400;
    res.status(status).json({ error: err.message });
  }
});

// POST /api/users/login
router.post('/login', async (req, res) => {
  try {
    const user = await UserService.login(req.body.email, req.body.password);
    res.json({ message: 'Login successful', user });
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
});

// GET /api/users/:id
router.get('/:id', (req, res) => {
  try {
    const user = UserService.getById(parseInt(req.params.id));
    res.json(user);
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

// GET /api/users
router.get('/', (req, res) => {
  const users = UserService.listAll();
  res.json(users);
});

module.exports = router;
