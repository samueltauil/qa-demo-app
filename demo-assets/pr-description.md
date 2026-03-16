# PR #42: Refactor payment processing with discount support

## Summary
Added discount code validation and application to the payment processing flow.
Modified the `processPayment` method to accept an optional `discountCode` parameter.

## Changes
- `src/services/PaymentService.js` — Added discount logic to `processPayment()`
- `src/routes/payments.js` — Accept `discountCode` in request body
- `tests/PaymentService.test.js` — Added basic discount tests

## Why
Product requested discount code support for the upcoming Q2 campaign.
Users can enter a promo code during checkout to receive percentage-based discounts.

## Testing Notes
- Tested manually with codes `SAVE10` (10%) and `SAVE20` (20%)
- Need QA to verify edge cases: expired codes, stacking, zero-amount results

---

### 🔍 QA Review Points (for demo Block 3)

Use these Copilot Chat prompts during the review:
1. "Could this change introduce any race conditions?"
2. "What happens if the payment amount is zero after applying the discount?"
3. "What tests should I add to verify this PR doesn't break existing behavior?"
