---
name: cucumber-capybara
description: Write and improve Cucumber scenarios with Capybara for browser-based system tests. Use when writing feature files, step definitions, fixing flaky tests, expanding test coverage, or reviewing Gherkin quality. Covers scenario structure, Capybara waiting, step reuse, and common anti-patterns.
---

# Cucumber + Capybara System Tests

Write browser tests that are readable, stable, and fast.

## Core References

| Open when you need to... | Read |
|--------------------------|------|
| write or review Gherkin scenarios | `references/gherkin-quality.md` |
| write or debug step definitions and Capybara interactions | `references/capybara-patterns.md` |
| diagnose or fix a flaky test | `references/flaky-test-fixes.md` |

## Principles

1. **Test behavior, not UI mechanics.** Scenarios describe what the user achieves, not which buttons they click. Step definitions translate intent to Capybara calls.
2. **One scenario = one behavior.** A scenario that tests login AND checkout tests nothing well. Split.
3. **Let Capybara wait.** Never `sleep`. Use assertions that auto-retry (`have_content`, `have_selector`, `have_css`). Capybara polls until the condition is met or `default_max_wait_time` expires.
4. **Keep scenarios brief.** 3–7 steps. If longer, you're testing too much or including incidental setup.
5. **Steps are reusable atoms.** Organize by domain concept, not by feature file. A `Given I am logged in` step belongs in auth steps, not in every feature's step file.
6. **Avoid testing implementation.** Don't assert on database state, CSS classes, or DOM structure. Assert on what the user sees.

## Scenario Checklist

Before committing a scenario, verify:

- [ ] Scenario name is a short declarative statement of the behavior
- [ ] Each step uses business/domain language, not UI jargon
- [ ] Step count ≤ 7 (ideally 3–5)
- [ ] Only one When-Then behavior per scenario
- [ ] Background contains only shared setup that applies to ALL scenarios in the file
- [ ] No hardcoded config data (URLs, passwords) in Gherkin — use step definitions or hooks
- [ ] Tags are applied for selective execution or test setup (`@smoke`, `@wip`, etc.)

## Step Definition Checklist

Before committing a step definition:

- [ ] Step is generic enough to reuse across features
- [ ] Uses Capybara's waiting finders (`find`, `have_selector`) not immediate ones (`all`, `first`)
- [ ] No `sleep` calls — use `have_content`, `have_selector`, or `using_wait_time` for slow operations
- [ ] Keeps Capybara mechanics (clicks, fills, selects) in the step definition, not in the scenario text
- [ ] Does not call other steps (no `step %[...]` nesting) — extract shared logic into Ruby helper methods

## Anti-Pattern Quick Reference

| Anti-pattern | Symptom | Fix |
|-------------|---------|-----|
| UI procedure | Steps say "click", "type", "select" | Use domain language: "I log in", "I add a product" |
| Swiss army scenario | One scenario tests 5 behaviors | Split into focused scenarios |
| Conjunction step | `Given I have shades and a Mustang and am on the highway` | Use separate `Given`/`And` steps |
| Sleep-driven test | `sleep 2` before assertion | Use Capybara matchers that auto-wait |
| Feature-coupled steps | Steps only work for one feature file | Name steps by domain concept |
| Scenario outline abuse | 20-row outline through the browser | Move edge cases to unit tests; keep ≤5 rows for browser tests |
| Database assertion | `expect(User.count).to eq(1)` | Assert on visible output; if DB check needed, wait for visual confirmation first |
| Stale element | Store `find(...)` result, use it after DOM change | Re-find the element after the action |
