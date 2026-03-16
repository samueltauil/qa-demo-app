const { getDb } = require('../database');

class PaymentService {
  /**
   * Process a payment for a user.
   *
   * @param {object} paymentData
   * @param {number} paymentData.userId      — the ID of the paying user
   * @param {number} paymentData.amount      — payment amount (must be > 0)
   * @param {string} paymentData.currency    — ISO 4217 currency code (default: USD)
   * @param {string} paymentData.description — optional description
   * @returns {object} The created payment record
   */
  static processPayment({ userId, amount, currency = 'USD', description = '' }) {
    if (!userId) {
      throw new Error('User ID is required');
    }

    if (amount === undefined || amount === null) {
      throw new Error('Amount is required');
    }

    if (typeof amount !== 'number' || isNaN(amount)) {
      throw new Error('Amount must be a valid number');
    }

    if (amount <= 0) {
      throw new Error('Amount must be greater than zero');
    }

    if (amount > 999999.99) {
      throw new Error('Amount exceeds maximum limit');
    }

    // Round to 2 decimal places
    const roundedAmount = Math.round(amount * 100) / 100;

    const db = getDb();

    // Verify user exists
    const user = db.prepare('SELECT id FROM users WHERE id = ?').get(userId);
    if (!user) {
      throw new Error('User not found');
    }

    const result = db.prepare(
      'INSERT INTO payments (user_id, amount, currency, status, description) VALUES (?, ?, ?, ?, ?)'
    ).run(userId, roundedAmount, currency.toUpperCase(), 'completed', description);

    return {
      id: result.lastInsertRowid,
      userId,
      amount: roundedAmount,
      currency: currency.toUpperCase(),
      status: 'completed',
      description,
      createdAt: new Date().toISOString()
    };
  }

  /**
   * Refund a payment. Changes status to 'refunded' and creates a negative entry.
   */
  static refundPayment(paymentId) {
    const db = getDb();

    const payment = db.prepare('SELECT * FROM payments WHERE id = ?').get(paymentId);
    if (!payment) {
      throw new Error('Payment not found');
    }

    if (payment.status === 'refunded') {
      throw new Error('Payment has already been refunded');
    }

    // Update original payment
    db.prepare('UPDATE payments SET status = ? WHERE id = ?').run('refunded', paymentId);

    // Create refund record
    const result = db.prepare(
      'INSERT INTO payments (user_id, amount, currency, status, description) VALUES (?, ?, ?, ?, ?)'
    ).run(payment.user_id, -payment.amount, payment.currency, 'refund', `Refund for payment #${paymentId}`);

    return {
      id: result.lastInsertRowid,
      originalPaymentId: paymentId,
      amount: -payment.amount,
      currency: payment.currency,
      status: 'refund',
      createdAt: new Date().toISOString()
    };
  }

  /**
   * Get payment history for a user.
   */
  static getPaymentsByUser(userId) {
    const db = getDb();
    return db.prepare(
      'SELECT * FROM payments WHERE user_id = ? ORDER BY created_at DESC'
    ).all(userId);
  }

  /**
   * Calculate total revenue.
   */
  static getTotalRevenue() {
    const db = getDb();
    const row = db.prepare(
      "SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE status = 'completed'"
    ).get();
    return row.total;
  }
}

module.exports = PaymentService;
