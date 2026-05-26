# Flaky Test Fixes

Symptom → cause → fix matrix for intermittently failing browser tests.

## Diagnosis Workflow

1. **Reproduce**: Run the test 5–10 times. If it passes every time, check CI environment differences (CPU, browser version, screen size).
2. **Inspect visually**: Run headful (`BROWSER=chrome` instead of `headless_chrome`) and watch. Add `save_screenshot` at the failure point.
3. **Check timing**: Is the assertion running before the page has updated? Look for missing waiting assertions.
4. **Check isolation**: Does the test pass alone but fail in suite? Look for leaked state (database, session, cookies).

## Common Flaky Patterns

| Symptom | Cause | Fix |
|---------|-------|-----|
| Element not found | Page hasn't loaded yet | Use waiting finder: `find(selector)` or assert `have_selector` before interacting |
| Wrong content on page | Previous action hasn't completed | Add assertion for the intermediate state before checking the final state |
| Click doesn't work | Element is obscured or still animating | Use `scroll_to(element)` first; disable CSS animations in test config |
| Stale element reference | DOM updated between find and interaction | Re-find the element after any action that changes the DOM |
| Element found but wrong one | `all(...)` returns stale list | Use `find(selector, match: :first)` or `within(scope)` to narrow |
| Test passes locally, fails on CI | Timing difference (CI is slower) | Increase `using_wait_time` for slow operations; never use `sleep` |
| Database assertion fails | UI action hasn't persisted yet | Assert on visible feedback first, then check DB: `expect(page).to have_content('Saved'); expect(Order.count).to eq(1)` |
| Test fails after unrelated change | Leaked state from another test | Check `DatabaseCleaner` config; ensure test creates its own data |
| Modal/dialog not found | Animation delay | Disable animations: `Capybara.disable_animation = true` |
| File download assertion fails | Download hasn't completed | Wait for a success indicator before checking the file |
| "Element click intercepted" | Overlay, sticky header, or scroll position | `scroll_to(element)` or use `find(selector).click` instead of `click_on` |

## Animations and Scrolling

### Disable animations globally

```ruby
# In test setup
Capybara.disable_animation = true
```

Or inject CSS:

```ruby
page.execute_script <<~JS
  const style = document.createElement('style');
  style.textContent = '*, *::before, *::after { animation-duration: 0s !important; transition-duration: 0s !important; }';
  document.head.appendChild(style);
JS
```

### Handle scroll-dependent interactions

```ruby
element = find('#save-button')
scroll_to(element)
element.click
```

For headless Chrome, disable smooth scrolling:

```ruby
# In Capybara driver registration
opts['smooth-scrolling'] = false
```

## Race Condition Patterns

### Pattern: Action → Wait → Assert

```ruby
# BAD: Assert immediately after action
click_on 'Delete'
expect(Order.count).to eq(0)  # May run before delete completes

# GOOD: Wait for visible feedback, then assert
click_on 'Delete'
expect(page).to have_content('Order deleted')  # Waits for confirmation
expect(Order.count).to eq(0)  # Now safe to check DB
```

### Pattern: AJAX form submission

```ruby
# BAD: Navigate immediately after submit
click_on 'Save'
visit orders_path  # May navigate before save completes

# GOOD: Wait for redirect or success indicator
click_on 'Save'
expect(page).to have_current_path(orders_path)  # Waits for redirect
```

### Pattern: Turbo Drive navigation

```ruby
# BAD: Check content immediately after click
click_on 'Next page'
expect(page).to have_content('Page 2')  # May find "Page 2" link text on current page

# GOOD: Wait for a unique element on the target page
click_on 'Next page'
expect(page).to have_selector('h1', text: 'Page 2')  # More specific
```

## When to Use `using_wait_time`

Only for operations that legitimately take longer than `default_max_wait_time`:

- File uploads/processing
- External service calls
- Complex data operations
- PDF/export generation

```ruby
click_on 'Generate report'
using_wait_time(15) do
  expect(page).to have_content('Report ready')
end
```

## When to Quarantine

Quarantine a test (`@flaky` tag + skip) only when:
- You've spent >30 min debugging without finding the cause
- The test blocks CI for the team
- You've created a ticket to investigate

Never leave a quarantined test indefinitely. Review weekly.

## The Nuclear Option: `sleep`

**Don't.** If every other approach has failed and you truly cannot find a waiting condition:

1. Document WHY with a comment
2. Use the smallest possible value
3. Create a ticket to fix it properly
4. Consider whether the feature itself needs a testability improvement (e.g., adding a loading indicator)
