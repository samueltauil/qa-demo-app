# GitHub Copilot & Advanced Security: A Day in the Life of QA

# 🎯 LIVE DEMO GUIDE — Read on Your Second Screen

> **How to use this guide:** Follow each numbered step in order. Every action is exact — which file to open, what to type, what to paste into Copilot Chat, and what to say out loud. No guessing required.

---

## Presentation Overview

| Detail | Value |
|--------|-------|
| **Duration** | 60 minutes |
| **Format** | Story-driven walkthrough + live demos |
| **Audience** | QA staff / leadership |
| **Narrative** | Follow "Alex," a QA engineer, through a typical workday |

---

## 🔧 Pre-Demo Setup (30 minutes before)

### If this is your first time ever:

**On Windows (PowerShell):**
```powershell
.\scripts\setup-demo.ps1 -RepoName "qa-demo-app"
# Labels & issues are created automatically on first push
# The project board is created by the setup script using your gh CLI auth
# Wait ~5 minutes for CodeQL alerts, Dependabot alerts, and secret scanning to populate
```

**On macOS/Linux (bash):**
```bash
./scripts/setup-demo.sh "qa-demo-app"
```

### Before every presentation run:

**On Windows (PowerShell):**
```powershell
.\scripts\reset-demo.ps1
```

**On macOS/Linux (bash):**
```bash
./scripts/reset-demo.sh
```

### Then verify:
- [ ] `npm install` → install dependencies (required after first clone or Node.js update)
- [ ] `npm run seed` → seed the database with sample data
- [ ] `npm start` → verify http://localhost:3000 loads in browser
- [ ] Open VS Code with the `demo-app` folder
- [ ] Open **Copilot Chat** panel in VS Code (Ctrl+Shift+I)
- [ ] Open browser tab 1: http://localhost:3000 → click through pages to verify
- [ ] Open browser tab 2: `github.com/{your-repo}/security` (Security overview)
- [ ] Open browser tab 3: `github.com/{your-repo}/projects` → open "QA Sprint Board — Alex's Tuesday"
- [ ] Run `npm test` → verify 12 tests pass (3 suites)
- [ ] Keep **this guide** open on your second screen
- [ ] Have a timer visible

---

## Timing Breakdown

| Block | Topic | Time | Type |
|-------|-------|------|------|
| 1 | Opening & Scene Setting | 5 min | Talk |
| 2 | Copilot: Writing Tests | 12 min | Demo-heavy |
| 3 | Copilot: Code Review & Bug Analysis | 8 min | Demo |
| 4 | Transition: "Security is Quality" | 2 min | Talk |
| 5 | GHAS: Code Scanning & Secret Scanning | 12 min | Demo-heavy |
| 6 | GHAS: Dependabot & Supply Chain | 8 min | Demo |
| 7 | Copilot + GHAS Together: Fixing a Vulnerability | 8 min | Demo |
| 7.5 | Project Management: The Full Picture | 3 min | Demo |
| 8 | Wrap-up & Q&A | 5 min | Discussion |

---

---

# Block 1: Opening & Scene Setting (5 min) 🎙️ TALK ONLY

> No demo — just talk.

### Say This:
1. *"Today we're going to follow Alex, a QA engineer, through a typical day."*
2. Quick poll: *"How many of you write automated tests? How many review PRs for security?"*
3. Set the frame: *"Quality and Security are two sides of the same coin — QA is uniquely positioned to own both."*
4. *"We'll see two GitHub tools that transform how QA works — Copilot for productivity and Advanced Security for shifting security left."*

### Key Message:
> *"QA doesn't just find bugs anymore. QA is the last line of defense before code reaches customers — and these tools make that defense dramatically stronger."*

---

---

# Block 2: Copilot — Writing Tests (12 min) 🖥️ DEMO

