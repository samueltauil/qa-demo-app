# QA Demo App

A demo web application for the **GitHub Copilot & Advanced Security** presentation.

> ⚠️ **This app contains intentional vulnerabilities for demonstration purposes.**  
> Do NOT deploy this to any real environment.

---

## Quick Start (First Time)

### Prerequisites
- Node.js 18+
- [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth login`)
- Git

### One-Command Setup

```bash
cd demo-app
./scripts/setup-demo.sh "qa-demo-app"

# Or with a GitHub org:
./scripts/setup-demo.sh "qa-demo-app" "my-org"
```

This will: install deps, seed the DB, create the GitHub repo, set up branches/PRs, enable GHAS, and trigger CodeQL. Wait ~5 minutes for alerts to populate.

---

## Before Each Presentation (Reset)

```bash
./scripts/reset-demo.sh
```

This will: restore blank Copilot demo files, reset the database, restore vulnerable source files, and verify tests pass. **Run this every time before you present.**

Then:
```bash
npm start
```

---

## Using as a GitHub Template

To make this reusable across multiple presentations:

1. On GitHub.com → your repo → Settings → check **"Template repository"**
2. Before each new presentation, click **"Use this template"** → creates a fresh copy
3. Run `./scripts/setup-demo.sh "new-demo-name"` in the fresh copy
4. Labels, issues, and the project board are created automatically by the `setup-project` workflow on the first push

This gives you clean PRs, fresh alerts, and no leftover state from previous demos.

> **How it works:** The `setup-project` workflow automatically creates labels and issues on the first push. Then when you run `./scripts/setup-demo.sh` locally, it detects the existing issues, skips re-creating them, and creates the project board using your `gh` CLI auth — no PAT secrets needed.

---

## Project Structure

```bash
cd demo-app
npm install
npm run seed   # Initialize the database with sample data
npm start      # Start the server on http://localhost:3000
```

## Demo Structure

| Feature | Location | Purpose |
|---------|----------|---------|
| User Registration | `src/services/UserService.js` | Copilot test generation demo |
| Payment Processing | `src/services/PaymentService.js` | PR review demo |
| SQL query page | `src/routes/search.js` | CodeQL SQL injection alert |
| File download | `src/routes/files.js` | CodeQL path traversal alert |
| User profile page | `src/views/profile.ejs` | CodeQL XSS alert |
| Config with secret | `src/config.js` | Secret scanning demo |
| Outdated deps | `package.json` | Dependabot alert demo |
| Setup script | `scripts/setup-demo.sh` | First-time repo + GitHub setup |
| Reset script | `scripts/reset-demo.sh` | Clean state before each run |
| Auto-setup workflow | `.github/workflows/setup-project.yml` | Creates issues & project board on first push |
| Presenter prompts | `demo-assets/copilot-prompts.md` | Copy-paste Copilot Chat prompts |
| Step-by-step guide | `demo-assets/demo-run-script.md` | Detailed demo walkthrough |

## Tests

```bash
npm test          # Run unit tests (partially covered)
npm run test:e2e  # Run Playwright E2E tests
```

## Replayability Cheat Sheet

```
┌─────────────────────────────────────────────────┐
│  FIRST TIME EVER                                │
│  ./scripts/setup-demo.sh "my-demo"              │
│  (wait 5 min for GitHub alerts)                 │
├─────────────────────────────────────────────────┤
│  BEFORE EACH PRESENTATION                       │
│  ./scripts/reset-demo.sh                        │
│  npm start                                      │
├─────────────────────────────────────────────────┤
│  FRESH COPY FOR NEW AUDIENCE                    │
│  Use Template → setup-demo.sh                   │
└─────────────────────────────────────────────────┘
```

## Intentional Vulnerabilities (for GHAS demo)

1. **SQL Injection** — `src/routes/search.js` builds queries with string concatenation
2. **XSS** — `src/views/profile.ejs` renders user input without escaping
3. **Path Traversal** — `src/routes/files.js` doesn't sanitize file paths
4. **Hardcoded Secret** — `src/config.js` contains an AWS-style API key
5. **Vulnerable Dependencies** — `lodash@4.17.20` and `axios@0.21.1` have known CVEs
