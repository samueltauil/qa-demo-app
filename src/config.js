// ============================================================
// ⚠️  DEMO ONLY — contains an intentional hardcoded secret
//     for the Secret Scanning demo (Block 5, step 4).
// ============================================================

module.exports = {
  port: process.env.PORT || 3000,
  jwtSecret: 'super-secret-jwt-key-do-not-use',
  database: './data/qa-demo.db',

  // GitHub PAT — PLACEHOLDER for secret scanning demo
  // Before the presentation, create a temporary GitHub PAT and paste it here
  // to trigger a secret scanning alert (see presentation-guide.md Step 5.4)
  github: {
    token: 'REPLACE_WITH_GITHUB_PAT_BEFORE_DEMO'
  }
};
