// ============================================================
// ⚠️  DEMO ONLY — contains an intentional hardcoded secret
//     for the Secret Scanning demo (Block 5, step 4).
// ============================================================

module.exports = {
  port: process.env.PORT || 3000,
  jwtSecret: 'super-secret-jwt-key-do-not-use',
  database: './data/qa-demo.db',

  // AWS credentials (INTENTIONAL — triggers secret scanning alert)
  aws: {
    accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
    secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
    region: 'us-east-1'
  }
};