### Say This First:
*"Alex opens the project board and picks up the first issue in the backlog: 'Add test coverage for user registration endpoint.' Instead of writing tests from scratch, Alex uses Copilot."*

> **Optional:** Switch to browser → GitHub.com → Projects → "QA Sprint Board — Alex's Tuesday" and click the "Add test coverage for user registration endpoint" card to show the issue before switching to VS Code.

---

### Step 2.1 — Generate Unit Tests from a Function (3 min)

**① Open this file in VS Code:**
```
src/services/UserService.js
```
> Scroll to the `register()` method (line 17). Show the audience the function signature, parameters, and validation logic (lines 17-58). Point out: email validation, password length check, digit requirement, name length limit, duplicate email check.

**② Open this file in a new tab:**
```
tests/UserService.copilot-demo.test.js
```
> This is a blank test file (line 18 says `// Start typing your tests here during the demo...`).

**③ Place your cursor on line 18 and type this live:**
```javascript
describe('UserService.register', () => {
  it('should
```
> **STOP TYPING and wait** — Copilot will autocomplete with test case suggestions.

**④ Accept 3-4 suggestions** by pressing Tab. Show the audience how Copilot infers edge cases like null input, duplicate email, and password validation.

**🗣️ Say:** *"Notice it understood the business logic — it's not just generating boilerplate."*

---

### Step 2.2 — Generate Test Data/Fixtures (3 min)

**① Open Copilot Chat and paste this prompt:**
```
Generate 10 realistic test users with varied edge cases for testing a registration endpoint. Include boundary values, unicode names, long emails, and special characters.
```

**② Show the output** — Copilot will produce test users with:
- Unicode names (e.g., 山田太郎)
- Names at the 100-char boundary (the limit in `UserService.js` line 41)
- Passwords at the 8-char minimum (the limit on line 33)
- Passwords with no digits (should fail — line 36)
- Mixed-case and very long emails
- SQL injection attempts in fields

**🗣️ Say:** *"Test data generation is one of the biggest time sinks in QA — Copilot handles it in seconds."*

---

### Step 2.3 — Write an E2E Test with Playwright (3 min)

**① Open this file in VS Code:**
```
e2e/registration.spec.js
```
> Show the existing partial test (lines 13-23) — it only checks that the form elements are visible.

**② Place your cursor on line 25** (where the comment says `// ⬇️ Ask Copilot to generate more E2E tests here during the demo`).

**③ Open Copilot Chat and paste this prompt:**
```
Write a Playwright test for the user registration form at /register. Test successful registration with valid data, and verify validation errors appear for invalid inputs like short passwords and invalid emails.
```

> Copilot will generate tests using `page.goto('/register')`, `page.locator('#name')`, `page.locator('#email')`, etc. — matching the real form selectors in `src/views/register.ejs`.

**🗣️ Say:** *"It knows the testing framework conventions — you write the intent, it writes the implementation."*

> **BONUS** — if time permits, paste any of these from line 27-29 of `registration.spec.js`:
> - `Add a test for successful registration with valid data`
> - `Add a test that verifies validation errors for short passwords`
> - `Add a test for duplicate email registration`

---

### Step 2.4 — Explain and Improve Existing Tests (3 min)

**① Open this file in VS Code:**
```
tests/PaymentService.test.js
```
> This is a complex, hard-to-read test file (68 lines). Scroll through it — it tests payment processing and refunds.

**② Select ALL the code (Ctrl+A) and open Copilot Chat. Paste this prompt:**
```
What does this test verify? Are there any gaps in the test coverage? What edge cases are missing?
```

**③ Show Copilot's response** — it should identify the gaps listed in lines 75-88 of that file:
- Amount = 0
- Very large amounts exceeding the max limit
- Non-numeric amounts (string, null, undefined)
- Double refund prevention
- Payment for non-existent user
- Currency validation
- `getPaymentsByUser()` not tested
- `getTotalRevenue()` not tested

