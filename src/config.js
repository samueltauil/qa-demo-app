// ============================================================
// ⚠️  DEMO ONLY — contains an intentional hardcoded secret
//     for the Secret Scanning demo (Block 5, step 4).
// ============================================================

module.exports = {
  port: process.env.PORT || 3000,
  jwtSecret: 'super-secret-jwt-key-do-not-use',
  database: './data/qa-demo.db',

  // AWS credentials — PLACEHOLDER for secret scanning demo
  // Before the presentation, replace these with a real-looking AWS key
  // to trigger a secret scanning alert (see presentation-guide.md Step 5.4)
  aws: {
    accessKeyId: 'REPLACE_WITH_AWS_KEY_BEFORE_DEMO',
    secretAccessKey: 'REPLACE_WITH_AWS_SECRET_BEFORE_DEMO',
    region: 'us-east-1'
  }
};
