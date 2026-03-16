#!/usr/bin/env bash
# =============================================================
# First-time setup for the QA Demo App presentation repo.
# Creates the GitHub repo, branches, PRs, project board, and
# issues needed for the demo.
#
# Usage:
#   ./scripts/setup-demo.sh <repo-name> [org]
#
# Examples:
#   ./scripts/setup-demo.sh qa-demo-app
#   ./scripts/setup-demo.sh qa-demo-app my-org
#
# Prerequisites:
#   - Node.js 18+
#   - GitHub CLI (gh) installed and authenticated: gh auth login
#   - Git installed
# =============================================================

set -euo pipefail

REPO_NAME="${1:?Usage: ./scripts/setup-demo.sh <repo-name> [org]}"
ORG="${2:-}"

cd "$(dirname "$0")/.."

# ── Pre-flight: ensure git identity is configured ─────────────
if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
  echo ""
  echo "ERROR: Git identity not configured."
  echo "Run these commands first:"
  echo "  git config --global user.email \"you@example.com\""
  echo "  git config --global user.name \"Your Name\""
  exit 1
fi

if [ -n "$ORG" ]; then
  REPO_FULL_NAME="$ORG/$REPO_NAME"
else
  REPO_FULL_NAME="$REPO_NAME"
fi

echo ""
echo "=== QA Demo App — First-Time Setup ==="

# ── Step 1: npm install & seed ────────────────────────────────
echo ""
echo "[1/7] Installing dependencies..."
npm install
echo "[1/7] Seeding database..."
npm run seed

# ── Step 2: Initialize git repo ──────────────────────────────
echo ""
echo "[2/7] Initializing git repository..."
if [ ! -d ".git" ]; then
  git init
  git add -A
  git commit -m "Initial commit: QA Demo App with intentional vulnerabilities"
else
  echo "  Git already initialized, skipping."
fi

# ── Step 3: Create GitHub repo ────────────────────────────────
echo ""
echo "[3/7] Creating GitHub repository..."
if [ -n "$ORG" ]; then
  gh repo create "$REPO_FULL_NAME" --public --source . --push || {
    echo "  Repo may already exist, attempting to set remote..."
    git remote add origin "https://github.com/$REPO_FULL_NAME.git" 2>/dev/null || true
    git push -u origin main 2>/dev/null || true
  }
else
  gh repo create "$REPO_NAME" --public --source . --push || {
    echo "  Repo may already exist, attempting to set remote..."
    git remote add origin "https://github.com/$REPO_FULL_NAME.git" 2>/dev/null || true
    git push -u origin main 2>/dev/null || true
  }
fi
echo "  Repo created: $REPO_FULL_NAME"

# ── Step 4: Enable GHAS features ─────────────────────────────
echo ""
echo "[4/7] Enabling GitHub Advanced Security features..."
echo "  Enabling secret scanning..."
gh api "repos/$REPO_FULL_NAME" -X PATCH -f 'security_and_analysis[secret_scanning][status]=enabled' 2>/dev/null || true
echo "  Enabling secret scanning push protection..."
gh api "repos/$REPO_FULL_NAME" -X PATCH -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled' 2>/dev/null || true
echo "  Note: CodeQL will run automatically via .github/workflows/codeql.yml on the next push."
echo "  Note: Dependabot is configured via .github/dependabot.yml and will create alerts/PRs automatically."

# ── Step 5: Create demo branches & PRs ───────────────────────
echo ""
echo "[5/7] Creating demo branches and PRs..."

# Branch: feature/payment-discount (for Block 3 - Code Review demo)
echo "  Creating branch: feature/payment-discount..."
git checkout -b feature/payment-discount

cp demo-assets/PaymentService-pr-diff.js src/services/PaymentService.js
git add src/services/PaymentService.js
git commit -m "Add discount code support to payment processing

- Added DISCOUNT_CODES lookup with percentage-based discounts
- processPayment() now accepts optional discountCode parameter
- Validates discount codes and checks expiration
- Rounds final amount to 2 decimal places

