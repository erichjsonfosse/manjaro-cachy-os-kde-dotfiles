---
name: testing-e2e
description: "Reusable Playwright E2E testing guidance. Use when creating or maintaining browser E2E tests, page objects, test isolation helpers, focused assertions, or test-result reports. Starter example: adapt paths, commands, app URLs, and cleanup strategy before production use."
---

# Testing E2E

This skill is a reusable starter example for writing end-to-end tests with Playwright. It is intentionally workflow-neutral: adapt the paths, commands, app startup, report location, permissions, and cleanup strategy to your project before using it as team policy.

## When to Use

Use this skill when you need to:

- Create new Playwright E2E test specifications.
- Add test cases to an existing E2E suite.
- Create or extend Page Object Model classes.
- Debug Playwright test failures.
- Define test isolation and cleanup patterns.
- Document focused E2E test results.

## Workflow

1. Confirm scope and source context: the target feature, page, or workflow, plus any requirements, implementation notes, user request, or exploratory report driving the tests. Ask concise clarifying questions when this is missing.
2. Inspect the repository's existing E2E tests, page objects, helpers, fixtures, Playwright config, and package scripts before writing anything new. Match established patterns.
3. Confirm the app URL or dev-server startup approach and the project's E2E test command when they are not already covered by Playwright config.
4. Identify the useful set of scenarios: happy path, important edge cases, validation, error handling, persistence, accessibility, and navigation as applicable.
5. Update or create page objects only where they make tests clearer and more maintainable.
6. Write specs with user-facing locators and the Arrange, Act, Assert pattern, keeping each test isolated and independent of execution order.
7. Run the focused test command for the new or changed tests, not the full suite.
8. When a test fails, classify it (see Failure Handling) and act accordingly; fix test-code issues, but do not modify production code unless explicitly allowed.
9. Document results in a report under `test-evidence/`, covering scope, files changed, command run, result summary, failure classification, coverage, artifact paths, and recommendations.

## Adapt Before Use

Before adopting this skill in another repository, decide and document:

- **Test command**: the project's E2E test command, whether it runs through a package script, a task runner, or the Playwright CLI directly.
- **App startup**: whether Playwright starts servers through `webServer`, a dev script, Docker, or a shared test environment.
- **Base URL**: where tests navigate, and whether it comes from config or environment variables.
- **Test paths**: where specs, page objects, helpers, fixtures, and reports live.
- **State cleanup**: how each test starts from a clean database, API state, browser storage, tenant, or test account.
- **Browser matrix**: which browsers and devices are required locally and in CI.
- **Tags and projects**: conventions for smoke, regression, accessibility, optional, and flaky tests.
- **Artifacts**: where screenshots, videos, traces, and test-result summaries are saved.
- **Permissions**: whether test agents may edit production code, install dependencies, commit, or open pull requests.

## Suggested Organization

Adjust these paths to match your repository:

```text
e2e/
|-- config/
|   `-- environment.config.ts
|-- helpers/
|   `-- navigation.ts
|-- pages/
|   `-- feature.page.ts
`-- tests/
  `-- feature.spec.ts
test-evidence/
`-- e2e-test-results-YYYY-MM-DD.md
```

## Command Reference

Discover the project's actual commands from its package scripts or task runner, then map them to these purposes:

| Purpose | What to look for |
|---------|------------------|
| Run the full E2E suite in headless mode | The default E2E test command |
| Run one focused spec file | The E2E command with a single spec path argument |
| Open the interactive UI runner | The Playwright UI mode command |
| Run tests in a visible browser | The headed test command |
| Step through a test in debug mode | The debug test command |
| Open the HTML test report | The report-viewing command |

## Test Structure

Follow Arrange, Act, Assert with explicit comments for readability:

```typescript
import { test } from '@playwright/test';
import { FeaturePage } from '../pages/feature.page';

test.describe('Feature Name', () => {
  let featurePage: FeaturePage;

  test.beforeEach(async ({ page }) => {
    featurePage = new FeaturePage(page);
    await featurePage.gotoWithCleanState();
  });

  test('should describe the expected behavior', async () => {
    // Arrange - Set up test data and preconditions
    const itemName = 'Example item';

    // Act - Perform the user action being tested
    await featurePage.createItem(itemName);

    // Assert - Verify user-visible outcomes
    await featurePage.expectItemToExist(itemName);
  });
});
```

### Key Patterns

- **Test isolation**: every test should start from a known state with a helper such as `gotoWithCleanState()`.
- **User behavior**: tests should exercise the UI the way a user would, not internal implementation hooks.
- **Focused assertions**: assert the visible outcome and the meaningful state change, not every incidental DOM detail.
- **Persistence checks**: use `await page.reload()` when a requirement says state must survive reloads or sessions.
- **Independent tests**: tests should not depend on order or data created by previous tests.
- **Readable data**: use descriptive unique test data when state can persist outside a single test.

## Page Object Model

Page objects encapsulate page-specific locators, actions, helper locators, and assertions.

```typescript
import { Page, Locator, expect } from '@playwright/test';
import { Navigation } from '../helpers/navigation';

export class FeaturePage {
  private readonly navigation: Navigation;

  readonly nameInput: Locator;
  readonly saveButton: Locator;
  readonly itemList: Locator;

  constructor(private readonly page: Page) {
    this.navigation = new Navigation(page);
    this.nameInput = page.getByLabel('Name');
    this.saveButton = page.getByRole('button', { name: 'Save' });
    this.itemList = page.getByRole('list', { name: 'Items' });
  }

  async goto(): Promise<void> {
    await this.navigation.goToFeature();
  }

  async gotoWithCleanState(): Promise<void> {
    await this.navigation.goToFeatureWithCleanState();
  }

  async createItem(name: string): Promise<void> {
    await this.nameInput.fill(name);
    await this.saveButton.click();
  }

  getItem(name: string): Locator {
    return this.itemList.getByRole('listitem').filter({ hasText: name });
  }

  async expectItemToExist(name: string): Promise<void> {
    await expect(this.getItem(name)).toBeVisible();
  }
}
```

