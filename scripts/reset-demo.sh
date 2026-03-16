#!/usr/bin/env bash
# =============================================================
# Reset the demo to a clean state before each presentation run.
#
# Usage:
#   ./scripts/reset-demo.sh
#
# Run this BEFORE each demo to restore everything to its
# starting state. It will:
#   1. Restore blank Copilot demo test files
#   2. Reset the database with fresh seed data
#   3. Restore the vulnerable source files on main
#   4. Verify tests pass
#
# This script does NOT touch GitHub (PRs, alerts stay as-is).
# =============================================================

set -euo pipefail
cd "$(dirname "$0")/.."

echo ""
echo "=== QA Demo App — Reset for Next Run ==="

# ── Step 0: Ensure clean git state ───────────────────────────
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo ""
  echo "[0/4] Recovering to main branch..."
  git checkout -- . 2>/dev/null || true
  git clean -fd 2>/dev/null || true
  git checkout main 2>/dev/null || git checkout -f main
  echo "  ✅ Switched to main"
fi

# Discard any uncommitted changes on main
git checkout -- . 2>/dev/null || true
git clean -fd 2>/dev/null || true

# Ensure dependencies are installed
if [ ! -d "node_modules" ]; then
  echo ""
  echo "[0/4] Installing dependencies..."
  npm install
fi

# ── Step 1: Restore blank demo test files ─────────────────────
echo ""
echo "[1/4] Restoring blank Copilot demo test files..."

cat > tests/UserService.copilot-demo.test.js << 'EOF'
// =============================================================
// 🎯 BLANK TEST FILE — for Copilot demo (Block 2, step 1)
//
// During the demo, open this file and start typing a describe
// block. Copilot will suggest test cases for UserService.
//
// Example starter (type this live):
//
//   describe('UserService.register', () => {
//     it('should
//
// Then let Copilot take over with suggestions.
// =============================================================

const UserService = require('../src/services/UserService');
const { getDb } = require('../src/database');

// Start typing your tests here during the demo...
EOF
echo "  ✅ tests/UserService.copilot-demo.test.js — restored to blank"

cat > tests/security.copilot-demo.test.js << 'EOF'
// =============================================================
// 🎯 BLANK TEST FILE — for Copilot security test demo
//    (Block 7, step 3 — "Write a security test")
//
// During the demo, ask Copilot:
//   "Write a test that verifies this SQL injection is properly
//    prevented"
// =============================================================

const request = require('supertest');
const app = require('../src/app');

// Start typing your security tests here during the demo...
EOF
echo "  ✅ tests/security.copilot-demo.test.js — restored to blank"

# ── Step 2: Restore vulnerable source files ───────────────────
echo ""
echo "[2/4] Ensuring vulnerable source files are intact..."

git checkout -- src/routes/search.js 2>/dev/null || true
git checkout -- src/routes/files.js 2>/dev/null || true
git checkout -- src/views/profile.ejs 2>/dev/null || true
git checkout -- src/services/PaymentService.js 2>/dev/null || true
echo "  ✅ Vulnerable source files restored from git"

# ── Step 3: Reset database ────────────────────────────────────
echo ""
echo "[3/4] Resetting database with fresh seed data..."

if [ -f "data/qa-demo.db" ]; then
  rm -f data/qa-demo.db
  echo "  Deleted old database"
fi

npm run seed
echo "  ✅ Database re-seeded"

# ── Step 4: Verify tests pass ─────────────────────────────────
echo ""
echo "[4/4] Running tests to verify clean state..."
if npm test 2>&1; then
  echo "  ✅ All tests pass"
else
  echo "  ⚠️  Some tests failed — check output above"
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "=== Reset Complete — Ready for Demo ==="
echo ""
echo "Checklist:"
echo "  [✅] Blank test files restored"
echo "  [✅] Vulnerable source files intact"
echo "  [✅] Database re-seeded with sample data"
echo "  [✅] Tests passing"
echo ""
echo "Next steps:"
echo "  1. Run: npm start"
echo "  2. Open VS Code with this folder"
echo "  3. Open Copilot Chat (Ctrl+Shift+I)"
echo "  4. Open presentation-guide.md on your second screen"
echo "  5. You're ready to present!"
echo ""
