# Capybara Patterns

How to write step definitions that are stable, fast, and debuggable.

## Waiting: The Core Concept

Capybara polls the DOM until a condition is met or `default_max_wait_time` expires. This only works with the **right methods**.

### Methods that wait (use these)

| Method | Waits for |
|--------|-----------|
| `find(selector)` | Element to appear |
| `click_on(text)` | Element to be clickable |
| `fill_in(locator, with:)` | Input to be present |
| `have_content(text)` | Text to appear anywhere on page |
| `have_selector(selector)` | Element matching selector to appear |
| `have_css(selector)` | Same as `have_selector` for CSS |
| `have_no_content(text)` | Text to disappear |
| `have_no_selector(selector)` | Element to disappear |
| `have_field(name, with:)` | Field with specific value |

### Methods that DON'T wait (avoid or use carefully)

| Method | Problem | Alternative |
|--------|---------|-------------|
| `all(selector)` | Returns empty array immediately if no matches | Assert first: `expect(page).to have_selector(selector)` then `all(...)` |
| `first(selector)` | Returns `nil` immediately if no match | Use `find(selector, match: :first)` |
| `page.text` | Returns current text without waiting | Use `have_content` matcher |
| `evaluate_script(...)` | Executes immediately | Use `have_selector` or `have_content` to wait for JS effects |
| `execute_script(...)` | No waiting | Last resort only; prefer Capybara DSL |

## The Golden Rule

```ruby
# BAD: Check then act (race condition)
if page.has_selector?('.modal')
  find('.modal .close').click
end

# GOOD: Act with waiting
find('.modal .close').click  # Waits for modal to appear, then clicks
```

```ruby
# BAD: Immediate value check
expect(find('#total').text).to eq('$100')  # Gets text NOW, may be stale

# GOOD: Waiting assertion
expect(page).to have_css('#total', text: '$100')  # Polls until match
```

## Checking Absence

```ruby
# BAD: Waits full timeout then passes (slow when correct)
expect(page).not_to have_selector('.error')

# GOOD: Wait for the positive state first, then check absence without waiting
expect(page).to have_content('Success')
expect(page).to have_no_selector('.error', wait: 0)
```

## Handling Slow Operations

For operations that legitimately take longer than `default_max_wait_time`:

```ruby
# Increase wait time for this specific block
using_wait_time(10) do
  expect(page).to have_content('Export complete')
end
```

**Never use `sleep`.** If you think you need `sleep`, you need a waiting assertion instead.

## Step Definition Organization

### Do: Organize by domain concept

```
features/step_definitions/
  auth_steps.rb           # Login, logout, permissions
  order_steps.rb          # Creating, editing, cancelling orders
  product_steps.rb        # Product CRUD
  navigation_steps.rb     # Visiting pages, clicking navigation
  assertion_steps.rb      # Generic "I should see" type assertions
```

### Don't: Organize by feature file

```
# BAD — leads to duplication
features/step_definitions/
  checkout_feature_steps.rb
  product_list_feature_steps.rb
```

## Step Reuse

### Do: Extract helper methods

```ruby
# In a support file
module AuthHelpers
  def sign_in_as(email, password: 'testtest')
    visit login_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Sign in'
    expect(page).to have_content('Dashboard')
  end
end

World(AuthHelpers)

# In step definition
Given('I am logged in as {string}') do |email|
  sign_in_as(email)
end
```

### Don't: Call steps from steps

```ruby
# BAD — hard to debug, breaks stack traces
Given('I have a complete order') do
  step 'I am logged in as "jane@example.com"'
  step 'I create a new order'
  step 'I add product "Bike" to the order'
end

# GOOD — use Ruby methods
Given('I have a complete order') do
  sign_in_as('jane@example.com')
  order = create_order(customer: 'Jane')
  add_product_to_order(order, 'Bike')
end
```

## Selectors

### Priority order

1. **Text/label** — `click_on 'Save'`, `fill_in 'Email'`
2. **Accessible role** — `find(:button, 'Submit')`, `find(:link, 'Home')`
3. **Data attribute** — `find('[data-testid="order-total"]')`
4. **CSS class** — Avoid; breaks when styling changes
5. **XPath** — Last resort; hard to read

### Test-specific attributes

Add `data-testid` attributes for elements that are hard to select otherwise:

```haml
.order-summary{ data: { testid: 'order-summary' } }
```

```ruby
find('[data-testid="order-summary"]')
```

## Modals and Confirmations

```ruby
# Native browser confirm/alert dialogs
page.driver.browser.switch_to.alert.accept   # Click OK
page.driver.browser.switch_to.alert.dismiss   # Click Cancel
page.driver.browser.switch_to.alert.text      # Read message

# Turbo confirm (data-turbo-confirm)
# These use native browser dialogs — same approach as above

# Custom modal dialogs
within('.modal') do
  click_on 'Confirm'
end
```

## Forms

```ruby
# Text input
fill_in 'Name', with: 'Jane Doe'

# Select dropdown
select 'Canada', from: 'Country'

# Checkbox
check 'Terms and conditions'
uncheck 'Newsletter'

# Radio button
choose 'Express shipping'

# File upload
attach_file 'Document', Rails.root.join('spec/fixtures/sample.pdf')

# Submit
click_on 'Save'                    # By button text
find('input[type="submit"]').click  # By selector (less preferred)
```

## Scoping

```ruby
# Scope interactions to a specific area of the page
within('#sidebar') do
  click_on 'Settings'
end

within_table('Users') do
  expect(page).to have_content('jane@example.com')
end

# Scope to a specific row
within('tr', text: 'Jane Doe') do
  click_on 'Edit'
end
```

## Debugging

```ruby
# Save page HTML to tmp/
save_page

# Save screenshot to tmp/
save_screenshot

# Open page in browser (requires launchy gem)
save_and_open_page

# Print current URL
puts current_url

# Print element details
puts find('#my-element').native.attribute('outerHTML')
```
