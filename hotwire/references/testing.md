# Testing Hotwire Features

## Contents
- [Test helper setup](#test-helper-setup)
- [Turbo Stream assertions](#turbo-stream-assertions)
- [Turbo Frame assertions](#turbo-frame-assertions)
- [Controller / integration tests](#controller--integration-tests)
- [Broadcast tests](#broadcast-tests)
- [System tests (Capybara)](#system-tests-capybara)
- [Stimulus controller testing](#stimulus-controller-testing)
- [Common pitfalls](#common-pitfalls)

---

## Test helper setup

turbo-rails auto-includes helpers in matching test base classes. Explicit includes for unusual setups:

```ruby
# ActionDispatch::IntegrationTest
include Turbo::TestAssertions
include Turbo::TestAssertions::IntegrationTestAssertions

# ActionCable::Channel::TestCase (broadcast tests)
include Turbo::Broadcastable::TestHelper
include ActiveJob::TestHelper
include Turbo::Streams::ActionHelper

# ActionDispatch::SystemTestCase
include Turbo::SystemTestHelper
```

---

## Turbo Stream assertions

### `assert_turbo_stream` / `assert_no_turbo_stream`

```ruby
assert_turbo_stream action: "replace", target: "message_1"
assert_turbo_stream action: "replace", target: @message       # ActiveRecord → dom_id
assert_turbo_stream action: "replace", targets: "#message_4"  # CSS selector (targets= attribute)
assert_turbo_stream action: :replace, count: 5

assert_turbo_stream action: "replace", target: "message_1" do
  assert_select "template p", text: "Hello!"
end

assert_no_turbo_stream action: "update", target: "messages"
```

**Integration test version** also checks HTTP status and MIME type:

```ruby
post messages_path, as: :turbo_stream
assert_turbo_stream status: :created, action: "append", target: "messages"
```

---

## Turbo Frame assertions

### `assert_turbo_frame` / `assert_no_turbo_frame`

```ruby
assert_turbo_frame "tray"
assert_turbo_frame @message                          # ActiveRecord → dom_id
assert_turbo_frame "tray", src: "/trays/1"
assert_turbo_frame "tray", loading: "lazy"
assert_turbo_frame "tray", count: 2

assert_turbo_frame "example" do
  assert_select "p", text: "Hello!"
end

assert_no_turbo_frame "missing"
```

---

## Controller / integration tests

### Turbo Stream responses

```ruby
class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "POST responds with turbo stream" do
    post messages_path, as: :turbo_stream  # sets Accept: text/vnd.turbo-stream.html

    assert_turbo_stream status: :created, action: :append, target: "messages"
    assert_no_turbo_stream status: :created, action: :update, target: "messages"
  end
end
```

### Turbo Frame requests

```ruby
test "frame requests get minimal layout" do
  get tray_path(id: 1), headers: { "Turbo-Frame" => "tray" }
  assert_select "title", count: 0  # frame-scoped, no full layout
end
```

### Testing morph refresh meta tags

```ruby
test "configuring refresh strategy" do
  get trays_path
  assert_match(/<meta name="turbo-refresh-method" content="morph">/, @response.body)
  assert_match(/<meta name="turbo-refresh-scroll" content="preserve">/, @response.body)
end
```

---

## Broadcast tests

### `assert_turbo_stream_broadcasts` / `capture_turbo_stream_broadcasts`

```ruby
class MyTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "broadcasts replace and remove" do
    assert_turbo_stream_broadcasts "messages", count: 2 do
      @message.broadcast_replace_to "messages"
      @message.broadcast_remove_to "messages"
    end
  end

  test "inspect broadcast content" do
    replace, remove = capture_turbo_stream_broadcasts "messages" do
      @message.broadcast_replace_to "messages"
      @message.broadcast_remove_to "messages"
    end
    assert_equal "replace", replace["action"]
    assert_equal "remove", remove["action"]
  end

  test "no broadcasts" do
    assert_no_turbo_stream_broadcasts "messages" do
      # nothing
    end
  end
end
```

### Async broadcasts (`_later` methods)

```ruby
test "broadcasting append later" do
  assert_broadcast_on "stream", turbo_stream_action_tag("append", target: "messages", template: render(@message)) do
    perform_enqueued_jobs do
      @message.broadcast_append_later_to "stream"
    end
  end
end
```

### Debounced refresh testing

```ruby
test "broadcast_refresh_later is debounced" do
  assert_broadcasts(@message.to_gid_param, 1) do
    perform_enqueued_jobs do
      3.times { @message.broadcast_refresh_later }
      Turbo::StreamsChannel.refresh_debouncer_for(@message).wait
    end
  end
end
```

### Building expected broadcast strings

```ruby
turbo_stream_action_tag("replace", target: "message_1", template: "<p>Hello</p>")
turbo_stream_action_tag("replace", target: "message_1", method: :morph, template: "...")
turbo_stream_refresh_tag
turbo_stream_refresh_tag(request_id: "abc123")
```

---

## System tests (Capybara)

### Driver setup

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

### Cable stream auto-connect

`Turbo::SystemTestHelper` auto-waits for `<turbo-cable-stream-source>` elements to connect after `visit`. Configure:

```ruby
# config/environments/test.rb
config.turbo.test_connect_after_actions << :click_link  # add more actions
config.turbo.test_connect_after_actions = []             # disable auto-connect
```

Manual connect:
```ruby
connect_turbo_cable_stream_sources
```

### Testing broadcasts in system tests

```ruby
test "Message broadcasts Turbo Streams" do
  visit messages_path
  assert_no_text "New message"

  Message.create(content: "New message").broadcast_append_to(:messages)

  within("#messages") { assert_text "New message" }
end
```

### Assert cable stream sources

```ruby
assert_turbo_cable_stream_source @message, connected: true
assert_no_turbo_cable_stream_source "nonexistent"
```

### Bulletproof `wait_for_turbo` helper

Turbo Drive sets `html[aria-busy]` during navigation, but there's a gap between form submission redirect and next page load. Use custom attributes:

```erb
<!-- layout -->
<html data-turbo-not-loaded="1">
```

```javascript
document.addEventListener("turbo:load", () => {
  document.documentElement.removeAttribute("data-turbo-not-loaded");
  document.documentElement.removeAttribute("data-turbo-loading");
});
document.addEventListener("turbo:submit-start", (event) => {
  if (!event.target.closest("turbo-frame")) {
    document.documentElement.setAttribute("data-turbo-loading", "1");
  }
});
document.addEventListener("turbo:submit-end", (event) => {
  if (!event.detail.fetchResponse?.redirected) {
    document.documentElement.removeAttribute("data-turbo-loading");
  }
});
```

```ruby
def wait_for_turbo
  page.assert_no_selector(
    "html[aria-busy], form[aria-busy], turbo-frame[aria-busy], " \
    "html[data-turbo-not-loaded], html[data-turbo-loading]",
    visible: :all
  )
end
```

---

## Stimulus controller testing

### Jest / Vitest setup

```bash
yarn add -D vitest jsdom
# or: yarn add -D jest jest-environment-jsdom mutationobserver-shim
```

```typescript
// vitest.config.ts
export default defineConfig({
  test: { environment: 'jsdom' }
})
```

### Full test template

```javascript
import { Application } from '@hotwired/stimulus'
import MyController from '../../app/javascript/controllers/my_controller'

const fixture = `
  <div data-controller="my">
    <button data-action="my#toggle" data-testid="btn">Toggle</button>
    <span data-my-target="output"></span>
  </div>
`

let application

beforeEach((done) => {
  document.body.innerHTML = fixture
  application = Application.start()
  application.register('my', MyController)
  // Wait for MutationObserver to fire and connect controller
  Promise.resolve().then(() => done())
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ''
})

test('toggle updates output', () => {
  document.querySelector('[data-testid="btn"]').click()
  expect(document.querySelector('[data-my-target="output"]').textContent).toBe('on')
})
```

### Key patterns

**Test via DOM events, not controller methods:**
```javascript
// BAD: bypasses Stimulus event routing
controller.toggle()

// GOOD: tests the full data-action → method path
document.querySelector('[data-action="my#toggle"]').click()
```

**Test value changes:**
```javascript
const el = document.querySelector('[data-controller="my"]')
el.setAttribute('data-my-count-value', '10')
await new Promise(r => setTimeout(r, 0))  // wait for MutationObserver
expect(el.textContent).toContain('10')
```

**Extract business logic for pure unit tests:**
```javascript
// playlist.js — pure logic, no DOM
export class PlayableList {
  skipForward() { /* ... */ }
}

// playlist_controller.js — thin adapter
export default class extends Controller {
  connect() { this.list = new PlayableList() }
  next() { this.list.skipForward(); this.render() }
}

// Test PlayableList directly — no Stimulus setup needed
```

---

## Common pitfalls

| Pitfall | Solution |
|---|---|
| `MutationObserver` not in jsdom | Add `mutationobserver-shim` to test setup |
| Controller instances accumulate | Call `application.stop()` in `afterEach` |
| `connect()` runs before test assertions | Mount HTML inside test + `await Promise.resolve()` |
| `_later` broadcasts don't fire | Wrap with `perform_enqueued_jobs` |
| Refresh broadcasts fire multiple times | Use `refresh_debouncer_for(...).wait` |
| `aria-busy` gap causes flaky system tests | Use `wait_for_turbo` helper or Capybara click patch |
| Frames don't fire `turbo:load` | Use `assert_selector` (retries) instead of waiting for `turbo:load` |
| Cable stream source not connected | Use `connect_turbo_cable_stream_sources` or auto-connect |
| Testing `connect()` in `beforeEach` | Mount HTML inside the test, not in setup |
| `application.register` without `stop()` | Listeners stack; always pair register with stop |
