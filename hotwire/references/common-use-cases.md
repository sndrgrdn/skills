# Common Use Cases

Concrete patterns for the most frequent Hotwire implementation tasks. Each entry includes the primary approach and key decisions.

## Contents
- [1. CRUD form with server-side validation](#1-crud-form-with-server-side-validation)
- [2. Inline editing](#2-inline-editing)
- [3. Search with live results](#3-search-with-live-results)
- [4. Tabbed content with URL state](#4-tabbed-content-with-url-state)
- [5. Infinite scroll / paginated list](#5-infinite-scroll--paginated-list)
- [6. Modal form with validation](#6-modal-form-with-validation)
- [7. Real-time updates via WebSocket](#7-real-time-updates-via-websocket)
- [8. Lazy-loaded content sections](#8-lazy-loaded-content-sections)
- [9. Multi-step wizard / form flow](#9-multi-step-wizard--form-flow)
- [10. Drag-and-drop reordering](#10-drag-and-drop-reordering)

---

## 1. CRUD form with server-side validation

**Goal:** Submit a form, show validation errors in place, redirect on success.

**Approach:**
- Wrap the form in a `<turbo-frame>`.
- Return `422 Unprocessable Entity` for validation failures — Turbo re-renders the frame with errors.
- Return `303 See Other` redirect on success — Turbo follows the redirect as a full visit.
- Use `turbo_frame_request?` in Rails to decide whether to render a full page or frame-scoped partial.

**Key decisions:**
- Frame ID must match between the form page and the error re-render.
- Never return `200` for a failed form — Turbo treats `2xx` as success and follows redirects.

## 2. Inline editing

**Goal:** Click text to edit it in place, save on blur or Enter.

**Approach:**
- Display view: `<turbo-frame id="item-N">` with a link to the edit action.
- Edit view: same frame ID wrapping an `<input>` with `autofocus`.
- Listen for `turbo:frame-render` to attach `focusout` → `requestSubmit()`.
- Server returns the display view frame on successful PATCH.

**Key decisions:**
- Use `turbo:frame-render` (not `DOMContentLoaded`) for event binding — the input only exists after frame swap.
- Call `input.select()` on render for easy text replacement.
- See `references/forms/2024-02-27-turbo-frames-inline-edit.md`.

## 3. Search with live results

**Goal:** Filter a list as the user types, with debounced server requests.

**Approach:**
- Stimulus controller on the search input with a `search` action on `input` event.
- Debounce input (200–300ms) before submitting the form targeting a results frame.
- Results frame contains the filtered list; server renders matching items.
- Optionally update the URL query string with `data-turbo-action="replace"`.

**Key decisions:**
- Debounce in Stimulus (`setTimeout` + clear pattern), not a global event listener.
- Preserve focus and caret position after frame updates.
- See `references/forms/2023-11-07-turbo-frames-typeahead-search.md`.

## 4. Tabbed content with URL state

**Goal:** Tab navigation that updates content in place and preserves browser history.

**Approach:**
- Each tab is a link targeting a content frame, with `data-turbo-action="advance"` for history.
- Active tab state is updated on `turbo:before-frame-render` or `turbo:frame-load`, not on click.
- Content frame loads the tab's content from the server.

**Key decisions:**
- Update active class on frame render events, not click — back/forward navigation must also update tabs.
- Clean active state in `turbo:before-cache` to avoid stale tab highlighting in cached pages.
- See `references/navigation/2023-06-20-turbo-frames-tabbed-navigation.md`.

## 5. Infinite scroll / paginated list

**Goal:** Load more items as the user scrolls or clicks "Load More".

**Approach:**
- Render a `<turbo-frame id="page-N" src="/items?page=N+1" loading="lazy">` at the bottom of each page of results.
- The server response includes the next page of items plus another lazy frame for the subsequent page.
- `loading="lazy"` defers the fetch until the frame scrolls into view.

**Key decisions:**
- Each page frame needs a unique ID (`page-1`, `page-2`, etc.).
- The last page omits the lazy frame to stop loading.
- Add `data-turbo-action="advance"` if the URL should reflect pagination state.
- See `references/navigation/2023-07-04-turbo-frames-pagination.md`.

## 6. Modal form with validation

**Goal:** Open a form in a modal, validate server-side, close on success.

**Approach:**
- Modal contains a `<turbo-frame>` that loads the form via `src` or link navigation.
- Validation errors re-render inside the frame (return `422`).
- On success, return `303` redirect — use `turbo:submit-end` to close the modal and optionally trigger a page refresh.
- Alternatively, return a Turbo Stream that updates the list and closes the modal.

**Key decisions:**
- Modal open/close is Stimulus-managed; form lifecycle is Turbo-managed.
- Handle the case where `turbo:frame-missing` fires if the redirect target doesn't contain the frame.
- See `references/forms/2024-05-21-turbo-frames-modals-validation.md`.

## 7. Real-time updates via WebSocket

**Goal:** Push live updates to all connected clients (chat, notifications, dashboards).

**Approach:**
- Use `turbo_stream_from` helper (Rails) to subscribe to a channel.
- Server broadcasts Turbo Stream actions (`append`, `replace`, `update`) via Action Cable.
- Client-side: `<turbo-stream-source>` element auto-connects and processes incoming streams.
- For Turbo 8: broadcast `refresh` action and use morphing for full-page reconciliation.

**Key decisions:**
- Prefer `morph` method on replace/update for minimal DOM disruption.
- Use `broadcast_refresh_to` for complex multi-element updates instead of multiple targeted streams.
- See `references/realtime/` for specific patterns.

## 8. Lazy-loaded content sections

**Goal:** Defer loading of below-the-fold or secondary content.

**Approach:**
- `<turbo-frame id="section" src="/section" loading="lazy">` with a placeholder/spinner inside.
- Server renders the full section content wrapped in a matching frame.
- Content loads when the frame enters the viewport.

**Key decisions:**
- Include a visible loading indicator inside the frame for perceived performance.
- Set appropriate cache headers on the lazy endpoint.
- See `references/navigation/2023-09-26-turbo-frames-lazy-loading-lifecycle.md`.

## 9. Multi-step wizard / form flow

**Goal:** Guide the user through sequential form steps without full page reloads.

**Approach:**
- Each step is rendered in a `<turbo-frame>`.
- "Next" submits the current step; server validates and returns the next step in the same frame.
- "Back" navigates to the previous step URL within the frame.
- Use `data-turbo-action="advance"` so each step gets a history entry.

**Key decisions:**
- Store intermediate state server-side (session or draft record), not in hidden fields across steps.
- Return `422` for step validation failures, `303` redirect on final completion.
- Frame ID stays the same across all steps for seamless swapping.

## 10. Drag-and-drop reordering

**Goal:** Reorder a list via drag-and-drop, persist order to server.

**Approach:**
- Stimulus controller wrapping a sortable library (e.g., SortableJS).
- On drop, extract new order from DOM positions and send PATCH request.
- Server updates positions and returns Turbo Stream or morph refresh.
- Optionally apply optimistic reorder in DOM before server confirms.

**Key decisions:**
- Use `requestSubmit()` or `fetch` with `X-CSRF-Token` header for the PATCH.
- Add `data-turbo-permanent` to sortable items if they must persist across navigations.
- Reconcile with server state on failure (revert DOM order or refresh).
