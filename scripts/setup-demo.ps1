<#
.SYNOPSIS
    First-time setup for the QA Demo App presentation repo.
    Creates the GitHub repo, branches, PRs, project board, and issues needed for the demo.

.DESCRIPTION
    Run this ONCE after cloning the template (or the first time).
    It will:
      1. Install npm dependencies
      2. Seed the database
      3. Initialize git and push to GitHub
      4. Create the demo branches and PRs (payment-discount, vuln-dependency)
      5. Trigger CodeQL analysis
      6. Create a GitHub Project (kanban board) with issues and linked PRs
      7. Verify everything is ready

.NOTES
    Prerequisites:
      - Node.js 18+
      - GitHub CLI (gh) installed and authenticated: gh auth login
      - Git installed
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$RepoName,

    [Parameter()]
    [string]$Org = "",

    [Parameter()]
    [switch]$Template
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

$repoFullName = if ($Org) { "$Org/$RepoName" } else { $RepoName }

Write-Host "`n=== QA Demo App — First-Time Setup ===" -ForegroundColor Cyan

# ── Step 1: npm install & seed ────────────────────────────────
Write-Host "`n[1/7] Installing dependencies..." -ForegroundColor Yellow
npm install
Write-Host "[1/7] Seeding database..." -ForegroundColor Yellow
npm run seed

# ── Step 2: Initialize git repo ──────────────────────────────
Write-Host "`n[2/7] Initializing git repository..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init
    git add -A
    git commit -m "Initial commit: QA Demo App with intentional vulnerabilities"
} else {
    Write-Host "  Git already initialized, skipping."
}

# ── Step 3: Create GitHub repo ────────────────────────────────
Write-Host "`n[3/7] Creating GitHub repository..." -ForegroundColor Yellow
$visibility = "--public"
$templateFlag = if ($Template) { "--template" } else { "" }

try {
    if ($Org) {
        gh repo create $repoFullName $visibility --source . --push
    } else {
        gh repo create $RepoName $visibility --source . --push
    }
    Write-Host "  Repo created: $repoFullName" -ForegroundColor Green
} catch {
    Write-Host "  Repo may already exist, attempting to set remote..." -ForegroundColor Yellow
    git remote add origin "https://github.com/$repoFullName.git" 2>$null
    git push -u origin main 2>$null
}

# ── Step 4: Enable GHAS features ─────────────────────────────
Write-Host "`n[4/7] Enabling GitHub Advanced Security features..." -ForegroundColor Yellow
Write-Host "  Enabling secret scanning..." 
gh api repos/$repoFullName -X PATCH -f security_and_analysis[secret_scanning][status]=enabled 2>$null
Write-Host "  Enabling secret scanning push protection..."
gh api repos/$repoFullName -X PATCH -f security_and_analysis[secret_scanning_push_protection][status]=enabled 2>$null
Write-Host "  Note: CodeQL will run automatically via .github/workflows/codeql.yml on the next push."
Write-Host "  Note: Dependabot is configured via .github/dependabot.yml and will create alerts/PRs automatically."

# ── Step 5: Create demo branches & PRs ───────────────────────
Write-Host "`n[5/7] Creating demo branches and PRs..." -ForegroundColor Yellow

# Branch: feature/payment-discount (for Block 3 - Code Review demo)
Write-Host "  Creating branch: feature/payment-discount..."
git checkout -b feature/payment-discount

# Copy the PR diff version into the actual service file for this branch
Copy-Item "demo-assets\PaymentService-pr-diff.js" "src\services\PaymentService.js" -Force
git add src/services/PaymentService.js
git commit -m "Add discount code support to payment processing

- Added DISCOUNT_CODES lookup with percentage-based discounts
- processPayment() now accepts optional discountCode parameter
- Validates discount codes and checks expiration
- Rounds final amount to 2 decimal places

Ticket: PROJ-142"

git push -u origin feature/payment-discount

# Create the PR
gh pr create `
    --title "feat: Add discount code support to payment processing" `
    --body "## Summary`nAdded discount code validation and application to the payment processing flow.`n`n## Changes`n- Modified \`processPayment()\` to accept an optional \`discountCode\` parameter`n- Added discount code lookup with percentage-based discounts`n- Added expiration checking for discount codes`n`n## Testing Notes`n- Tested manually with codes SAVE10 (10%) and SAVE20 (20%)`n- Need QA to verify edge cases: expired codes, stacking, zero-amount results" `
    --base main `
    --head feature/payment-discount

# Branch: feature/add-new-dependency (for Block 6 - Dependency Review demo)
git checkout main
Write-Host "  Creating branch: feature/add-new-dependency..."
git checkout -b feature/add-new-dependency

# Add a dependency with known vulnerabilities
$pkg = Get-Content "package.json" | ConvertFrom-Json
$pkg.dependencies | Add-Member -NotePropertyName "node-fetch" -NotePropertyValue "2.6.0" -Force
$pkg | ConvertTo-Json -Depth 10 | Set-Content "package.json"
git add package.json
git commit -m "Add node-fetch for API calls"
git push -u origin feature/add-new-dependency

