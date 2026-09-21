import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility (a11y)', () => {
  test('homepage should not have any automatically detectable accessibility issues', async ({ page }) => {
    await page.goto('/');
    await page.waitForURL('**/login*');
    await expect(page.locator('h1')).toBeVisible();
    
    const accessibilityScanResults = await new AxeBuilder({ page }).disableRules(['color-contrast']).analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('login page should not have any automatically detectable accessibility issues', async ({ page }) => {
    await page.goto('/login');
    await expect(page.locator('h1')).toBeVisible();
    
    const accessibilityScanResults = await new AxeBuilder({ page }).disableRules(['color-contrast']).analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });
});