**🗣️ Say:** *"This is invaluable when onboarding new team members or reviewing inherited test suites."*

> **ALTERNATIVE** — You can also open `tests/UserService.test.js` and highlight it. The gaps are listed in lines 44-54: duplicate email, password boundary cases, unicode names, empty strings, SQL injection.

---

---

# Block 3: Copilot — QA Code Review & Issue Tracking (8 min) 🖥️ DEMO

### Say This First:
*"Alex's morning continues with PR reviews. On the project board, there's a QA task: 'Review PR — Discount code support for payments.' Let's see how a QA engineer uses Copilot to handle this end-to-end."*

---

### Step 3.1 — Start from the QA Issue (1 min)

**① On GitHub.com, open the project board and click the issue: "Review PR: Discount code support for payments"**

> Show the issue body — it has a QA checklist (race conditions, zero-amount, expired codes) and a link to the PR.

**🗣️ Say:** *"This is Alex's task — a structured QA review checklist created when the PR was opened. Let's use a custom Copilot agent to do the review and update this issue automatically."*

---

### Step 3.2 — Run the QA PR Reviewer Agent (5 min)

**① In VS Code / Codespaces, open Copilot Chat and select the `pr-reviewer` agent from the agent picker.**

> This is a custom agent defined in `.github/agents/pr-reviewer.agent.md` — it reviews PRs from a QA perspective and updates the linked issue.

**② Type this single prompt:**
```
Review the payment discount PR and update the linked QA issue with your findings
```

**③ Watch the agent work** — it will:
1. Read the PR diff (payment processing changes)
2. Analyze from a QA perspective — regression risk, edge cases, security
3. Post a QA code review on the PR via `gh` CLI
4. Find the linked QA issue ("Review PR: Discount code support")
5. Post a QA summary comment on the issue with findings and checklist status
6. Add the `reviewed` label to the issue

**🗣️ Say:** *"One prompt — and the agent did a complete QA workflow. It reviewed the PR, found the bugs (the date comparison issue, the zero-amount edge case), posted the review, and then went back and updated the QA issue with its findings. The issue now has a full audit trail."*

> **Show both on GitHub.com:**
> 1. The PR's "Files changed" tab — show the review with inline comments
> 2. The QA issue — show the comment the agent posted with findings and checklist

---

### Step 3.3 — Highlight the Custom Agent & Copilot Features (2 min)

**① Open `.github/agents/pr-reviewer.agent.md` in VS Code to show the audience how it's built.**

**🗣️ Say:** *"This agent is a markdown file in the repo. It defines the QA review process — what to look for, how to post the review, and how to update the issue. Any team can customize this with their own standards."*

> **Key Copilot features to highlight for QA teams:**
> - **Custom agents** — encode your QA review process as a reusable agent
> - **PR reviews** — Copilot analyzes diffs for bugs, edge cases, security issues
> - **Issue updates** — the agent closes the loop by updating the QA task with findings
> - **`gh` CLI integration** — uses `gh` CLI for all write operations, works in Codespaces, local VS Code, or any terminal
> - **Copilot in GitHub.com** — can also assign `@copilot` as a PR reviewer directly from the PR page

**🗣️ Say:** *"The QA team gets a full audit trail — from issue to review to findings — all automated. Instead of context-switching between the issue, the PR, and a spreadsheet, everything stays connected."*

---

---

# Block 4: Transition — "Security is Quality" (2 min) 🎙️ TALK ONLY

> No demo — just talk. Bridge from Copilot to GHAS.

### Say This:
1. *"Alex has been productive all morning — tests written, PRs reviewed. But there's another dimension to quality that QA teams are increasingly responsible for: security."*
2. *"A bug that lets users register with invalid emails is a quality issue. A bug that lets attackers inject SQL through the registration form is a security issue. The skills to find both are the same."*
3. *"GitHub Advanced Security brings security directly into the workflows Alex already uses."*