gh pr create `
    --title "chore: Add node-fetch for external API calls" `
    --body "Added node-fetch@2.6.0 for making HTTP requests to external services." `
    --base main `
    --head feature/add-new-dependency

git checkout main

# ── Step 6: Trigger CodeQL ────────────────────────────────────
Write-Host "`n[6/7] Triggering CodeQL analysis..." -ForegroundColor Yellow
gh workflow run codeql.yml 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  CodeQL workflow will run on next push to main (may already be running)." -ForegroundColor Yellow
} else {
    Write-Host "  CodeQL workflow triggered. Alerts will appear in ~5 minutes." -ForegroundColor Green
}

# ── Step 7: Create GitHub Project board + Issues ──────────────
Write-Host "`n[7/7] Creating GitHub Project board and issues..." -ForegroundColor Yellow

# Determine the owner (org or authenticated user)
$projectOwner = if ($Org) { $Org } else { (gh api user --jq '.login') }

# Create labels
Write-Host "  Creating labels..."
gh label create "QA" --description "QA team tasks" --color "0E8A16" --repo $repoFullName 2>$null
gh label create "security" --description "Security-related items" --color "D93F0B" --repo $repoFullName 2>$null
gh label create "testing" --description "Test coverage tasks" --color "1D76DB" --repo $repoFullName 2>$null
gh label create "blocked" --description "Blocked / waiting on dependency" --color "B60205" --repo $repoFullName 2>$null
gh label create "in-review" --description "Currently under review" --color "FBCA04" --repo $repoFullName 2>$null

# Create issues that map to Alex's day
Write-Host "  Creating issues..."

$issue1Url = gh issue create --repo $repoFullName `
    --title "Add test coverage for user registration endpoint" `
    --body "## Description`nThe new user registration endpoint (\`UserService.register()\`) needs comprehensive test coverage.`n`n## Acceptance Criteria`n- [ ] Unit tests for all validation rules (email format, password strength, name length)`n- [ ] Edge case tests (duplicate email, unicode names, boundary values)`n- [ ] Integration tests for the REST API endpoint`n- [ ] E2E test for the registration form`n`n## Notes`nSee \`src/services/UserService.js\` for the implementation.`nBlank test file ready at \`tests/UserService.copilot-demo.test.js\`." `
    --label "QA,testing" `
    --assignee "@me"

$issue2Url = gh issue create --repo $repoFullName `
    --title "Review PR: Discount code support for payments" `
    --body "## Description`nReview PR #1 (feat: Add discount code support to payment processing).`n`n## QA Review Checklist`n- [ ] Check for race conditions with concurrent discount usage`n- [ ] Verify behavior when discount makes amount zero`n- [ ] Verify expired discount codes are rejected`n- [ ] Ensure original non-discount flow still works`n- [ ] Generate regression test checklist`n`n## Related`n- PR: feature/payment-discount" `
    --label "QA,in-review" `
    --assignee "@me"

$issue3Url = gh issue create --repo $repoFullName `
    --title "Triage CodeQL security alerts on main branch" `
    --body "## Description`nCode scanning found new alerts on the main branch that need QA triage.`n`n## Alerts to Review`n- [ ] SQL Injection in \`src/routes/search.js\``n- [ ] XSS in \`src/views/profile.ejs\``n- [ ] Path Traversal in \`src/routes/files.js\``n`n## Actions Required`n1. Review each alert and understand the data flow`n2. Write security regression tests for each vulnerability`n3. Verify developer fixes when PRs are submitted`n`n## Priority`nHigh — these are exploitable vulnerabilities on the main branch." `
    --label "QA,security" `
    --assignee "@me"

$issue4Url = gh issue create --repo $repoFullName `
    --title "Investigate secret scanning alert — AWS key in config" `
    --body "## Description`nSecret scanning detected an AWS access key committed to the repository in \`src/config.js\`.`n`n## Actions Required`n- [ ] Verify the key has been rotated/invalidated`n- [ ] Confirm push protection is enabled to prevent future incidents`n- [ ] Check if other config files contain credentials`n`n## Reference`nFile: \`src/config.js\` lines 13-14" `
    --label "security" `
    --assignee "@me"

$issue5Url = gh issue create --repo $repoFullName `
    --title "Validate Dependabot dependency updates" `
    --body "## Description`nDependabot flagged vulnerable dependencies that need QA validation after updates.`n`n## Vulnerable Dependencies`n- [ ] \`lodash@4.17.20\` — prototype pollution (CVE-2021-23337)`n- [ ] \`axios@0.21.1\` — SSRF vulnerability`n`n## QA Tasks`n1. Review each Dependabot PR`n2. Run the full test suite against updated dependencies`n3. Verify no breaking changes in functionality`n4. Approve PRs if tests pass" `
    --label "QA,security" `
    --assignee "@me"

