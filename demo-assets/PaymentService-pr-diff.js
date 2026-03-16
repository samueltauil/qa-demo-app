// ============================================================
// PR #42: Payment processing with discount support
// This file represents the "diff" a developer submitted.
// Use this during Block 3 (Copilot: Code Review & Bug Analysis)
// ============================================================

const { getDb } = require('../database');

// Discount codes (in production this would be in a database)
const DISCOUNT_CODES = {
  'SAVE10': { percent: 10, expiresAt: new Date('2026-06-30') },
  'SAVE20': { percent: 20, expiresAt: new Date('2026-06-30') },
  'WELCOME50': { percent: 50, expiresAt: new Date('2026-12-31') },
};

class PaymentServiceWithDiscount {
  /**
   * Process a payment with optional discount code.
   *
   * ⚠️ REVIEW QUESTIONS (for Copilot demo):
   *   - What happens if amount becomes zero after discount?
   *   - Is there a race condition with concurrent discount usage?
   *   - Can a user apply the same discount code twice?
   */
  static processPayment({ userId, amount, currency = 'USD', description = '', discountCode = null }) {
    if (!userId) throw new Error('User ID is required');
    if (typeof amount !== 'number' || amount <= 0) throw new Error('Invalid amount');

    let finalAmount = amount;

    // Apply discount if code provided
    if (discountCode) {
      const discount = DISCOUNT_CODES[discountCode.toUpperCase()];

      if (!discount) {
        throw new Error('Invalid discount code');
      }

      // BUG: doesn't check expiration properly (uses string comparison)
      // This is intentional for the PR review demo
      if (discount.expiresAt < Date.now()) {
        throw new Error('Discount code has expired');
      }

      finalAmount = amount * (1 - discount.percent / 100);

      // BUG: doesn't handle case where finalAmount becomes 0
      // (e.g., WELCOME50 on a $1 item rounds to $0.50, but
      //  what about a 100% code if one were added?)
    }

    const roundedAmount = Math.round(finalAmount * 100) / 100;

    const db = getDb();
    const user = db.prepare('SELECT id FROM users WHERE id = ?').get(userId);
    if (!user) throw new Error('User not found');

    const result = db.prepare(
      'INSERT INTO payments (user_id, amount, currency, status, description) VALUES (?, ?, ?, ?, ?)'
    ).run(userId, roundedAmount, currency.toUpperCase(), 'completed', description);

    return {
      id: result.lastInsertRowid,
      userId,
      originalAmount: amount,
      discountApplied: discountCode ? discountCode.toUpperCase() : null,
      finalAmount: roundedAmount,
      currency: currency.toUpperCase(),
      status: 'completed',
      description,
      createdAt: new Date().toISOString()
    };
  }
}

module.exports = PaymentServiceWithDiscount;
