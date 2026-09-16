import { test, expect } from '@playwright/test';

test.describe('Public Navigation', () => {
  test('should redirect unauthenticated user from protected routes to login', async ({ page }) => {
    // Attempt to access dashboard
    await page.goto('/dashboard');
    
    // Should be redirected to login
    await expect(page).toHaveURL(/.*\/login/);
  });

  test('homepage should load', async ({ page }) => {
    await page.goto('/');
    
    // Check for some homepage text (adjust based on actual homepage content)
    await expect(page.locator('body')).toContainText(/IT Lab OS/i);
  });
});