### Key Message:
> *"You don't need to become a security expert. GHAS brings security expertise to you, right where you already work."*

---

---

# Block 5: GHAS — Code Scanning & Secret Scanning (12 min) 🖥️ DEMO

### Say This First:
*"After lunch, Alex gets a Slack notification: 'Code scanning found 2 new alerts on the main branch.'"*

---

### Step 5.1 — Security Overview Dashboard (2 min)

**① Switch to browser → GitHub.com → your repo → Security tab**

> Show the security overview dashboard: open alerts by severity, trends over time.

**🗣️ Say:** *"This is your security posture at a glance — QA leadership can track this the same way you track test coverage."*

---

### Step 5.2 — CodeQL Alerts: SQL Injection (4 min)

**① In the Security tab, click on the SQL injection CodeQL alert.**

> Walk through:
> - The alert title (SQL injection)
> - The CWE reference
> - The **data flow visualization** — trace from `req.query.q` to the SQL string

**② To show the vulnerable source code, open this file in VS Code:**
```
src/routes/search.js
```
> Line 16 has the vulnerability — SQL injection via string concatenation:
> ```javascript
> const sql = "SELECT * FROM products WHERE name LIKE '%" + query + "%' OR description LIKE '%" + query + "%'";
> ```
> The user input `req.query.q` (line 12) flows directly into the SQL string without parameterization.

**🗣️ Say:** *"CodeQL doesn't just find the bug — it shows you the path the data takes. This is exactly the kind of analysis QA does when writing test cases."*

> **Also mention:** There are more CodeQL alerts ready in the repo:
> - **Path Traversal** (x2) in `src/routes/files.js` line 23: `path.join(UPLOADS_DIR, fileName)` without validation
> - **Polynomial ReDoS** in `src/services/UserService.js`: email regex can cause catastrophic backtracking
> - **Missing Rate Limiting** (x6) across multiple routes

---

### Step 5.3 — Code Scanning in Action (2 min)

**① On GitHub.com → Security → Code scanning alerts → click the SQL injection alert → click "Show paths"**

> Walk through the **data flow path** — CodeQL traces user input from `req.query.q` through string concatenation into the SQL query. This is the same kind of taint analysis that security engineers perform manually.

**② (Optional) Show inline annotations on a PR:**
> Open the payment discount PR ("feat: Add discount code support") → click the **Checks** tab → you'll see CodeQL ran on the PR. If CodeQL found alerts on the branch, they appear as annotations inline on the Files Changed tab.

**🗣️ Say:** *"CodeQL runs on every PR and every push to main. Issues are flagged before they merge — before QA even has to test them. It's shift-left in action."*

---

### Step 5.4 — Secret Scanning (4 min)

**① In GitHub.com → Security → Secret scanning alerts**

> Show the alert for the AWS key. The hardcoded secret is in `src/config.js` lines 13-14:
> ```
> accessKeyId: 'AKIAIOSFODNN7EXAMPLE'
> secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
> ```

**② (Optional) Demo push protection:**
> In a terminal, try to commit a file containing `AKIAIOSFODNN7EXAMPLE` and push it.
> Show the push being blocked by GitHub's push protection.

**🗣️ Say:** *"How many of you have found credentials in config files during testing? Secret scanning catches these automatically — and push protection stops them from entering the repo at all."*

---

---

# Block 6: GHAS — Dependabot & Supply Chain (8 min) 🖥️ DEMO

### Say This First:
*"Alex reviews the weekly Dependabot digest — 3 dependency alerts came in overnight."*

---

### Step 6.1 — Dependabot Alerts Dashboard (3 min)

**① In GitHub.com → Security → Dependabot alerts**

> Show the alerts for the intentionally vulnerable dependencies in `package.json`:
> - `lodash@4.17.20` — has known prototype pollution CVEs
> - `axios@0.21.1` — has known SSRF/redirect CVEs
>
> Open one alert. Show: CVE ID, affected versions, fixed version available.

