// ============================================================
// Path traversal fix
// Compare with src/routes/files.js to see the vulnerability.
// ============================================================

const express = require('express');
const path = require('path');
const fs = require('fs');
const router = express.Router();

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

// GET /files/download?name=...
// FIXED: Validates that resolved path stays within UPLOADS_DIR
router.get('/download', (req, res) => {
  const fileName = req.query.name;

  if (!fileName) {
    return res.status(400).json({ error: 'File name is required' });
  }

  // ✅ FIXED — Resolve and validate path stays within uploads directory
  const filePath = path.resolve(UPLOADS_DIR, fileName);

  if (!filePath.startsWith(path.resolve(UPLOADS_DIR))) {
    return res.status(403).json({ error: 'Access denied' });
  }

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'File not found' });
  }

  res.download(filePath);
});

router.get('/', (req, res) => {
  if (!fs.existsSync(UPLOADS_DIR)) {
    fs.mkdirSync(UPLOADS_DIR, { recursive: true });
  }
  const files = fs.readdirSync(UPLOADS_DIR);
  res.json({ files });
});

module.exports = router;
