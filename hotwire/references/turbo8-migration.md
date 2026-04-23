# Turbo 7 → Turbo 8 Migration

## Contents
- [What changed](#what-changed)
- [Migration steps](#migration-steps)
- [Morph refreshes](#morph-refreshes)
- [broadcasts_refreshes vs broadcast_replace_to](#broadcasts_refreshes-vs-broadcast_replace_to)
- [New events](#new-events)
- [Opting out of morphing](#opting-out-of-morphing)
- [Gotchas](#gotchas)

---

## What changed

Turbo 8.0 (Feb 2024) / turbo-rails 2.0 — paired releases. Headline feature: **morph-based page refreshes** using [idiomorph](https://github.com/bigskysoftware/idiomorph).

### New meta tags

| Meta name | Values | Default | Effect |
|---|---|---|---|
| `turbo-refresh-method` | `morph`, `replace` | `replace` | Morph vs full body swap on page refresh |
| `turbo-refresh-scroll` | `preserve`, `reset` | `reset` | Scroll behavior during morph refresh |
| `turbo-prefetch` | `true`, `false` | `true` | Link prefetching on hover (new in Turbo 8) |
| `view-transition` | `same-origin` | — | Browser-native View Transitions between pages |

### New stream action: `refresh`

```html
<turbo-stream action="refresh"></turbo-stream>
<turbo-stream action="refresh" request-id="abc-123"></turbo-stream>
```

Tells clients to fetch their current URL and morph/replace. Multiple refreshes are automatically debounced. `request-id` suppresses duplicate refreshes within the same request.

### `method="morph"` on replace/update streams

```html
<turbo-stream action="replace" method="morph" target="item_1">
  <template>New content</template>
</turbo-stream>
```

Ruby: `broadcast_replace_to stream, attributes: { method: :morph }, partial: "..."`.

### Frame `refresh="morph"`

```html
<turbo-frame id="my-frame" refresh="morph" src="/frame_content">
</turbo-frame>
```

Frame re-fetches `src` and morphs instead of full replacement during page refresh.

### Other additions

- **Link prefetching**: enabled by default on hover (100ms debounce). Disable per-link with `data-turbo-prefetch="false"`.
- **`data-turbo-track="dynamic"`**: removes `<link>`/`<style>` when absent from navigation response (no full reload).
- **`data-turbo-visit-direction`**: set on `<html>` during navigations (`forward`/`back`/`none`).
- **`aria-busy`** on `<form>` during submission (was only on `<html>` in Turbo 7).
- **`Turbo.visit` with `frame:` option**: `Turbo.visit("/page", { frame: "my-frame" })`.

---

## Migration steps

### 1. Update versions

```ruby
# Gemfile
gem "turbo-rails", "~> 2.0"
```

```json
// package.json (if using bundler)
"@hotwired/turbo": "^8.0.0"
```

### 2. Address breaking changes

| Removed/Changed | Migration |
|---|---|
| `data-turbo-cache="false"` | Use `<meta name="turbo-cache-control" content="no-cache">` or `turbo_exempts_page_from_cache` |
| `Turbo.clearCache()` | Removed; no direct replacement |
| `SubmitEvent`/`requestSubmit` polyfills | Add your own if supporting Safari < 15.4 |
| `X-Purpose` header for preloads | Renamed to `X-Sec-Purpose` |
| `turbo_meta_tags` helper | Removed from turbo-rails 2.0 (was a no-op) |
| Redirect to same URL | Now treated as page refresh (replace action, not advance) |

### 3. Opt into morph (optional — not auto-enabled)

**Global (layout):**
```erb
<head>
  <%= turbo_refreshes_with(method: :morph, scroll: :preserve) %>
  <%= yield :head %>  <%# REQUIRED — turbo_refreshes_with uses provide :head %>
</head>
```

**Per-page:**
```erb
<%= turbo_refresh_method_tag :morph %>
<%= turbo_refresh_scroll_tag :preserve %>
```

**Recommendation:** Enable per-page first, not globally. Morph interacts with third-party JS, Stimulus DOM mutations, and form state in ways that need testing.

---

## Morph refreshes

A **page refresh** occurs when Turbo navigates to the same pathname the user is already on. With `turbo-refresh-method: morph`, idiomorph diffs the new and current DOM trees and mutates in-place.

**What morphing preserves:**
- Scroll position (with `turbo-refresh-scroll: preserve`)
- Focus on active input (`ignoreActiveValue: true` — focused input value is not overwritten)
- CSS transition states, open dropdowns, third-party widget state (if not morphed)

**What morphing does NOT preserve:**
- Values of non-focused input fields (server sends clean form → morphed to clean)
- DOM nodes added by third-party JS (overwritten by server HTML)
- Cached previews (page refreshes skip preview rendering)

---

## broadcasts_refreshes vs broadcast_replace_to

| | `broadcasts_refreshes` | `broadcast_replace_to` |
|---|---|---|
| **Code** | 1 line in model | Partials + targets + templates |
| **Session context** | ✅ Each client fetches with own session | ❌ Server renders partial without user context |
| **Precision** | Low — full page re-fetched + diffed | High — exactly the changed element |
| **Speed** | Slower — N HTTP round-trips | Faster — HTML pushed via WebSocket |
| **Server load** | Higher — N full page renders | Lower — 1 partial render |
| **Authorization** | Automatic per-client | Must guard broadcast content |
| **Best for** | Content pages, auth-sensitive data | Chat, counters, high-frequency updates |

### Model macros

```ruby
class Board < ApplicationRecord
  broadcasts_refreshes                    # on create/update/destroy
end

class Column < ApplicationRecord
  belongs_to :board, touch: true          # triggers Board's broadcast
  broadcasts_refreshes_to :board          # explicit association broadcast
end
```

### Instance methods

```ruby
record.broadcast_refresh_later_to(*streamables)  # async via job (preferred)
record.broadcast_refresh_to(*streamables)         # synchronous
```

### Subscribe in view

```erb
<%= turbo_stream_from @board %>
```

---

## New events

| Event | Fires when | Cancelable |
|---|---|---|
| `turbo:morph` | After full page morph | No |
| `turbo:before-morph-element` | Before morphing a specific element | **Yes** — skip morph of this element |
| `turbo:before-morph-attribute` | Before morphing an attribute | **Yes** — preserve attribute |
| `turbo:morph-element` | After morphing a specific element | No |

`turbo:before-render` and `turbo:render` gain `renderMethod` property (`"morph"` or `"replace"`).

---

## Opting out of morphing

### Per-element: `data-turbo-permanent`

```html
<div id="edit-form" data-turbo-permanent>
  <!-- Not morphed during refreshes. Requires unique id. -->
</div>
```

### Programmatic: cancel morph events

```js
document.addEventListener("turbo:before-morph-element", (event) => {
  if (event.target.matches("[data-no-morph]")) {
    event.preventDefault();  // skip morphing this element
  }
});

document.addEventListener("turbo:before-morph-attribute", (event) => {
  if (event.detail.attributeName === "data-preserve") {
    event.preventDefault();  // keep original attribute value
  }
});
```

---

## Gotchas

1. **Non-focused input values are overwritten** — Server sends clean form; morph replaces values of unfocused fields. Fix: wrap forms in `data-turbo-permanent`.

2. **Third-party JS DOM mutations are lost** — Date pickers, rich text editors adding DOM nodes get overwritten. Fix: `data-turbo-permanent` on containers managed by third-party JS.

3. **Duplicate IDs break morph scroll preservation** — Idiomorph node matching fails with duplicate `id` attributes.

4. **`turbo_refreshes_with` requires `yield :head`** — Unlike inline tag helpers, it uses `provide`/`yield`. Use `turbo_refresh_method_tag` / `turbo_refresh_scroll_tag` for inline rendering.

5. **Asset changes during morph still trigger full reload** — `data-turbo-track="reload"` elements changing between current and refreshed response cause full page reload.

6. **`broadcasts_refreshes` fires on all lifecycle events** — Registers callbacks on `after_create_commit`, `after_update_commit`, `after_destroy_commit`. Use manual `broadcast_refresh_later_to` for selective behavior.

7. **`data-turbo-permanent` blocks form reset for submitting user** — The form is preserved from morph but also from clearing after successful submission. Combine with a Stimulus controller for manual reset.