$issue6Url = gh issue create --repo $repoFullName `
    --title "Write security regression test for SQL injection fix" `
    --body "## Description`nAfter the SQL injection in \`src/routes/search.js\` is fixed, we need a regression test to ensure it never comes back.`n`n## Acceptance Criteria`n- [ ] Test with common SQL injection payloads (\`' OR 1=1 --\`, \`UNION SELECT\`, \`DROP TABLE\`)`n- [ ] Test passes against the fixed code (parameterized queries)`n- [ ] Test fails against the original vulnerable code`n`n## Related`n- CodeQL alert: SQL Injection`n- Fix file: \`demo-assets/search-fixed.js\``n- Blank test file: \`tests/security.copilot-demo.test.js\`" `
    --label "QA,security,testing" `
    --assignee "@me"

# Create the GitHub Project (v2)
Write-Host "  Creating GitHub Project board..."
$projectCreateOutput = gh project create --owner $projectOwner --title "QA Sprint Board — Alex's Tuesday" --format json 2>&1
$projectNumber = ($projectCreateOutput | ConvertFrom-Json).number

if (-not $projectNumber) {
    Write-Host "  ⚠️  Could not create project automatically. Create it manually at github.com" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Project #$projectNumber created" -ForegroundColor Green

    # Add issues to the project
    Write-Host "  Adding issues to project board..."
    gh project item-add $projectNumber --owner $projectOwner --url $issue1Url 2>$null
    gh project item-add $projectNumber --owner $projectOwner --url $issue2Url 2>$null
    gh project item-add $projectNumber --owner $projectOwner --url $issue3Url 2>$null
    gh project item-add $projectNumber --owner $projectOwner --url $issue4Url 2>$null
    gh project item-add $projectNumber --owner $projectOwner --url $issue5Url 2>$null
    gh project item-add $projectNumber --owner $projectOwner --url $issue6Url 2>$null

    # Add PRs to the project
    Write-Host "  Adding PRs to project board..."
    $pr1Url = "https://github.com/$repoFullName/pull/1"
    $pr2Url = "https://github.com/$repoFullName/pull/2"
    gh project item-add $projectNumber --owner $projectOwner --url $pr1Url 2>$null
    gh project item-add $projectNumber --owner $projectOwner --url $pr2Url 2>$null

    # Get the Status field ID and option IDs to set columns
    Write-Host "  Setting board column statuses..."
    $fieldsJson = gh project field-list $projectNumber --owner $projectOwner --format json 2>$null
    if ($fieldsJson) {
        $fields = $fieldsJson | ConvertFrom-Json
        $statusField = $fields.fields | Where-Object { $_.name -eq "Status" }

        if ($statusField) {
            $statusFieldId = $statusField.id
            $todoOption = ($statusField.options | Where-Object { $_.name -match "Todo|To Do|to do" }).id
            $inProgressOption = ($statusField.options | Where-Object { $_.name -match "In Progress|in progress" }).id
            $doneOption = ($statusField.options | Where-Object { $_.name -match "Done|done" }).id

            # Get item IDs
            $itemsJson = gh project item-list $projectNumber --owner $projectOwner --format json 2>$null
            if ($itemsJson) {
                $items = ($itemsJson | ConvertFrom-Json).items

                foreach ($item in $items) {
                    $title = $item.content.title
                    $itemId = $item.id

                    if ($todoOption) {
                        # Issue 1 (test coverage) & Issue 6 (security test) → Todo
                        if ($title -match "test coverage|security regression") {
                            gh project item-edit --project-id (gh project view $projectNumber --owner $projectOwner --format json | ConvertFrom-Json).id --id $itemId --field-id $statusFieldId --single-select-option-id $todoOption 2>$null
                        }
                    }
                    if ($inProgressOption) {
                        # Issue 2 (review PR) & Issue 3 (triage alerts) → In Progress
                        if ($title -match "Review PR|Triage CodeQL") {
                            gh project item-edit --project-id (gh project view $projectNumber --owner $projectOwner --format json | ConvertFrom-Json).id --id $itemId --field-id $statusFieldId --single-select-option-id $inProgressOption 2>$null
                        }
                    }
                }
            }
        }
    }

    Write-Host "  ✅ Issues and PRs added to project board" -ForegroundColor Green
}

# ── Done ──────────────────────────────────────────────────────
Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your demo is ready! Here's what was created:" -ForegroundColor Cyan
Write-Host "  Repository:  https://github.com/$repoFullName"
Write-Host "  PR #1:       feature/payment-discount (Block 3 - Code Review demo)"
Write-Host "  PR #2:       feature/add-new-dependency (Block 6 - Dependency Review demo)"
if ($projectNumber) {
Write-Host "  Project:     #$projectNumber — 'QA Sprint Board - Alex's Tuesday'"
Write-Host "  Issues:      6 issues across Todo / In Progress columns"
}
Write-Host ""
Write-Host "Wait ~5 minutes for:" -ForegroundColor Yellow
Write-Host "  - CodeQL alerts to appear (SQL injection, XSS, path traversal)"
Write-Host "  - Dependabot alerts for lodash@4.17.20, axios@0.21.1"
Write-Host "  - Secret scanning alert for the AWS key in src/config.js"
Write-Host ""
Write-Host "To reset the demo before each run:" -ForegroundColor Yellow
Write-Host "  .\scripts\reset-demo.ps1"
Write-Host ""
