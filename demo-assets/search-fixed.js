// ============================================================
// SQL Injection fix for demo Block 7
// (Copilot + GHAS Together: Fixing a Vulnerability)
//
// This is the "developer's fix" that Alex verifies in the demo.
// Compare with src/routes/search.js to see the vulnerability.
// ============================================================

const express = require('express');
const router = express.Router();
const { getDb } = require('../database');

// GET /search?q=...
// FIXED: Uses parameterized query instead of string concatenation
router.get('/', (req, res) => {
  const query = req.query.q || '';

  if (!query) {
    return res.render('search', { results: [], query: '' });
  }

  try {
    const db = getDb();

    // ✅ FIXED — Parameterized query prevents SQL injection
    const sql = "SELECT * FROM products WHERE name LIKE ? OR description LIKE ?";
    const param = `%${query}%`;
    const results = db.prepare(sql).all(param, param);

    res.render('search', { results, query });
  } catch (err) {
    res.render('search', { results: [], query, error: err.message });
  }
});

module.exports = router;
