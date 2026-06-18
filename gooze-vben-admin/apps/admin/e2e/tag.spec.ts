import { test, expect } from '@playwright/test';
import { login, navigateToModule, waitForTableLoad, getToastMessage, confirmDialog } from './utils/auth';

test.describe('标签管理模块 E2E 测试', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
    await navigateToModule(page, '/content/tag');
    await waitForTableLoad(page);
  });

  test('页面加载验证', async ({ page }) => {
    await expect(page.getByText('标签管理')).toBeVisible();
    await expect(page.getByRole('button', { name: '新增标签' })).toBeVisible();
    await expect(page.locator('.vxe-table--body')).toBeVisible();
  });

  test('搜索筛选功能', async ({ page }) => {
    const searchInput = page.getByPlaceholder('请输入').first();
    await searchInput.fill('测试');
    await searchInput.press('Enter');
    await page.waitForTimeout(1000);
    await waitForTableLoad(page);

    const statusSelect = page.getByPlaceholder('请选择').first();
    await statusSelect.click();
    await page.getByText('启用').click();
    await page.waitForTimeout(1000);
    await waitForTableLoad(page);

    const resetButton = page.getByRole('button', { name: '重置' });
    if (await resetButton.isVisible()) {
      await resetButton.click();
      await page.waitForTimeout(1000);
    }
  });

  test('新增标签功能', async ({ page }) => {
    await page.getByRole('button', { name: '新增标签' }).click();

    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await expect(page.getByText('新增标签')).toBeVisible();

    const tagName = `E2E测试标签_${Date.now()}`;
    const nameInput = page.getByLabel('标签名称');
    await nameInput.fill(tagName);

    const sortInput = page.getByLabel('排序');
    await sortInput.fill('999');

    await page.getByRole('button', { name: '确定' }).click();

    const message = await getToastMessage(page);
    expect(message).toContain('成功');

    await page.waitForTimeout(1500);
    await waitForTableLoad(page);

    const newTag = page.getByText(tagName);
    await expect(newTag).toBeVisible();
  });

  test('编辑标签功能', async ({ page }) => {
    const tagName = `E2E测试标签_${Date.now()}`;

    await page.getByRole('button', { name: '新增标签' }).click();
    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await page.getByLabel('标签名称').fill(tagName);
    await page.getByLabel('排序').fill('999');
    await page.getByRole('button', { name: '确定' }).click();
    await getToastMessage(page);
    await page.waitForTimeout(1500);

    const editButtons = page.getByTitle('编辑').first();
    await editButtons.click();

    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await expect(page.getByText('编辑标签')).toBeVisible();

    const updatedName = `${tagName}_已更新`;
    await page.getByLabel('标签名称').fill(updatedName);
    await page.getByLabel('排序').fill('888');

    await page.getByRole('button', { name: '确定' }).click();

    const message = await getToastMessage(page);
    expect(message).toContain('成功');

    await page.waitForTimeout(1500);
    await waitForTableLoad(page);

    const updatedTag = page.getByText(updatedName);
    await expect(updatedTag).toBeVisible();
  });

  test('状态切换功能', async ({ page }) => {
    const tagName = `E2E测试标签_${Date.now()}`;

    await page.getByRole('button', { name: '新增标签' }).click();
    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await page.getByLabel('标签名称').fill(tagName);
    await page.getByRole('radio', { name: '启用' }).click();
    await page.getByRole('button', { name: '确定' }).click();
    await getToastMessage(page);
    await page.waitForTimeout(1500);

    const row = page.getByText(tagName).first().locator('..').locator('..');
    const switchElement = row.locator('.el-switch');

    const initialState = await switchElement.getAttribute('class');
    const isInitiallyActive = initialState?.includes('is-checked');

    await switchElement.click();
    const message = await getToastMessage(page);
    expect(message).toContain('成功');

    await page.waitForTimeout(1000);

    const newState = await switchElement.getAttribute('class');
    const isNowActive = newState?.includes('is-checked');

    expect(isNowActive).toBe(!isInitiallyActive);
  });

  test('删除标签功能', async ({ page }) => {
    const tagName = `E2E测试标签_${Date.now()}`;

    await page.getByRole('button', { name: '新增标签' }).click();
    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await page.getByLabel('标签名称').fill(tagName);
    await page.getByRole('button', { name: '确定' }).click();
    await getToastMessage(page);
    await page.waitForTimeout(1500);

    const row = page.getByText(tagName).first().locator('..').locator('..');
    const deleteButton = row.getByTitle('删除').first();
    await deleteButton.click();

    await confirmDialog(page);

    const message = await getToastMessage(page);
    expect(message).toContain('成功');

    await page.waitForTimeout(1500);
    await waitForTableLoad(page);

    const deletedTag = page.getByText(tagName);
    await expect(deletedTag).not.toBeVisible();
  });

  test('列表导出功能', async ({ page }) => {
    const exportButton = page.getByTitle('导出数据');
    if (await exportButton.isVisible()) {
      const downloadPromise = page.waitForEvent('download');
      await exportButton.click();
      const download = await downloadPromise;
      expect(download.suggestedFilename()).toContain('.xlsx');
    }
  });

  test('分页功能', async ({ page }) => {
    for (let i = 0; i < 15; i++) {
      await page.getByRole('button', { name: '新增标签' }).click();
      await page.waitForSelector('.vben-drawer', { timeout: 5000 });
      await page.getByLabel('标签名称').fill(`分页测试标签_${Date.now()}_${i}`);
      await page.getByRole('button', { name: '确定' }).click();
      await getToastMessage(page);
      await page.waitForTimeout(800);
    }

    await waitForTableLoad(page);

    const pagination = page.locator('.vxe-pager');
    if (await pagination.isVisible()) {
      const page2Button = pagination.getByText('2');
      if (await page2Button.isVisible()) {
        await page2Button.click();
        await page.waitForTimeout(1000);
        await waitForTableLoad(page);
      }
    }
  });
});
