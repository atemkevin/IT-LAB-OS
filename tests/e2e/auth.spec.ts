import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should load the login page', async ({ page }) => {
    await page.goto('/login', { waitUntil: 'domcontentloaded' });
    
    // Check for login form elements
    await expect(page.locator('text=Sign In').first()).toBeVisible();
    await expect(page.locator('input[type="email"]')).toBeVisible();
    await expect(page.locator('input[type="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('should load the signup page', async ({ page }) => {
    await page.goto('/register', { waitUntil: 'domcontentloaded' });
    
    await expect(page.locator('text=Create Account').first()).toBeVisible();
    await expect(page.locator('input[type="email"]')).toBeVisible();
    await expect(page.locator('input[type="password"]').first()).toBeVisible();
  });

  // Note: We don't want to actually sign up real users in E2E unless we use a test database.
  // Testing the UI presence is a good start.
});
