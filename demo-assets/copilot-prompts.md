# Pre-Typed Copilot Chat Prompts
# ================================
# Copy-paste these during the live demo to avoid typos under pressure.
# Organized by presentation block.


# ─────────────────────────────────────────────
# BLOCK 2: Copilot — Writing Tests
# ─────────────────────────────────────────────

## 2.1 — Generate unit tests (type in the test file):
describe('UserService.register', () => {
  it('should

## 2.2 — Generate test data/fixtures (Copilot Chat):
Generate 10 realistic test users with varied edge cases for testing a registration endpoint. Include boundary values, unicode names, long emails, and special characters.

## 2.3 — Write E2E test (Copilot Chat):
Write a Playwright test for the user registration form at /register. Test successful registration with valid data, and verify validation errors appear for invalid inputs like short passwords and invalid emails.

## 2.4 — Explain existing test (Copilot Chat):
What does this test verify? Are there any gaps in the test coverage? What edge cases are missing?


# ─────────────────────────────────────────────
# BLOCK 3: Copilot — Code Review & Bug Analysis
# ─────────────────────────────────────────────

## 3.1 — Analyze the PR (Copilot Chat, with PaymentService-pr-diff.js open):
Review this code change. Could it introduce any race conditions?

## 3.2 — Edge case analysis (Copilot Chat):
What happens if the payment amount is zero after applying the discount? What about negative amounts?

## 3.3 — Generate regression test checklist (Copilot Chat):
What tests should I add to verify this PR doesn't break existing payment processing behavior? Give me a specific test checklist.


# ─────────────────────────────────────────────
# BLOCK 7: Copilot + GHAS Together
# ─────────────────────────────────────────────

## 7.1 — Explain the vulnerability (Copilot Chat, with search.js open):
Explain this SQL injection vulnerability and how an attacker could exploit it. Give me a specific example of a malicious input.

## 7.2 — Write a security test (Copilot Chat):
Write a test that verifies this SQL injection is properly prevented. Include test cases with common SQL injection payloads like ' OR 1=1 --, UNION SELECT, and DROP TABLE.

## 7.3 — Verify the fix (Copilot Chat, with search-fixed.js open):
Does this fix properly prevent SQL injection? Are there any remaining security concerns?
