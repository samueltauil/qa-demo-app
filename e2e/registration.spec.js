// =============================================================
// 🎯 E2E TEST — for Copilot demo (Block 2, step 3)
//
// This file has a partial E2E test. During the demo, ask Copilot
// to help write additional tests for the registration form.
//
// Example prompt:
//   "Write a Playwright test for the user registration form
//    that tests successful registration and validation errors"
// =============================================================

const { test, expect } = require('@playwright/test');

test.describe('User Registration', () => {
  test('should display the registration form', async ({ page }) => {
    await page.goto('/register');

    await expect(page.locator('h1')).toContainText('Create Account');
    await expect(page.locator('#name')).toBeVisible();
    await expect(page.locator('#email')).toBeVisible();
    await expect(page.locator('#password')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  // ⬇️ Ask Copilot to generate more E2E tests here during the demo
  // Suggested prompts:
  //   "Add a test for successful registration with valid data"
  //   "Add a test that verifies validation errors for short passwords"
  //   "Add a test for duplicate email registration"
});
