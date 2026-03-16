// ============================================================
// ⚠️  VULNERABLE — intentional path traversal for CodeQL demo
//     (Block 5, step 2 — Code Scanning alert)
// ============================================================

const express = require('express');
const path = require('path');
const fs = require('fs');
const router = express.Router();

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

// GET /files/download?name=...
// VULNERABLE: User-supplied filename is used without sanitization
router.get('/download', (req, res) => {
  const fileName = req.query.name;

  if (!fileName) {
    return res.status(400).json({ error: 'File name is required' });
  }

  // ❌ VULNERABLE — Path traversal: attacker can use ../../etc/passwd
  const filePath = path.join(UPLOADS_DIR, fileName);

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'File not found' });
  }

  res.download(filePath);
});

// GET /files — list available files
router.get('/', (req, res) => {
  if (!fs.existsSync(UPLOADS_DIR)) {
    fs.mkdirSync(UPLOADS_DIR, { recursive: true });
  }
  const files = fs.readdirSync(UPLOADS_DIR);
  res.json({ files });
});

module.exports = router;
