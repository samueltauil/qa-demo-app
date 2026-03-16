// ============================================================
// Complex test file for Copilot to analyze (Block 2, step 4)
// "What does this test verify? Are there any gaps?"
//
// Intentionally complex and hard to read so Copilot can
// demonstrate its ability to explain and find gaps.
// ============================================================

const PaymentService = require('../src/services/PaymentService');
const UserService = require('../src/services/UserService');
const { getDb } = require('../src/database');

describe('PaymentService', () => {
  let testUserId;

  beforeEach(async () => {
    const db = getDb();
    db.exec('DELETE FROM payments');
    db.exec('DELETE FROM users');

    const user = await UserService.register({
      email: 'payer@test.com',
      password: 'testPass1',
      name: 'Test Payer'
    });
    testUserId = user.id;
  });

  it('processes a standard USD payment and returns expected structure', () => {
    const r = PaymentService.processPayment({
      userId: testUserId,
      amount: 49.99,
      currency: 'USD',
      description: 'Widget purchase'
    });
    expect(r.amount).toBe(49.99);
    expect(r.currency).toBe('USD');
    expect(r.status).toBe('completed');
    expect(r.userId).toBe(testUserId);
    expect(r).toHaveProperty('id');
    expect(r).toHaveProperty('createdAt');
  });

  it('rejects payment without user ID', () => {
    expect(() => PaymentService.processPayment({
      amount: 10, currency: 'USD'
    })).toThrow('User ID is required');
  });

  it('rejects negative payment amounts', () => {
    expect(() => PaymentService.processPayment({
      userId: testUserId, amount: -5
    })).toThrow('Amount must be greater than zero');
  });

  it('rounds amounts to 2 decimal places', () => {
    const r = PaymentService.processPayment({
      userId: testUserId,
      amount: 19.999
    });
    expect(r.amount).toBe(20.00);
  });

  it('handles refund flow', () => {
    const payment = PaymentService.processPayment({
      userId: testUserId,
      amount: 25.00
    });
    const refund = PaymentService.refundPayment(payment.id);
    expect(refund.amount).toBe(-25.00);
    expect(refund.status).toBe('refund');
    expect(refund.originalPaymentId).toBe(payment.id);
  });

  // ⬇️ GAPS — intentionally missing tests for Copilot to identify:
  //
  // - What happens with amount = 0?
  // - What happens with very large amounts (> max limit)?
  // - What about non-numeric amounts (string, null, undefined)?
  // - Double refund prevention?
  // - Payment for a non-existent user?
  // - Currency validation (invalid currency codes)?
  // - getPaymentsByUser() — not tested at all
  // - getTotalRevenue() — not tested at all
  // - Concurrent payment processing?
});
