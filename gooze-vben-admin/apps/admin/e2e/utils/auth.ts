import { Page, expect } from '@playwright/test';

export async function login(page: Page, username: string = 'admin', password: string = 'admin') {
  await page.goto('/login');

  await page.waitForSelector('input[name="username"]', { timeout: 10000 });

  await page.fill('input[name="username"]', username);
  await page.fill('input[name="password"]', password);

  await page.click('button[type="submit"]');

  await page.waitForURL(/\/dashboard|\/home/, { timeout: 15000 });

  const currentUrl = page.url();
  expect(currentUrl).toContain('/dashboard');
}

export async function navigateToModule(page: Page, modulePath: string) {
  await page.goto(modulePath);
  await page.waitForLoadState('networkidle');
}

export async function waitForTableLoad(page: Page) {
  await page.waitForSelector('.vxe-table--body', { timeout: 15000 });
  await page.waitForTimeout(1000);
}

export async function getToastMessage(page: Page): Promise<string> {
  const toastSelector = '.toastification-content';
  await page.waitForSelector(toastSelector, { timeout: 5000 });
  const message = await page.textContent(toastSelector);
  return message || '';
}

export async function confirmDialog(page: Page) {
  const confirmButton = page.getByRole('button', { name: /确(定|认)/ });
  if (await confirmButton.isVisible()) {
    await confirmButton.click();
  }
}
