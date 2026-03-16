// ============================================================
// ⚠️  The profile view (profile.ejs) contains an intentional
//     XSS vulnerability for the CodeQL demo.
// ============================================================

const express = require('express');
const router = express.Router();
const UserService = require('../services/UserService');

// GET /profile/:id
router.get('/:id', (req, res) => {
  try {
    const user = UserService.getById(parseInt(req.params.id));
    res.render('profile', { user });
  } catch (err) {
    res.status(404).render('error', { message: 'User not found' });
  }
});

module.exports = router;
