# Gherkin Quality

How to write scenarios that are readable, focused, and maintainable.

## BRIEF Framework

Six principles for good scenarios (from Cucumber docs). Acronym: **BRIEF**.

| Principle | Rule | Common violation |
|-----------|------|------------------|
| **B**usiness language | Use terms stakeholders recognize | "I click on element `input[type='submit']`" |
| **R**eal data | Use concrete, realistic values | "Given a thing exists" (too vague) |
| **I**ntention revealing | Describe intent, not mechanics | "When I fill in field X and click Y" |
| **E**ssential | Only steps that illustrate the rule | Login steps in a checkout scenario |
| **F**ocused | One rule per scenario | Testing validation AND success in one scenario |
| **Brief** | 3–5 steps preferred, 7 max | 15-step journey through the app |

## Scenario Structure

```gherkin
Feature: Order cancellation
  Customers should be able to cancel orders before they're picked up.

  Background:
    Given I am logged in as "jane@example.com"
    And I have an order "ORD-001" with status "reserved"

  Scenario: Cancel a reserved order
    When I cancel order "ORD-001"
    Then the order status should be "cancelled"
    And I should see "Order has been cancelled"

  Scenario: Cannot cancel a picked-up order
    Given order "ORD-001" has been picked up
    When I try to cancel order "ORD-001"
    Then I should see "Cannot cancel a picked-up order"
```

### Structure rules

1. **Feature description**: State the business capability and the rule being illustrated. Not a screen name.
2. **Background**: Only truly shared preconditions. ≤4 lines. If it scrolls off screen, simplify.
3. **Scenario name**: Short declarative statement. Not "Test that..." or "Verify that...".
4. **Given**: Present/present-perfect tense. System state before the user acts.
5. **When**: Present tense. The user's action or triggering event. Usually one `When` per scenario.
6. **Then**: Present tense. Observable outcome. What the user sees, not what the database contains.

## Declarative vs Imperative

The single most important Gherkin writing principle.

| Imperative (bad) | Declarative (good) |
|-----------------|-------------------|
| `When I fill in "email" with "jane@example.com"` | `When I log in as "jane@example.com"` |
| `And I fill in "password" with "secret"` | |
| `And I click "Sign in"` | |
| `When I click on "Add to cart"` | `When I add "Bike" to my cart` |
| `And I click on "Checkout"` | `When I proceed to checkout` |

Declarative scenarios survive UI redesigns. Only the step definition changes.

**Exception**: When the UI interaction IS the behavior being tested (e.g., testing a specific form validation message), imperative steps are acceptable.

## Tags

Use tags for:

| Tag purpose | Example |
|------------|---------|
| Selective execution | `@smoke`, `@regression`, `@admin` |
| Test setup hooks | `@allow_http_401`, `@silence_http_422` |
| Work in progress | `@wip` |
| Known issues | `@flaky`, `@skip` |
| Feature flags | `@feature_sso` |

## When to Use Scenario Outline

Use scenario outlines only when:
- The same behavior varies by input data
- ≤5 rows (more = move to unit tests)
- NOT for browser tests that are inherently slow

```gherkin
Scenario Outline: Login with invalid credentials
  When I log in with email "<email>" and password "<password>"
  Then I should see "<error>"

  Examples:
    | email              | password | error                    |
    | wrong@example.com  | secret   | Invalid email or password |
    | jane@example.com   | wrong    | Invalid email or password |
    |                    | secret   | Email can't be blank      |
```

## When NOT to Write a Cucumber Scenario

Cucumber scenarios are expensive (browser, database, full stack). Don't use them for:

- Unit logic (calculations, validations, transformations)
- Every edge case of a business rule (use RSpec)
- API-only behavior with no UI
- Performance or load testing

**Use Cucumber for**: Critical user journeys, workflows that cross multiple pages, behaviors where the UI interaction is the point.
