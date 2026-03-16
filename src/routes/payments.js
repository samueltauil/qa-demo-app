const express = require('express');
const router = express.Router();
const PaymentService = require('../services/PaymentService');

// POST /api/payments
router.post('/', (req, res) => {
  try {
    const payment = PaymentService.processPayment({
      userId: req.body.userId,
      amount: parseFloat(req.body.amount),
      currency: req.body.currency,
      description: req.body.description
    });
    res.status(201).json(payment);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// POST /api/payments/:id/refund
router.post('/:id/refund', (req, res) => {
  try {
    const refund = PaymentService.refundPayment(parseInt(req.params.id));
    res.json(refund);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /api/payments/user/:userId
router.get('/user/:userId', (req, res) => {
  const payments = PaymentService.getPaymentsByUser(parseInt(req.params.userId));
  res.json(payments);
});

// GET /api/payments/revenue
router.get('/revenue', (req, res) => {
  const total = PaymentService.getTotalRevenue();
  res.json({ totalRevenue: total });
});

module.exports = router;