**🗣️ Say:** *"QA teams already track known issues — Dependabot is doing the same thing for your dependencies."*

---

### Step 6.2 — Auto-Generated Dependabot PR (3 min)

**① Show a Dependabot PR** that bumps `lodash` or `axios` to a safe version.

> Point out: the compatibility score, the changelog summary, and that the fix is already built.

**🗣️ Say:** *"The fix is pre-built — QA's job becomes validating the update doesn't break anything, not finding the vulnerability."*

---

### Step 6.3 — Dependency Review Action on PRs (2 min)

**① Show the workflow config at:**
```
.github/workflows/dependency-review.yml
```
> Explain: this runs on every PR and blocks any new dependency with moderate+ severity or GPL-3.0/AGPL-3.0 licenses.

**② Show a PR where the dependency review check ran** (on GitHub.com → PR → Checks tab).

**🗣️ Say:** *"This prevents new vulnerabilities from entering through the front door — a developer adds a bad package, and the PR is flagged before QA ever sees it."*

---

---

# Block 7: The Power Combo — Copilot + GHAS Together (8 min) 🖥️ DEMO

### Say This First:
*"Alex's best moment of the day: a CodeQL alert found a SQL injection vulnerability. Now Alex needs to verify the fix. This is where both tools shine together."*

---

### Step 7.1 — Start with the CodeQL Alert (1 min)

**① Show the SQL injection CodeQL alert** (same as Block 5, step 2 — on GitHub.com or reference the data flow).

> Quick reminder to audience: the vulnerability is in `src/routes/search.js` line 16 — user input concatenated into SQL.

---

### Step 7.2 — Ask Copilot to Explain the Vulnerability (2 min)

**① Open this file in VS Code:**
```
src/routes/search.js
```

**② Select the vulnerable code (lines 12-17) and open Copilot Chat. Paste this prompt:**
```
Explain this SQL injection vulnerability and how an attacker could exploit it. Give me a specific example of a malicious input.
```

**③ Show Copilot's response** — it will generate an exploitation scenario, e.g.:
- Input: `' OR 1=1 --`
- Input: `' UNION SELECT * FROM users --`
- Explanation of how the string concatenation allows injected SQL to execute

**🗣️ Say:** *"QA now has an instant attack scenario to test against."*

---

### Step 7.3 — Use Copilot to Write a Security Test (3 min)

**① Open this file in VS Code:**
```
tests/security.copilot-demo.test.js
```
> This is a blank security test file (line 13 says `// Start typing your security tests here during the demo...`). It already has `supertest` and the `app` imported.

**② Open Copilot Chat and paste this prompt:**
```
Write a test that verifies this SQL injection is properly prevented. Include test cases with common SQL injection payloads like ' OR 1=1 --, UNION SELECT, and DROP TABLE.
```

**③ Show Copilot generating test code** with malicious payloads like:
```javascript
const payloads = [
  "' OR 1=1 --",
  "'; DROP TABLE products; --",
  "' UNION SELECT * FROM users --"
];
```

**🗣️ Say:** *"This is the multiplier — GHAS finds the issue, Copilot helps QA write the regression test to make sure it never comes back."*

---

### Step 7.4 — Verify the Fix (2 min)

**① Open the developer's fix file in VS Code:**
```
demo-assets/search-fixed.js
```
> Show the fix at lines 27-29 — the parameterized query:
> ```javascript
> const sql = "SELECT * FROM products WHERE name LIKE ? OR description LIKE ?";
> const param = `%${query}%`;
> const results = db.prepare(sql).all(param, param);
> ```
> Compare with the vulnerable version in `src/routes/search.js` line 16.

**② (Optional) Paste this into Copilot Chat to verify the fix:**
```
Does this fix properly prevent SQL injection? Are there any remaining security concerns?
```

