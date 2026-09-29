/**
 * Generic Page Object Model template for Playwright E2E tests.
 *
 * Adapt before use:
 * 1. Rename this file to <feature>.page.ts.
 * 2. Rename FeaturePage to match the page or feature under test.
 * 3. Replace sample locators with user-facing locators from your app.
 * 4. Replace navigation and cleanup with your project's safe test-isolation strategy.
 */

import { Page, Locator, expect } from '@playwright/test';
import { Navigation } from '../helpers/navigation';

export class FeaturePage {
  private readonly navigation: Navigation;

  // ============ Locators ============

  readonly pageHeading: Locator;
  readonly nameInput: Locator;
  readonly saveButton: Locator;
  readonly itemList: Locator;

  constructor(private readonly page: Page) {
    this.navigation = new Navigation(page);

    this.pageHeading = page.getByRole('heading', { name: 'Feature' });
    this.nameInput = page.getByLabel('Name');
    this.saveButton = page.getByRole('button', { name: 'Save' });
    this.itemList = page.getByRole('list', { name: 'Items' });
  }

  // ============ Navigation ============

  async goto(): Promise<void> {
    await this.navigation.goToFeature();
  }

  async gotoWithCleanState(): Promise<void> {
    await this.navigation.goToFeatureWithCleanState();
  }

  // ============ Actions ============

  async createItem(name: string): Promise<void> {
    await this.nameInput.fill(name);
    await this.saveButton.click();
  }

  // ============ Locator Helpers ============

  getItem(name: string): Locator {
    return this.itemList.getByRole('listitem').filter({ hasText: name });
  }

  getAllItems(): Locator {
    return this.itemList.getByRole('listitem');
  }

  // ============ Assertions ============

  async expectReady(): Promise<void> {
    await expect(this.pageHeading).toBeVisible();
  }

  async expectItemToExist(name: string): Promise<void> {
    await expect(this.getItem(name)).toBeVisible();
  }

  async expectItemNotToExist(name: string): Promise<void> {
    await expect(this.getItem(name)).not.toBeVisible();
  }

  async expectItemCount(count: number): Promise<void> {
    await expect(this.getAllItems()).toHaveCount(count);
  }
}