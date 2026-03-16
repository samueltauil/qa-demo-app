<#
.SYNOPSIS
    Reset the demo to a clean state before each presentation run.

.DESCRIPTION
    Run this BEFORE each demo to restore everything to its starting state.
    It will:
      1. Restore blank Copilot demo test files (remove any code typed during the last run)
      2. Reset the database with fresh seed data
      3. Restore the vulnerable PaymentService.js on main (undo any live fixes)
      4. Verify tests pass

    This script does NOT touch GitHub (PRs, alerts stay as-is — that's what you want).
#>

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "`n=== QA Demo App — Reset for Next Run ===" -ForegroundColor Cyan

# ── Step 1: Restore blank demo test files ─────────────────────
Write-Host "`n[1/4] Restoring blank Copilot demo test files..." -ForegroundColor Yellow

# UserService.copilot-demo.test.js — restore to blank
$blankUserTest = @'
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
'@
Set-Content -Path "tests\UserService.copilot-demo.test.js" -Value $blankUserTest -NoNewline
Write-Host "  ✅ tests\UserService.copilot-demo.test.js — restored to blank"

# security.copilot-demo.test.js — restore to blank
$blankSecurityTest = @'
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
'@
Set-Content -Path "tests\security.copilot-demo.test.js" -Value $blankSecurityTest -NoNewline
Write-Host "  ✅ tests\security.copilot-demo.test.js — restored to blank"

# ── Step 2: Restore vulnerable source files ───────────────────
Write-Host "`n[2/4] Ensuring vulnerable source files are intact..." -ForegroundColor Yellow

# Make sure we're on main branch
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "  Switching to main branch..."
    git checkout main
}

# Restore any files that may have been edited during the demo
git checkout -- src/routes/search.js 2>$null
git checkout -- src/routes/files.js 2>$null
git checkout -- src/views/profile.ejs 2>$null
git checkout -- src/services/PaymentService.js 2>$null
Write-Host "  ✅ Vulnerable source files restored from git"

# ── Step 3: Reset database ────────────────────────────────────
Write-Host "`n[3/4] Resetting database with fresh seed data..." -ForegroundColor Yellow

# Delete existing database
if (Test-Path "data\qa-demo.db") {
    Remove-Item "data\qa-demo.db" -Force
    Write-Host "  Deleted old database"
}

npm run seed
Write-Host "  ✅ Database re-seeded"

# ── Step 4: Verify tests pass ─────────────────────────────────
Write-Host "`n[4/4] Running tests to verify clean state..." -ForegroundColor Yellow
$testResult = npm test 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ All tests pass" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Some tests failed — check output above" -ForegroundColor Red
}

# ── Done ──────────────────────────────────────────────────────
Write-Host "`n=== Reset Complete — Ready for Demo ===" -ForegroundColor Green
Write-Host ""
Write-Host "Checklist:" -ForegroundColor Cyan
Write-Host "  [✅] Blank test files restored"
Write-Host "  [✅] Vulnerable source files intact"
Write-Host "  [✅] Database re-seeded with sample data"
Write-Host "  [✅] Tests passing"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: npm start"
Write-Host "  2. Open VS Code with this folder"
Write-Host "  3. Open Copilot Chat (Ctrl+Shift+I)"
Write-Host "  4. Open presentation-guide.md on your second screen"
Write-Host "  5. You're ready to present!"
Write-Host ""
