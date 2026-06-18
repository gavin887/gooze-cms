import { test, expect } from '@playwright/test';
import { login, navigateToModule, waitForTableLoad, getToastMessage, confirmDialog } from './utils/auth';

test.describe('分类管理模块 E2E 测试', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
    await navigateToModule(page, '/content/category');
    await waitForTableLoad(page);
  });

  test('页面加载验证', async ({ page }) => {
    await expect(page.getByText('分类管理')).toBeVisible();
    await expect(page.getByRole('button', { name: '新增分类' })).toBeVisible();
    await expect(page.getByRole('button', { name: /展开全部/ })).toBeVisible();
    await expect(page.getByRole('button', { name: /收起全部/ })).toBeVisible();
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

  test('新增分类功能', async ({ page }) => {
    await page.getByRole('button', { name: '新增分类' }).click();

    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await expect(page.getByText('新增分类')).toBeVisible();

    const categoryName = `E2E测试分类_${Date.now()}`;
    const nameInput = page.getByLabel('分类名称');
    await nameInput.fill(categoryName);

    const sortInput = page.getByLabel('排序');
    await sortInput.fill('999');

    await page.getByRole('button', { name: '确定' }).click();

    const message = await getToastMessage(page);
    expect(message).toContain('成功');

    await page.waitForTimeout(1500);
    await waitForTableLoad(page);

    const newCategory = page.getByText(categoryName);
    await expect(newCategory).toBeVisible();
  });

  test('编辑分类功能', async ({ page }) => {
    const categoryName = `E2E测试分类_${Date.now()}`;

    await page.getByRole('button', { name: '新增分类' }).click();
    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await page.getByLabel('分类名称').fill(categoryName);
    await page.getByLabel('排序').fill('999');
    await page.getByRole('button', { name: '确定' }).click();
    await getToastMessage(page);
    await page.waitForTimeout(1500);

    const editButtons = page.getByTitle('编辑').first();
    await editButtons.click();

    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await expect(page.getByText('编辑分类')).toBeVisible();

    const updatedName = `${categoryName}_已更新`;
    await page.getByLabel('分类名称').fill(updatedName);
    await page.getByLabel('排序').fill('888');

    await page.getByRole('button', { name: '确定' }).click();

    const message = await getToastMessage(page);
    expect(message).toContain('成功');

    await page.waitForTimeout(1500);
    await waitForTableLoad(page);

    const updatedCategory = page.getByText(updatedName);
    await expect(updatedCategory).toBeVisible();
  });

  test('状态切换功能', async ({ page }) => {
    const categoryName = `E2E测试分类_${Date.now()}`;

    await page.getByRole('button', { name: '新增分类' }).click();
    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await page.getByLabel('分类名称').fill(categoryName);
    await page.getByRole('radio', { name: '启用' }).click();
    await page.getByRole('button', { name: '确定' }).click();
    await getToastMessage(page);
    await page.waitForTimeout(1500);

    const row = page.getByText(categoryName).first().locator('..').locator('..');
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

  test('删除分类功能', async ({ page }) => {
    const categoryName = `E2E测试分类_${Date.now()}`;

    await page.getByRole('button', { name: '新增分类' }).click();
    await page.waitForSelector('.vben-drawer', { timeout: 5000 });
    await page.getByLabel('分类名称').fill(categoryName);
    await page.getByRole('button', { name: '确定' }).click();
    await getToastMessage(page);
    await page.waitForTimeout(1500);

    const row = page.getByText(categoryName).first().locator('..').locator('..');
    const deleteButton = row.getByTitle('删除').first();
    await deleteButton.click();

    await confirmDialog(page);

    const message = await getToastMessage(page);
    expect(message).toContain('成功');

    await page.waitForTimeout(1500);
    await waitForTableLoad(page);

    const deletedCategory = page.getByText(categoryName);
    await expect(deletedCategory).not.toBeVisible();
  });

  test('展开/收起全部功能', async ({ page }) => {
    await page.getByRole('button', { name: /展开全部/ }).click();
    await page.waitForTimeout(1000);

    await page.getByRole('button', { name: /收起全部/ }).click();
    await page.waitForTimeout(1000);
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
});
