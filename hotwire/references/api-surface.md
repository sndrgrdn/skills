# Hotwire API Surface

## Contents
- [Turbo Drive](#turbo-drive)
- [Turbo Frames](#turbo-frames)
- [Turbo Streams](#turbo-streams)
- [Stimulus](#stimulus)

---

## Turbo Drive

Intercepts link clicks and form submissions, replacing full page loads with fetch + DOM swap.

### Key attributes

| Attribute | Element | Effect |
|---|---|---|
| `data-turbo="false"` | `<a>`, `<form>`, any ancestor | Disables Turbo for this element and descendants |
| `data-turbo-method="post\|put\|patch\|delete"` | `<a>` | Turns link click into a non-GET fetch |
| `data-turbo-confirm="message"` | `<a>`, `<form>` | Shows confirmation dialog before proceeding |
| `data-turbo-action="advance\|replace"` | `<a>`, `<form>` | Controls history entry (push vs replace) |
| `data-turbo-prefetch="false"` | `<a>`, ancestor | Disables link prefetching on hover |
| `data-turbo-permanent` | any element with `id` | Persists element across page navigations |

### Lifecycle events

| Event | Fires when | `event.detail` |
|---|---|---|
| `turbo:click` | Turbo-eligible link clicked | `{ url }` |
| `turbo:before-visit` | Before navigation starts | `{ url }` — cancelable |
| `turbo:visit` | Visit starts | `{ url, action }` |
| `turbo:before-render` | Before new body is rendered | `{ newBody, render }` — cancelable, overridable |
| `turbo:render` | After rendering | `{ renderMethod }` (`"replace"` or `"morph"`) |
| `turbo:load` | Page fully loaded (initial + navigations) | `{ url, timing }` |
| `turbo:before-cache` | Before page is written to cache | — |
| `turbo:submit-start` | Form submission begins | `{ formSubmission }` |
| `turbo:submit-end` | Form submission completes | `{ formSubmission }` with `success` flag |
| `turbo:before-fetch-request` | Before any Turbo fetch | `{ fetchOptions }` — modify headers here |
| `turbo:before-fetch-response` | After fetch, before processing | `{ fetchResponse }` |
| `turbo:fetch-request-error` | Network error during fetch | `{ request, error }` |

### Meta tags

| Meta name | Values | Effect |
|---|---|---|
| `turbo-visit-control` | `reload` | Forces full reload for this page |
| `turbo-cache-control` | `no-cache`, `no-preview` | Controls caching behavior |
| `turbo-refresh-method` | `morph`, `replace` | Turbo 8: morph vs full replace on refresh |
| `turbo-refresh-scroll` | `preserve`, `reset` | Turbo 8: scroll behavior on morph refresh |

---

## Turbo Frames

Scope navigation and updates to a `<turbo-frame>` region.

### Element: `<turbo-frame>`

| Attribute | Effect |
|---|---|
| `id` (required) | Frame identity — response must include matching `<turbo-frame id>` |
| `src` | Lazy-loads content from URL on connect |
| `loading="lazy"` | Defers `src` load until frame is visible (IntersectionObserver) |
| `target="_top"` | Breaks out of frame — navigates full page |
| `data-turbo-action="advance"` | Pushes frame navigations into browser history |
| `disabled` | Prevents frame from loading or navigating |
| `autoscroll` | Scrolls frame into view after load |
| `autoscroll-block="start\|center\|end\|nearest"` | Controls scroll alignment |
| `complete` | Boolean attribute present when frame has loaded |

### Frame lifecycle events

| Event | Fires when |
|---|---|
| `turbo:before-frame-render` | Before frame content is rendered — cancelable, render overridable |
| `turbo:frame-render` | After frame content is rendered |
| `turbo:frame-load` | After frame navigation completes |
| `turbo:frame-missing` | Frame response doesn't contain matching frame ID |

### Frame behavior rules

- Links and forms inside a frame target that frame by default.
- `data-turbo-frame="frame-id"` on a link/form targets a different frame.
- `data-turbo-frame="_top"` breaks out to full-page navigation.
- Frame `src` changes trigger a new fetch.
- The `busy` attribute is added during loading (CSS: `turbo-frame[busy]`).

---

## Turbo Streams

Server-pushed DOM mutations via 8 built-in actions (+ custom actions).

### Built-in actions

| Action | Effect | Requires `target` or `targets` |
|---|---|---|
| `append` | Appends content to target | `target` |
| `prepend` | Prepends content to target | `target` |
| `replace` | Replaces target element entirely | `target` |
| `update` | Replaces target's innerHTML | `target` |
| `remove` | Removes target element | `target` |
| `before` | Inserts content before target | `target` |
| `after` | Inserts content after target | `target` |
| `refresh` | Turbo 8: triggers morph refresh | neither (optional `request-id`) |

### Stream element attributes

| Attribute | Effect |
|---|---|
| `action` | Action name (built-in or custom) |
| `target` | ID of single target element |
| `targets` | CSS selector for multiple targets |
| `method` | `morph` — use morphing for replace/update instead of full swap |

### Delivery methods

1. **Inline `<turbo-stream>` in response body** — MIME type `text/vnd.turbo-stream.html`
2. **WebSocket** via Action Cable / `turbo_stream_from` helper
3. **SSE** via `<turbo-stream-source>` element with `src` pointing to SSE endpoint
4. **Client-side injection** — append `<turbo-stream>` elements to DOM programmatically

### Custom stream actions

```js
import { StreamActions } from "@hotwired/turbo"

StreamActions.myAction = function() {
  // `this` is the <turbo-stream> element
  const target = document.getElementById(this.getAttribute("target"));
  // ... perform action
}
```

---

## Stimulus

Modest JavaScript framework connecting HTML data attributes to controller classes.

### Controller lifecycle

| Method | Called when |
|---|---|
| `initialize()` | Once, when controller is first instantiated |
| `connect()` | Each time controller element enters the DOM |
| `disconnect()` | Each time controller element leaves the DOM |

### Descriptors

| Concept | HTML | Controller static | Access in controller |
|---|---|---|---|
| **Targets** | `data-<id>-target="name"` | `static targets = ["name"]` | `this.nameTarget`, `this.nameTargets`, `this.hasNameTarget` |
| **Values** | `data-<id>-name-value="x"` | `static values = { name: Type }` | `this.nameValue`, `this.hasNameValue`, `nameValueChanged()` callback |
| **Classes** | `data-<id>-name-class="cls"` | `static classes = ["name"]` | `this.nameClass`, `this.nameClasses`, `this.hasNameClass` |
| **Outlets** | `data-<id>-name-outlet=".sel"` | `static outlets = ["name"]` | `this.nameOutlet`, `this.nameOutlets`, `this.hasNameOutlet`, `nameOutletConnected()` / `nameOutletDisconnected()` callbacks |

### Actions

```html
<button data-action="click->controller#method">
```

| Syntax element | Meaning |
|---|---|
| `event->` | DOM event name (optional for default events) |
| `controller#` | Controller identifier |
| `method` | Method name on controller |
| `:prevent` | Calls `event.preventDefault()` |
| `:stop` | Calls `event.stopPropagation()` |
| `:self` | Only fires if `event.target` is the element itself |
| `@window` | Listens on `window` |
| `@document` | Listens on `document` |

### Action parameters

```html
<button data-action="click->cart#add"
        data-cart-id-param="123"
        data-cart-name-param="Widget">
```

Accessed as `event.params.id`, `event.params.name` in the action method. Types are auto-cast from data attributes.

### Default events by element

| Element | Default event |
|---|---|
| `<input>`, `<select>`, `<textarea>` | `input` (`change` for `<select>`) |
| `<form>` | `submit` |
| `<a>`, `<button>`, `<details>` | `click` |
| All others | `click` |