Ticket: PROJ-142"

git push -u origin feature/payment-discount

gh pr create \
  --title "feat: Add discount code support to payment processing" \
  --body "## Summary
Added discount code validation and application to the payment processing flow.

## Changes
- Modified \`processPayment()\` to accept an optional \`discountCode\` parameter
- Added discount code lookup with percentage-based discounts
- Added expiration checking for discount codes

## Testing Notes
- Tested manually with codes SAVE10 (10%) and SAVE20 (20%)
- Need QA to verify edge cases: expired codes, stacking, zero-amount results" \
  --base main \
  --head feature/payment-discount

# Branch: feature/add-new-dependency (for Block 6 - Dependency Review demo)
git checkout main
echo "  Creating branch: feature/add-new-dependency..."
git checkout -b feature/add-new-dependency

# Add a dependency with known vulnerabilities
node -e "const p=require('./package.json'); p.dependencies['node-fetch']='2.6.0'; require('fs').writeFileSync('package.json', JSON.stringify(p, null, 2)+'\n')"
git add package.json
git commit -m "Add node-fetch for API calls"
git push -u origin feature/add-new-dependency

gh pr create \
  --title "chore: Add node-fetch for external API calls" \
  --body "Added node-fetch@2.6.0 for making HTTP requests to external services." \
  --base main \
  --head feature/add-new-dependency

git checkout main

# ── Step 6: Trigger CodeQL ────────────────────────────────────
echo ""
echo "[6/7] Triggering CodeQL analysis..."
if gh workflow run codeql.yml 2>/dev/null; then
  echo "  CodeQL workflow triggered. Alerts will appear in ~5 minutes."
else
  echo "  CodeQL workflow will run on next push to main (may already be running)."
fi

# ── Step 7: Create GitHub Project board + Issues ──────────────
echo ""
echo "[7/7] Creating GitHub Project board and issues..."

# Determine the owner (org or authenticated user)
if [ -n "$ORG" ]; then
  PROJECT_OWNER="$ORG"
else
  PROJECT_OWNER=$(gh api user --jq '.login')
fi

# Check if the setup-project workflow already created issues
EXISTING_ISSUES=$(gh issue list --repo "$REPO_FULL_NAME" --state all --limit 1 --json number --jq 'length' 2>/dev/null || echo "0")
if [ "$EXISTING_ISSUES" -gt 0 ]; then
  echo "  Issues already exist (created by setup-project workflow). Skipping issue creation."
else
  # Create labels
  echo "  Creating labels..."
  gh label create "QA" --description "QA team tasks" --color "0E8A16" --repo "$REPO_FULL_NAME" 2>/dev/null || true
  gh label create "security" --description "Security-related items" --color "D93F0B" --repo "$REPO_FULL_NAME" 2>/dev/null || true
  gh label create "testing" --description "Test coverage tasks" --color "1D76DB" --repo "$REPO_FULL_NAME" 2>/dev/null || true
  gh label create "blocked" --description "Blocked / waiting on dependency" --color "B60205" --repo "$REPO_FULL_NAME" 2>/dev/null || true
  gh label create "in-review" --description "Currently under review" --color "FBCA04" --repo "$REPO_FULL_NAME" 2>/dev/null || true

  # Create issues that map to Alex's day
  echo "  Creating issues..."

ISSUE1_URL=$(gh issue create --repo "$REPO_FULL_NAME" \
  --title "Add test coverage for user registration endpoint" \
  --body "## Description
The new user registration endpoint (\`UserService.register()\`) needs comprehensive test coverage.

## Acceptance Criteria
- [ ] Unit tests for all validation rules (email format, password strength, name length)
- [ ] Edge case tests (duplicate email, unicode names, boundary values)
- [ ] Integration tests for the REST API endpoint
- [ ] E2E test for the registration form

## Notes
See \`src/services/UserService.js\` for the implementation.
Blank test file ready at \`tests/UserService.copilot-demo.test.js\`." \
  --label "QA,testing" \
  --assignee "@me")

ISSUE2_URL=$(gh issue create --repo "$REPO_FULL_NAME" \
  --title "Review PR: Discount code support for payments" \
  --body "## Description
Review PR #1 (feat: Add discount code support to payment processing).

## QA Review Checklist
- [ ] Check for race conditions with concurrent discount usage
- [ ] Verify behavior when discount makes amount zero
- [ ] Verify expired discount codes are rejected
- [ ] Ensure original non-discount flow still works
- [ ] Generate regression test checklist

## Related
- PR: feature/payment-discount" \
  --label "QA,in-review" \
  --assignee "@me")

ISSUE3_URL=$(gh issue create --repo "$REPO_FULL_NAME" \
  --title "Triage CodeQL security alerts on main branch" \
  --body "## Description
Code scanning found new alerts on the main branch that need QA triage.

## Alerts to Review
- [ ] SQL Injection in \`src/routes/search.js\`
- [ ] XSS in \`src/views/profile.ejs\`
- [ ] Path Traversal in \`src/routes/files.js\`

## Actions Required
1. Review each alert and understand the data flow
2. Write security regression tests for each vulnerability
3. Verify developer fixes when PRs are submitted

## Priority
High — these are exploitable vulnerabilities on the main branch." \
  --label "QA,security" \
  --assignee "@me")

ISSUE4_URL=$(gh issue create --repo "$REPO_FULL_NAME" \
  --title "Investigate secret scanning alert — AWS key in config" \
  --body "## Description
Secret scanning detected an AWS access key committed to the repository in \`src/config.js\`.

## Actions Required
- [ ] Verify the key has been rotated/invalidated
- [ ] Confirm push protection is enabled to prevent future incidents
- [ ] Check if other config files contain credentials

## Reference
File: \`src/config.js\` lines 13-14" \
  --label "security" \
  --assignee "@me")

ISSUE5_URL=$(gh issue create --repo "$REPO_FULL_NAME" \
  --title "Validate Dependabot dependency updates" \
  --body "## Description
Dependabot flagged vulnerable dependencies that need QA validation after updates.

## Vulnerable Dependencies
- [ ] \`lodash@4.17.20\` — prototype pollution (CVE-2021-23337)
- [ ] \`axios@0.21.1\` — SSRF vulnerability

## QA Tasks
1. Review each Dependabot PR
2. Run the full test suite against updated dependencies
3. Verify no breaking changes in functionality
4. Approve PRs if tests pass" \
  --label "QA,security" \
  --assignee "@me")

ISSUE6_URL=$(gh issue create --repo "$REPO_FULL_NAME" \
  --title "Write security regression test for SQL injection fix" \
  --body "## Description
After the SQL injection in \`src/routes/search.js\` is fixed, we need a regression test to ensure it never comes back.

## Acceptance Criteria
- [ ] Test with common SQL injection payloads (\`' OR 1=1 --\`, \`UNION SELECT\`, \`DROP TABLE\`)
- [ ] Test passes against the fixed code (parameterized queries)
- [ ] Test fails against the original vulnerable code

## Related
- CodeQL alert: SQL Injection
- Fix file: \`demo-assets/search-fixed.js\`
- Blank test file: \`tests/security.copilot-demo.test.js\`" \
  --label "QA,security,testing" \
  --assignee "@me")

fi  # end of issue creation block

# Collect all issue URLs (whether just created or already existing from workflow)
echo "  Collecting issue URLs..."
ISSUE_URLS=$(gh issue list --repo "$REPO_FULL_NAME" --state all --json url --jq '.[].url' 2>/dev/null)

# Create the GitHub Project (v2)
echo "  Creating GitHub Project board..."
PROJECT_JSON=$(gh project create --owner "$PROJECT_OWNER" --title "QA Sprint Board — Alex's Tuesday" --format json 2>&1) || true
PROJECT_NUMBER=$(echo "$PROJECT_JSON" | jq -r '.number // empty' 2>/dev/null)

if [ -z "$PROJECT_NUMBER" ]; then
  echo "  ⚠️  Could not create project automatically. Create it manually at github.com"
else
  echo "  ✅ Project #$PROJECT_NUMBER created"

  # Add issues to the project
  echo "  Adding issues to project board..."
  echo "$ISSUE_URLS" | while read -r url; do
    [ -n "$url" ] && gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$url" 2>/dev/null || true
  done

  # Add PRs to the project
  echo "  Adding PRs to project board..."
  PR1_URL="https://github.com/$REPO_FULL_NAME/pull/1"
  PR2_URL="https://github.com/$REPO_FULL_NAME/pull/2"
  gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$PR1_URL" 2>/dev/null || true
  gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$PR2_URL" 2>/dev/null || true

  # Get the Status field ID and option IDs to set columns
  echo "  Setting board column statuses..."
  FIELDS_JSON=$(gh project field-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json 2>/dev/null) || true
  if [ -n "$FIELDS_JSON" ]; then
    STATUS_FIELD_ID=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Status") | .id // empty')
    TODO_OPTION=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Status") | .options[] | select(.name | test("Todo|To Do|to do")) | .id // empty')
    IN_PROGRESS_OPTION=$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name == "Status") | .options[] | select(.name | test("In Progress|in progress")) | .id // empty')

    if [ -n "$STATUS_FIELD_ID" ]; then
      PROJECT_ID=$(gh project view "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json 2>/dev/null | jq -r '.id // empty')

      if [ -n "$PROJECT_ID" ]; then
        ITEMS_JSON=$(gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json 2>/dev/null) || true
        if [ -n "$ITEMS_JSON" ]; then
          echo "$ITEMS_JSON" | jq -c '.items[]' 2>/dev/null | while read -r item; do
            TITLE=$(echo "$item" | jq -r '.content.title // empty')
            ITEM_ID=$(echo "$item" | jq -r '.id // empty')

            # Issue 1 (test coverage) & Issue 6 (security test) → Todo
            if [ -n "$TODO_OPTION" ] && echo "$TITLE" | grep -qE "test coverage|security regression"; then
              gh project item-edit --project-id "$PROJECT_ID" --id "$ITEM_ID" --field-id "$STATUS_FIELD_ID" --single-select-option-id "$TODO_OPTION" 2>/dev/null || true
            fi

            # Issue 2 (review PR) & Issue 3 (triage alerts) → In Progress
            if [ -n "$IN_PROGRESS_OPTION" ] && echo "$TITLE" | grep -qE "Review PR|Triage CodeQL"; then
              gh project item-edit --project-id "$PROJECT_ID" --id "$ITEM_ID" --field-id "$STATUS_FIELD_ID" --single-select-option-id "$IN_PROGRESS_OPTION" 2>/dev/null || true
            fi
          done
        fi
      fi
    fi
  fi

  echo "  ✅ Issues and PRs added to project board"
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Your demo is ready! Here's what was created:"
echo "  Repository:  https://github.com/$REPO_FULL_NAME"
echo "  PR #1:       feature/payment-discount (Block 3 - Code Review demo)"
echo "  PR #2:       feature/add-new-dependency (Block 6 - Dependency Review demo)"
if [ -n "$PROJECT_NUMBER" ]; then
echo "  Project:     #$PROJECT_NUMBER — 'QA Sprint Board - Alex's Tuesday'"
echo "  Issues:      6 issues across Todo / In Progress columns"
fi
echo ""
echo "Wait ~5 minutes for:"
echo "  - CodeQL alerts to appear (SQL injection, XSS, path traversal)"
echo "  - Dependabot alerts for lodash@4.17.20, axios@0.21.1"
echo "  - Secret scanning alert for the AWS key in src/config.js"
echo ""
echo "To reset the demo before each run:"
echo "  ./scripts/reset-demo.sh"
echo ""
