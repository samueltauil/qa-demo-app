/**
 * Seed script — populates the database with sample data for demos.
 * Run with: npm run seed
 */
const path = require('path');
const fs = require('fs');
const bcrypt = require('bcrypt');

// Ensure data directory exists
const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}
fs.writeFileSync(path.join(uploadsDir, 'report-q1.pdf'), 'sample file content');
fs.writeFileSync(path.join(uploadsDir, 'test-results.csv'), 'test,status\nlogin,pass\nregister,pass');

const { getDb } = require('./database');
const db = getDb();

// Drop and recreate tables so IDs always start at 1
db.exec('DROP TABLE IF EXISTS payments');
db.exec('DROP TABLE IF EXISTS users');
db.exec('DROP TABLE IF EXISTS products');
db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT NOT NULL,
    bio TEXT DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )
`);
db.exec(`
  CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT DEFAULT 'pending',
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
  )
`);
db.exec(`
  CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    category TEXT
  )
`);

// Seed users
const passwordHash = bcrypt.hashSync('password123', 10);

const users = [
  { email: 'alex@company.com', name: 'Alex Rivera' },
  { email: 'jordan@company.com', name: 'Jordan Chen' },
  { email: 'sam@company.com', name: 'Sam Patel' },
  { email: 'admin@company.com', name: 'Admin User' }
];

const insertUser = db.prepare('INSERT INTO users (email, password_hash, name, bio) VALUES (?, ?, ?, ?)');

const userIds = [];
users.forEach(u => {
  const result = insertUser.run(u.email, passwordHash, u.name, `Hi, I'm ${u.name}. QA Engineer.`);
  userIds.push(Number(result.lastInsertRowid));
});

// Seed one user with a dangerous bio (for XSS demo)
db.prepare('UPDATE users SET bio = ? WHERE email = ?').run(
  'Hello! <img src=x onerror="alert(\'XSS\')"> Nice to meet you.',
  'jordan@company.com'
);

// Seed products
const products = [
  { name: 'Widget Pro', description: 'Professional-grade widget', price: 29.99, category: 'Tools' },
  { name: 'Widget Lite', description: 'Lightweight widget for beginners', price: 9.99, category: 'Tools' },
  { name: 'DataSync Cable', description: 'High-speed data synchronization cable', price: 14.99, category: 'Accessories' },
  { name: 'CloudMonitor', description: 'Real-time cloud infrastructure monitoring', price: 49.99, category: 'Software' },
  { name: 'TestRunner 3000', description: 'Automated test execution platform', price: 199.99, category: 'Software' },
  { name: 'SecureVault', description: 'Encrypted credential storage solution', price: 79.99, category: 'Security' },
  { name: 'API Gateway', description: 'Scalable API management gateway', price: 149.99, category: 'Infrastructure' },
  { name: 'LogAnalyzer', description: 'Log aggregation and analysis tool', price: 39.99, category: 'Software' }
];

const insertProduct = db.prepare('INSERT INTO products (name, description, price, category) VALUES (?, ?, ?, ?)');
products.forEach(p => {
  insertProduct.run(p.name, p.description, p.price, p.category);
});

// Seed payments
const insertPayment = db.prepare(
  'INSERT INTO payments (user_id, amount, currency, status, description) VALUES (?, ?, ?, ?, ?)'
);
insertPayment.run(userIds[0], 29.99, 'USD', 'completed', 'Widget Pro purchase');
insertPayment.run(userIds[0], 14.99, 'USD', 'completed', 'DataSync Cable purchase');
insertPayment.run(userIds[1], 199.99, 'USD', 'completed', 'TestRunner 3000 license');
insertPayment.run(userIds[2], 49.99, 'USD', 'pending', 'CloudMonitor subscription');

console.log('✅ Database seeded successfully!');
console.log(`   - ${users.length} users (password: password123)`);
console.log(`   - ${products.length} products`);
console.log('   - 4 payment records');
console.log('   - 2 sample upload files');
