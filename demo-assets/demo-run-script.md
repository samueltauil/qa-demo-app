# Demo Run Script — Step-by-Step
# ================================
# Follow this checklist during the presentation.
# Each block corresponds to a section in the presentation guide.


## Pre-Demo Setup (do this 30 min before)

- [ ] `cd demo-app && npm install`
- [ ] `npm run seed` — verify "Database seeded successfully" message
- [ ] `npm start` — verify http://localhost:3000 loads
- [ ] Open VS Code with the demo-app folder
- [ ] Open Copilot Chat panel in VS Code
- [ ] Open browser to http://localhost:3000 and verify pages work
- [ ] Open a second browser tab to github.com/{your-repo}/security
- [ ] Have this file and `copilot-prompts.md` open in a side editor for easy copy-paste
- [ ] Run `npm test` once to verify existing tests pass (should be 5-6 passing)


---


## Block 1: Opening & Scene Setting (5 min) — TALK ONLY

No demo needed. Tell Alex's story.


---


## Block 2: Copilot — Writing Tests (12 min)

### Step 2.1: Generate unit tests
1. Open `src/services/UserService.js` — show the `register()` method
2. Open `tests/UserService.copilot-demo.test.js` (the blank test file)
3. Start typing: `describe('UserService.register', () => {`
4. Then type: `it('should` — let Copilot autocomplete
5. Accept 3-4 suggestions, show how it finds edge cases
6. **Talk:** "Notice it understood the business logic"

### Step 2.2: Generate test data
1. In Copilot Chat, paste from `copilot-prompts.md` → section 2.2
2. Show the generated test users with boundary values
3. **Talk:** "Test data generation in seconds"

### Step 2.3: Write E2E test
1. Open `e2e/registration.spec.js` — show the existing partial test
2. In Copilot Chat, paste prompt from section 2.3
3. Show Copilot generating Playwright test code
4. **Talk:** "It knows the testing framework conventions"

### Step 2.4: Explain existing test
1. Highlight the tests in `tests/UserService.test.js`
2. In Copilot Chat, paste prompt from section 2.4
3. Show Copilot identifying the missing edge cases listed in the comments
4. **Talk:** "Invaluable for onboarding and inherited test suites"


---


## Block 3: Copilot — Code Review (8 min)

### Step 3.1: PR summary
1. If using GitHub.com: show Copilot-generated PR summary
2. If local: open `demo-assets/pr-description.md` as the PR context

### Step 3.2: Ask about the code
1. Open `demo-assets/PaymentService-pr-diff.js`
2. Paste prompt from section 3.1 (race conditions)
3. Then paste from section 3.2 (zero amount)
4. **Talk:** "Like having a senior engineer pair-reviewing with you"

### Step 3.3: Generate review tests
1. Paste prompt from section 3.3
2. Show the regression test checklist Copilot generates
3. **Talk:** "A targeted list instead of guessing"


---


## Block 4: Transition — "Security is Quality" (2 min) — TALK ONLY

Bridge from Copilot to GHAS. Key line:
> "A bug with invalid emails is quality. SQL injection is security. Same skills to find both."


---


## Block 5: GHAS — Code Scanning & Secret Scanning (12 min)

### Step 5.1: Security dashboard
1. In GitHub.com, navigate to repo → Security tab
2. Show the overview dashboard with alerts by severity

### Step 5.2: CodeQL alerts
1. Open the SQL injection alert (from `src/routes/search.js`)
2. Walk through: vulnerable code, data flow, CWE reference
3. Show data flow visualization
4. **Talk:** "Shows the *path* the data takes"

### Step 5.3: Alert in a PR
1. Show a PR diff with inline CodeQL annotation
2. **Talk:** "Catches issues *before* they merge"

### Step 5.4: Secret scanning
1. Navigate to Security → Secret scanning alerts
2. Show the AWS key alert from `src/config.js`
3. (Optional) Demo push protection:
   - Create a test commit with `AKIAIOSFODNN7EXAMPLE`
   - Show the push being blocked
4. **Talk:** "Push protection stops secrets from entering the repo"


---


## Block 6: GHAS — Dependabot (8 min)

### Step 6.1: Dependabot alerts
1. Navigate to Security → Dependabot alerts
2. Show alerts for `lodash@4.17.20` and `axios@0.21.1`
3. Open one, show CVE, affected versions, fix path

### Step 6.2: Dependabot PR
1. Show a Dependabot PR that bumps lodash or axios
2. Show compatibility score and changelog
3. **Talk:** "The fix is pre-built — QA validates, doesn't hunt"

### Step 6.3: Dependency review
1. Show `.github/workflows/dependency-review.yml` config
2. Show a PR where the dependency review check ran
3. **Talk:** "Prevents bad packages from the front door"


---


## Block 7: Copilot + GHAS Together (8 min)

### Step 7.1: Start with CodeQL alert
1. Show the SQL injection alert (same as 5.2 if needed)

### Step 7.2: Ask Copilot to explain
1. Open `src/routes/search.js` in VS Code
2. Paste prompt from section 7.1
3. Show Copilot generating an exploitation scenario
4. **Talk:** "Instant attack scenario to test against"

### Step 7.3: Write security test
1. Open `tests/security.copilot-demo.test.js`
2. Paste prompt from section 7.2
3. Show Copilot generating tests with SQL injection payloads
4. **Talk:** "GHAS finds, Copilot helps QA write the regression test"

### Step 7.4: Verify the fix
1. Open `demo-assets/search-fixed.js` — show the parameterized query
2. Paste prompt from section 7.3
3. Run the generated test against the fix
4. Show it passing
5. **Talk:** "Find, understand, test, verify — one afternoon"


---


## Block 8: Wrap-Up & Q&A (5 min) — TALK ONLY

Summary & closing statement. Use Q&A prompts if room is quiet:
- "What part of your workflow takes the most time?"
- "Have you ever found a security issue during testing?"
- "What would you do with an extra 2 hours per day?"