**③ (Optional) Run the Copilot-generated security test** against the fixed code and show it passing.

**🗣️ Say:** *"The entire flow — find, understand, test, verify — happened in one afternoon."*

### Key Message:
> *"Copilot makes you faster. GHAS makes you safer. Together, they make QA the most impactful team in the organization."*

---

---

# Block 7.5: Project Management — The Full Picture (3 min) 🖥️ DEMO

### Say This First:
*"Before we wrap up, let me show you how all of this ties together from a project management perspective. Alex doesn't just work in isolation — every task we saw today lives on a kanban board that the whole team can see."*

---

### Step 7.5.1 — Show the Project Board (1 min)

**① Switch to browser → GitHub.com → Projects tab → "QA Sprint Board — Alex's Tuesday"**

> Show the kanban board with columns: **Todo**, **In Progress**, **Done**.
> The board was created by the setup script with 6 issues and 2 PRs.

Point out the cards:

| Column | Card | Maps to Demo Block |
|--------|------|--------------------|
| **Todo** | "Add test coverage for user registration endpoint" | Block 2 — Copilot wrote these tests |
| **Todo** | "Write security regression test for SQL injection fix" | Block 7 — Copilot + GHAS together |
| **In Progress** | "Review PR: Discount code support for payments" | Block 3 — Copilot code review |
| **In Progress** | "Triage CodeQL security alerts on main branch" | Block 5 — GHAS code scanning |
| Cards also | "Investigate secret scanning alert" | Block 5 — Secret scanning |
| Cards also | "Validate Dependabot dependency updates" | Block 6 — Dependabot |

**🗣️ Say:** *"Every task Alex worked on today is tracked here. QA leadership gets full visibility — what's been triaged, what's in progress, what's done."*

---

### Step 7.5.2 — Show Issue ↔ PR Links (1 min)

**① Click on the "Review PR: Discount code support" issue card**

> Show how the issue links to PR #1 (the payment discount PR from Block 3).
> The PR has Copilot's review comments, the code diff, and the CI checks.

**🗣️ Say:** *"The issue, the PR, the code review, the security checks — it's all connected. Click any card and you see the full context."*

---

### Step 7.5.3 — Drag a Card to Done (1 min)

**① Drag the "Add test coverage for user registration endpoint" card from Todo → Done**

> This is the task Alex completed in Block 2 using Copilot.

**② (Optional) Drag "Triage CodeQL security alerts" from In Progress → Done**

> This is the task Alex completed in Block 5.

**🗣️ Say:** *"As Alex completes each task — writing tests, triaging alerts, verifying fixes — the board updates. At the end of the day, leadership sees exactly what was accomplished and what's still open."*

### Key Message:
> *"This isn't just about individual productivity. It's about giving the whole team — QA engineers, leads, and management — a shared view of quality and security work, tracked right alongside the code."*

---

---

# Block 8: Wrap-Up & Q&A (5 min) 🎙️ TALK ONLY

### Summary Points:
- **Copilot for QA:** Write tests faster, review code smarter, generate test data instantly
- **GHAS for QA:** Catch vulnerabilities before they ship, automate dependency management, protect secrets
- **Together:** A complete quality + security workflow inside GitHub
- **Project Board:** Full visibility for QA leadership — every task tracked from issue to done

### Closing Statement:
> *"Alex's day used to be: write tests manually, review PRs line-by-line, and hope security issues get caught in penetration testing. Now it's: generate tests in minutes, get AI-assisted reviews, and have vulnerabilities surfaced automatically. The time QA saves goes into what humans do best — creative exploratory testing and critical thinking."*

### Q&A Prompts (if the room is quiet):
- *"What part of your current testing workflow takes the most time?"*
- *"Have you ever found a security issue during testing? How long did it take to trace?"*
- *"What would you do with an extra 2 hours per day?"*

---

---