### Page Object Conventions

- Define reusable locators as `readonly` properties.
- Use action methods named as verbs, such as `createItem`, `openSettings`, or `submitForm`.
- Prefix assertion helpers with `expect`, such as `expectItemToExist`.
- Keep page objects focused on user-visible behavior.
- Add lower-level helper locators only when they make tests clearer.

## Locator Priority

Prefer Playwright locators that reflect the user experience:

| Locator Type | Example | Use For |
|--------------|---------|---------|
| `getByRole` | `page.getByRole('button', { name: 'Save' })` | Buttons, links, headings, lists, checkboxes |
| `getByLabel` | `page.getByLabel('Email')` | Form fields with accessible labels |
| `getByPlaceholder` | `page.getByPlaceholder('Search')` | Inputs where placeholder is the user-facing cue |
| `getByText` | `page.getByText('Order submitted')` | Visible text and status messages |
| `getByTitle` | `page.getByTitle('Close')` | Elements with meaningful title attributes |
| `getByTestId` | `page.getByTestId('invoice-row')` | Stable fallback when user-facing locators are not enough |

Use CSS or XPath only as a last resort. Stable structural containers may use IDs or test IDs when they have no meaningful accessible name, but interactions inside them should still prefer role, label, text, or test ID locators.

## Test Isolation

The cleanup strategy is project-specific. Common approaches include:

- API cleanup before navigation.
- Database reset through a test-only endpoint or fixture.
- Browser storage cleanup with `localStorage.clear()` and `context.clearCookies()`.
- Unique tenant, user, or namespace per test.
- Seed data created through APIs before the UI action.

Example navigation helper pattern:

```typescript
import { Page } from '@playwright/test';

export class Navigation {
  constructor(private readonly page: Page) {}

  async goToFeature(): Promise<void> {
    await this.page.goto('/feature');
    await this.page.getByRole('heading', { name: 'Feature' }).waitFor();
  }

  async goToFeatureWithCleanState(): Promise<void> {
    await this.page.request.post('/test/reset-feature-state');
    await this.page.goto('/feature');
    await this.page.getByRole('heading', { name: 'Feature' }).waitFor();
  }
}
```

## Failure Handling

When a test fails:

1. Re-run the focused test once to distinguish deterministic failure from possible flake.
2. Inspect the error, screenshot, trace, console messages, and network failures when available.
3. Classify the failure as one of: test-code issue, implementation bug, environment/server issue, flaky behavior, or unclear.
4. Fix test-code issues in the test or page object.
5. Do not modify production code unless the user explicitly asks or the agent's local instructions allow it.
6. Document unresolved failures with the command, output, artifact paths, likely cause, and recommended next step.

## Test Result Report

For reusable agents, prefer a simple report under `test-evidence/` unless the user provides another path:

```text
test-evidence/e2e-test-results-YYYY-MM-DD.md
```

The report should include:

- Scope and source context.
- Tests created or changed.
- Command run.
- Result summary.
- Failed test details, if any.
- Coverage against requested scenarios.
- Artifact paths.
- Recommendations.

## Templates

Starter templates are available in this skill folder:

- `templates/spec.template.ts`
- `templates/page.template.ts`
- `templates/test-results.template.md`

## Bundled Agents

Two starter agent definitions ship alongside this skill so the bundle is
self-contained; adapt tools, model, paths, and permissions to your project
before use:

- [General Test Explorer](./agents/general-test-explorer.agent.md) — explores
  the running application to discover and document E2E test scenarios, then
  hands off to the tester.
- [General Tester](./agents/general-tester.agent.md) — creates and maintains
  E2E tests from a feature, requirement, implementation note, or exploratory
  report.

## Anti-Patterns

- Asserting on internal implementation hooks or incidental DOM detail instead of user-visible outcomes.
- Tests that depend on execution order or on data created by a previous test.
- Reusing CSS or XPath selectors when a role, label, text, or test-ID locator would work.
- Skipping state cleanup, so tests pass only against a pre-seeded or leftover database.
- Running the full suite to validate one change instead of a focused spec.
- Treating an exploratory report as product requirements without confirming intended behavior.
- "Fixing" a failing test by changing production code before classifying the failure as a real bug.
- Masking flakiness with arbitrary sleeps instead of explicit waits on observable state.
- Storing secrets, tokens, or credentials in specs, fixtures, reports, screenshots, or logs.

## Critical Rules

- Prefer user-facing locators (`getByRole`, `getByLabel`, `getByText`) over structural selectors, but if you have available test IDs, use them as a stable fallback for important elements that lack good user-facing attributes.
- Every test must start from a known clean state and run independently.
- Classify each failure before acting: test-code issue, implementation bug, environment/server issue, flaky behavior, or unclear.
- Do not modify production application code unless the user explicitly asks or local instructions allow it.
- Do not commit changes or open pull requests unless explicitly asked and equipped with the right workflow.
- Never request, transmit, or store secrets through chat, reports, or artifacts.
- This skill ships tool-neutral examples; replace sample paths, commands, and app URLs with the project's real values before use.