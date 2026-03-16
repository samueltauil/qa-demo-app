// ============================================================
// ⚠️  VULNERABLE — intentional SQL injection for CodeQL demo
//     (Block 5, step 2 — Code Scanning alert)
// ============================================================

const express = require('express');
const router = express.Router();
const { getDb } = require('../database');

// GET /search?q=...
// VULNERABLE: User input is concatenated directly into SQL query
router.get('/', (req, res) => {
  const query = req.query.q || '';

  if (!query) {
    return res.render('search', { results: [], query: '' });
  }

  try {
    const db = getDb();

    // ❌ VULNERABLE — SQL Injection via string concatenation
    const sql = "SELECT * FROM products WHERE name LIKE '%" + query + "%' OR description LIKE '%" + query + "%'";
    const results = db.prepare(sql).all();

    res.render('search', { results, query });
  } catch (err) {
    res.render('search', { results: [], query, error: err.message });
  }
});

module.exports = router;