# 📋 Quick Reference — All Copilot Chat Prompts

Copy-paste these during the demo. Organized by block.

### Block 2 — Writing Tests
| Step | Prompt |
|------|--------|
| 2.1 | *(Type in editor, don't paste in Chat)* `describe('UserService.register', () => {` then `it('should` |
| 2.2 | `Generate 10 realistic test users with varied edge cases for testing a registration endpoint. Include boundary values, unicode names, long emails, and special characters.` |
| 2.3 | `Write a Playwright test for the user registration form at /register. Test successful registration with valid data, and verify validation errors appear for invalid inputs like short passwords and invalid emails.` |
| 2.4 | `What does this test verify? Are there any gaps in the test coverage? What edge cases are missing?` |

### Block 3 — Code Review
| Step | Prompt |
|------|--------|
| 3.2a | `Review this code change. Could it introduce any race conditions?` |
| 3.2b | `What happens if the payment amount is zero after applying the discount? What about negative amounts?` |
| 3.3 | `What tests should I add to verify this PR doesn't break existing payment processing behavior? Give me a specific test checklist.` |

### Block 7 — Copilot + GHAS Together
| Step | Prompt |
|------|--------|
| 7.2 | `Explain this SQL injection vulnerability and how an attacker could exploit it. Give me a specific example of a malicious input.` |
| 7.3 | `Write a test that verifies this SQL injection is properly prevented. Include test cases with common SQL injection payloads like ' OR 1=1 --, UNION SELECT, and DROP TABLE.` |
| 7.4 | `Does this fix properly prevent SQL injection? Are there any remaining security concerns?` |

---

# 📂 Quick Reference — Files to Open per Block

| Block | File to Open | What's There |
|-------|-------------|--------------|
| 2.1 | `src/services/UserService.js` | The `register()` method — show function signature |
| 2.1 | `tests/UserService.copilot-demo.test.js` | Blank test file — type here live |
| 2.2 | *(Copilot Chat only)* | Paste test data prompt |
| 2.3 | `e2e/registration.spec.js` | Partial E2E test — Copilot extends it |
| 2.4 | `tests/PaymentService.test.js` | Complex test — Copilot finds gaps (lines 75-88) |
| 2.4 alt | `tests/UserService.test.js` | Partial tests — gaps listed at lines 44-54 |
| 3.1 | `demo-assets/pr-description.md` | PR description for review |
| 3.2 | `demo-assets/PaymentService-pr-diff.js` | PR code diff with bugs (lines 39-44) |
| 5.2 | `src/routes/search.js` | SQL injection vulnerability (line 16) |
| 5.2 | `src/views/profile.ejs` | XSS vulnerability (line 30) |
| 5.2 | `src/routes/files.js` | Path traversal vulnerability (line 23) |
| 5.4 | `src/config.js` | Hardcoded AWS key (lines 13-14) |
| 6.3 | `.github/workflows/dependency-review.yml` | Dependency review config |
| 7.2 | `src/routes/search.js` | SQL injection to explain |
| 7.3 | `tests/security.copilot-demo.test.js` | Blank security test file |
| 7.4 | `demo-assets/search-fixed.js` | The parameterized query fix (lines 16-19) |
| 7.5 | GitHub.com → Projects tab | "QA Sprint Board — Alex's Tuesday" kanban board |

---

# 🛟 Plan B — If a Live Demo Fails

- **Copilot not responding?** → Show the expected output verbally: "Copilot would suggest tests for null input, duplicate emails, and password validation."
- **GitHub.com down?** → Take screenshots during setup using the list in `demo-assets/backup-screenshots-guide.md` (19 screenshots covering every step).
- **Tests fail unexpectedly?** → Run `npm run seed` to reset the database, then `npm test` again.
- **CodeQL alerts missing?** → Ensure you pushed to `main` and the CodeQL workflow ran at least once (check `.github/workflows/codeql.yml`).
