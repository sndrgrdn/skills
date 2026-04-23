# Troubleshooting & Workarounds

Common Hotwire issues with symptoms, root causes, and fixes.

## Contents
- [1. Form errors don't render in place](#1-form-errors-dont-render-in-place)
- [2. Event listeners lost after navigation](#2-event-listeners-lost-after-navigation)
- [3. Turbo Frame content disappears or shows "Content missing"](#3-turbo-frame-content-disappears-or-shows-content-missing)
- [4. Stale content flashes on back/forward navigation](#4-stale-content-flashes-on-backforward-navigation)
- [5. Stimulus controller connects multiple times](#5-stimulus-controller-connects-multiple-times)
- [6. Turbo Stream actions silently fail](#6-turbo-stream-actions-silently-fail)
- [7. Double form submissions](#7-double-form-submissions)
- [8. Third-party scripts break after Turbo navigation](#8-third-party-scripts-break-after-turbo-navigation)
- [9. Scroll position resets on frame update](#9-scroll-position-resets-on-frame-update)
- [10. Morph refresh causes input focus/selection loss](#10-morph-refresh-causes-input-focusselection-loss)
- [11. Frame lazy-load fires immediately instead of on scroll](#11-frame-lazy-load-fires-immediately-instead-of-on-scroll)
- [12. Redirect after form submit loads inside the frame](#12-redirect-after-form-submit-loads-inside-the-frame)

---

## 1. Form errors don't render in place

**Symptom:** Form submission with invalid data redirects or shows a blank page instead of inline validation errors.

**Root cause:** Server returns `200 OK` or `302 redirect` for validation failures. Turbo treats any `2xx` as success and any `3xx` as a redirect to follow.

**Fix:** Return `422 Unprocessable Entity` for validation failures. Turbo re-renders the response within the originating frame.

```ruby
# Rails controller
def create
  @item = Item.new(item_params)
  if @item.save
    redirect_to @item, status: :see_other  # 303
  else
    render :new, status: :unprocessable_entity  # 422
  end
end
```

## 2. Event listeners lost after navigation

**Symptom:** JavaScript behavior works on first page load but stops working after clicking a link.

**Root cause:** Turbo replaces the `<body>` on navigation; DOM event listeners attached to specific elements are discarded. Code bound on `DOMContentLoaded` only runs once.

**Fix:** Use one of:
- **Stimulus controllers** — `connect()` re-runs each time the element enters the DOM.
- **Event delegation** on `document` or a persistent ancestor.
- **`turbo:load`** event instead of `DOMContentLoaded` (fires on every navigation).
- **`turbo:frame-render`** for listeners on elements inside frames.

```js
// BAD — only runs once
document.addEventListener('DOMContentLoaded', () => { ... });

// GOOD — runs on every navigation
document.addEventListener('turbo:load', () => { ... });

// BEST — Stimulus handles lifecycle automatically
export default class extends Controller {
  connect() { /* re-runs on every appearance */ }
}
```

## 3. Turbo Frame content disappears or shows "Content missing"

**Symptom:** Frame goes blank or browser shows a "Content missing" error after navigation.

**Root cause:** The server response doesn't contain a `<turbo-frame>` with a matching `id`.

**Fix:**
- Ensure the server response wraps content in `<turbo-frame id="same-id">`.
- In Rails, use `turbo_frame_request?` to conditionally render frame-scoped content vs full page.
- Handle `turbo:frame-missing` event to provide a fallback (e.g., break out to full-page visit).

```js
document.addEventListener('turbo:frame-missing', (event) => {
  event.preventDefault();
  event.detail.visit(event.detail.response);  // Fall back to full page visit
});
```

## 4. Stale content flashes on back/forward navigation

**Symptom:** Navigating back shows outdated UI state (open modals, expanded dropdowns, old data) before the fresh page loads.

**Root cause:** Turbo caches a snapshot of the DOM before navigation. Transient UI state is included in the snapshot.

**Fix:** Clean up transient state in `turbo:before-cache`:

```js
document.addEventListener('turbo:before-cache', () => {
  // Close modals/dropdowns
  document.querySelectorAll('[data-expanded]').forEach(el => {
    el.removeAttribute('data-expanded');
  });
  // Remove flash messages
  document.querySelectorAll('.flash').forEach(el => el.remove());
  // Reset forms
  document.querySelectorAll('form').forEach(form => form.reset());
  // Destroy third-party widgets
  document.querySelectorAll('.select2-container').forEach(el => el.remove());
});
```

See `references/navigation/2023-05-23-turbo-drive-cache-lifecycle.md`.

## 5. Stimulus controller connects multiple times

**Symptom:** Event handlers fire multiple times, counters increment unexpectedly, duplicate DOM elements appear.

**Root cause:** Controller `connect()` adds event listeners or DOM elements but `disconnect()` doesn't clean them up. Turbo's cache restore cycle calls `disconnect()` then `connect()` again.

**Fix:** Ensure symmetric setup/teardown:

```js
export default class extends Controller {
  connect() {
    this.handler = this.handleEvent.bind(this);
    window.addEventListener('resize', this.handler);
  }

  disconnect() {
    window.removeEventListener('resize', this.handler);
  }
}
```

Rules:
- Every `addEventListener` in `connect()` needs a matching `removeEventListener` in `disconnect()`.
- Every `setInterval`/`setTimeout` needs to be cleared in `disconnect()`.
- Every IntersectionObserver/MutationObserver needs `.disconnect()` in `disconnect()`.
- Revoke blob URLs, destroy third-party instances.

## 6. Turbo Stream actions silently fail

**Symptom:** Server sends Turbo Stream HTML but nothing happens on the page.

**Root cause (common):**
1. Response MIME type is not `text/vnd.turbo-stream.html`.
2. `target` ID doesn't match any element in the DOM.
3. Stream is delivered inside a `<turbo-frame>` response instead of as a stream response.

**Fix:**
- In Rails, use `respond_to { |f| f.turbo_stream { ... } }` which sets the correct MIME type.
- Verify target element IDs match exactly (case-sensitive, no `#` prefix in the `target` attribute).
- For WebSocket delivery, confirm the Action Cable subscription is active (check browser DevTools → Network → WS).
- For non-Rails backends, set `Content-Type: text/vnd.turbo-stream.html; charset=utf-8` explicitly.

```ruby
# Rails — correct
respond_to do |format|
  format.turbo_stream { render turbo_stream: turbo_stream.append("items", partial: "item") }
end
```

## 7. Double form submissions

**Symptom:** Form submits twice, creating duplicate records.

**Root cause:** Submit button is not disabled during Turbo's async submission, allowing multiple clicks. Or JavaScript calls `submit()` while Turbo is already handling the native form submission.

**Fix:**
- Turbo automatically disables `<button type="submit">` during submission (sets `disabled` attribute). Ensure CSS reflects disabled state.
- Don't call `form.submit()` programmatically alongside Turbo — use `form.requestSubmit()` instead which triggers Turbo's interception.
- For custom submit triggers, listen for `turbo:submit-start` / `turbo:submit-end` to gate the UI.

```js
form.addEventListener('turbo:submit-start', () => {
  submitButton.disabled = true;
  submitButton.textContent = 'Saving...';
});

form.addEventListener('turbo:submit-end', () => {
  submitButton.disabled = false;
  submitButton.textContent = 'Save';
});
```

## 8. Third-party scripts break after Turbo navigation

**Symptom:** Libraries like Select2, Flatpickr, Chart.js, etc. stop working or produce duplicate widgets after navigating.

**Root cause:** Third-party libraries initialize on `DOMContentLoaded` and don't expect the DOM to be swapped under them. Their init code runs once; teardown never happens.

**Fix:**
- Wrap third-party initialization in Stimulus controllers:
  - `connect()`: initialize the library on the target element.
  - `disconnect()`: call the library's destroy/teardown method.
- Clean leftover DOM artifacts in `turbo:before-cache`.

```js
// flatpickr_controller.js
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    this.picker = flatpickr(this.element, { /* options */ });
  }

  disconnect() {
    this.picker.destroy();
  }
}
```

## 9. Scroll position resets on frame update

**Symptom:** Page scrolls to top or frame scrolls to top after a frame update, losing user's position.

**Root cause:** Turbo Frames don't preserve scroll position by default on content replacement.

**Fix:**
- Add `autoscroll` attribute to the frame element to scroll it into view after load.
- For page-level scroll, use `turbo-refresh-scroll="preserve"` meta tag (Turbo 8 morphing).
- Manually save/restore scroll position with `turbo:before-frame-render` / `turbo:frame-render`:

```js
let savedScroll = 0;

document.addEventListener('turbo:before-frame-render', (event) => {
  savedScroll = document.documentElement.scrollTop;
});

document.addEventListener('turbo:frame-render', () => {
  document.documentElement.scrollTop = savedScroll;
});
```

See `references/navigation/2023-09-12-turbo-frames-scroll-position-restoration.md`.

## 10. Morph refresh causes input focus/selection loss

**Symptom:** User is typing in a form field; a Turbo 8 morph refresh arrives and the input loses focus or the cursor jumps.

**Root cause:** Morph refresh (idiomorph) replaces/patches DOM nodes. Active input elements may be morphed, losing focus state.

**Fix:**
- Use `data-turbo-permanent` on the form or input container to exclude it from morphing.
- Scope morph refreshes: only broadcast refreshes to channels that don't include the editing user.
- Wrap the editable region in a Turbo Frame to isolate it from page-level morph refreshes.

```html
<!-- Excluded from morph refresh -->
<div id="edit-form" data-turbo-permanent>
  <form>
    <input type="text" name="title" autofocus>
  </form>
</div>
```

## 11. Frame lazy-load fires immediately instead of on scroll

**Symptom:** `<turbo-frame loading="lazy" src="...">` loads immediately on page load instead of waiting for visibility.

**Root cause:** The frame is within the viewport on initial render, or is inside an element that has no scroll container (so IntersectionObserver considers it visible immediately).

**Fix:**
- Confirm the frame is actually below the fold / outside the viewport on initial render.
- If the frame is conditionally visible (e.g., inside a collapsed accordion), don't set `src` until the container is expanded — set it dynamically via Stimulus.
- As a fallback, omit `src` initially and set it when the element should load:

```js
export default class extends Controller {
  static targets = ["frame"]

  reveal() {
    this.frameTarget.src = this.frameTarget.dataset.lazySrc;
  }
}
```

## 12. Redirect after form submit loads inside the frame

**Symptom:** After successful form submission with a redirect, the redirect destination renders inside the frame instead of navigating the full page.

**Root cause:** The form is inside a `<turbo-frame>` and the redirect response contains a matching frame. Turbo keeps the navigation scoped to the frame.

**Fix:**
- Set `data-turbo-frame="_top"` on the form to break out to full-page navigation.
- Or use `turbo:submit-end` to manually visit the redirect URL:

```js
document.addEventListener('turbo:submit-end', (event) => {
  if (event.detail.success) {
    const redirectUrl = event.detail.fetchResponse.response.url;
    Turbo.visit(redirectUrl);
  }
});
```

- Or use `turbo:frame-missing` handler (see issue #3) as a global fallback.
