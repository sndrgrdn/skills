---
name: hotwire
description: >-
  Build Hotwire applications with Turbo Drive, Turbo Frames, Turbo Streams, and Stimulus.
  Covers form submission and validation, inline editing, typeahead/autocomplete, modal forms,
  navigation and pagination, tabbed content, lazy loading, faceted search, cache lifecycle,
  scroll restoration, real-time WebSocket/SSE updates, custom Turbo Stream actions, cross-tab
  sync, media uploads/previews/playback, third-party media integrations (WaveSurfer, Swiper,
  Blurhash, Picture-in-Picture), loading states, progress bars, optimistic UI, view transitions,
  and Stimulus controller fundamentals (lifecycle, values, targets, outlets, actions, keyboard
  events). Use when building or debugging any Hotwire feature.
disable-model-invocation: true
---

# Hotwire

Implement Hotwire features with Turbo Drive, Turbo Frames, Turbo Streams, and Stimulus.

## Step 1: Route to Domain

Identify the primary domain, then jump to that section and load references selectively.

| Problem domain | Jump to |
|---|---|
| API reference, available attributes/events/actions | [API Surface](#api-surface) |
| Form submission, validation, inline editing, typeahead, modal forms, external form controls | [Forms & Validation](#forms--validation) |
| Pagination, tabs, lazy loading, faceted search, cache, scroll restoration, visit/render control | [Navigation & Content](#navigation--content) |
| WebSocket/SSE push updates, Turbo Streams, custom stream actions, cross-tab sync | [Real-Time & Streaming](#real-time--streaming) |
| Image/video/audio upload, previews, playback, progress, third-party media libs | [Media & Rich Content](#media--rich-content) |
| Loading states, progress bars, optimistic UI, view/page transitions, perceived performance | [UX Feedback](#ux-feedback) |
| Stimulus lifecycle, values, targets, outlets, actions, keyboard events, controller architecture | [Stimulus Fundamentals](#stimulus-fundamentals) |
| Debugging, common errors, broken behavior after navigation | [Troubleshooting](#troubleshooting) |
| Turbo 7→8 migration, morphing, broadcast_refreshes | [Turbo 8 Migration](#turbo-8-migration) |
| Turbo Native iOS/Android, Strada bridge components | [Turbo Native](#turbo-native) |
| Testing Turbo/Stimulus (system tests, unit tests, broadcasts) | [Testing](#testing) |
| importmap-rails, jsbundling-rails, Vite, asset pipeline setup | [Asset Pipeline](#asset-pipeline) |

When the task spans multiple domains, start with the primary domain and load additional references as needed.
For common implementation patterns, read `references/common-use-cases.md`.

---

## API Surface

Read `references/api-surface.md` for the full Hotwire API reference: Turbo Drive attributes/events/meta tags, Turbo Frame element and lifecycle, Turbo Stream actions and delivery methods, and Stimulus controller descriptors (targets, values, classes, outlets, actions).

Load this reference when the task requires looking up specific attribute names, event names, or API details.

---

## Forms & Validation

Implement form-centric workflows with Turbo Frames and Stimulus.

### Workflow

1. Identify form flow: create/edit, inline edit, typeahead, modal form, or external controls.
2. Wrap form scope in a Turbo Frame when validation errors must rerender in place.
3. Return `422` for validation failures and `303` for successful redirects.
4. Handle post-submit behavior with `turbo:submit-end` only when Turbo defaults are insufficient.
5. Preserve user context during rerenders (focus/caret/selection).

### Guardrails

- One source of truth for input state; no duplicate controls across frame and non-frame DOM.
- Use HTML `form` attribute for controls outside the target `<form>` hierarchy.
- Debounce/throttle keystroke-driven submits.

### References

| Topic | File |
|---|---|
| Inline editing | `references/forms/2024-02-27-turbo-frames-inline-edit.md` |
| Modal validation | `references/forms/2024-05-21-turbo-frames-modals-validation.md` |
| Typeahead search | `references/forms/2023-11-07-turbo-frames-typeahead-search.md` |
| Typeahead validation + focus | `references/forms/2025-10-20-turbo-frames-typeahead-validation.md` |
| External form controls | `references/forms/2026-02-03-turbo-frames-external-form.md` |
| Stimulus action parameters | `references/forms/2024-01-16-stimulus-action-parameters.md` |

---

## Navigation & Content

Implement navigation and content-discovery behavior with Turbo Drive and Turbo Frames.

### Workflow

1. Classify navigation mode: tabs, pagination, lazy frame, faceted search, or custom render/cache.
2. Decide URL and history ownership first (`data-turbo-action`, frame `src`, query params).
3. Use frame lifecycle and visit events to update active state and scroll restoration.
4. Clean transient UI state before Turbo cache snapshots.
5. Validate across forward/back navigation and refresh paths.

### Guardrails

- Update active/tab state on load/render events, not click intent.
- Keep URL state canonical for filters and pagination.
- No transient UI artifacts in cache snapshots.

### References

| Topic | File |
|---|---|
| Tabbed navigation | `references/navigation/2023-06-20-turbo-frames-tabbed-navigation.md` |
| Pagination + history | `references/navigation/2023-07-04-turbo-frames-pagination.md` |
| Lazy frame lifecycle | `references/navigation/2023-09-26-turbo-frames-lazy-loading-lifecycle.md` |
| Scroll restoration | `references/navigation/2023-09-12-turbo-frames-scroll-position-restoration.md` |
| Cache lifecycle | `references/navigation/2023-05-23-turbo-drive-cache-lifecycle.md` |
| Custom render interception | `references/navigation/2023-05-09-turbo-drive-custom-rendering.md` |
| Conditional instant click | `references/navigation/2024-02-13-turbo-drive-conditional-instant-click.md` |
| Faceted search | `references/navigation/2024-12-10-stimulus-turbo-frames-faceted-search.md` |
| Markdown preview | `references/navigation/2024-10-08-turbo-frames-markdown-preview.md` |

---

## Real-Time & Streaming

Implement push-driven behavior with Turbo Streams and Stimulus.

### Workflow

1. Identify transport: WebSocket, SSE, inline stream tags, or server response streams.
2. Prefer default Turbo Stream actions; add custom actions only when defaults are insufficient.
3. Keep stream actions small and deterministic; no arbitrary scripts in payloads.
4. Separate stream orchestration from domain UI concerns.
5. Verify ordering, idempotency, and multi-tab behavior.

### Guardrails

- Prefer `append/prepend/replace/update/remove/before/after/refresh` before custom actions.
- Explicit cross-tab sync (BroadcastChannel/localStorage), scoped to same-device.
- Use view transitions only where animation clarifies state changes.

### References

| Topic | File |
|---|---|
| Inline stream tags | `references/realtime/2023-08-01-turbo-streams-inline-stream-tags.md` |
| Custom stream actions | `references/realtime/2023-08-15-turbo-streams-custom-stream-actions.md` |
| Playlist orchestration | `references/realtime/2023-10-10-turbo-streams-custom-stream-actions-video-playlist-management.md` |
| LocalStorage stream state | `references/realtime/2024-01-30-turbo-streams-custom-stream-actions-localstorage.md` |
| List animations + View Transitions | `references/realtime/2025-06-10-turbo-streams-list-animation-view-transitions.md` |
| Real-time combobox | `references/realtime/2024-03-12-hotwire-combobox-with-real-time-data.md` |
| Inter-tab communication | `references/realtime/2023-11-21-stimulus-inter-tab-communication.md` |

---

## Media & Rich Content

Implement media-centric features with Stimulus and Turbo Frames.

### Workflow

1. Identify media mode: upload/preview, playback controls, progress persistence, or library integration.
2. Keep media state in Stimulus values; bridge third-party APIs through value callbacks and targets.
3. Use browser-native APIs first (`URL.createObjectURL`, Picture-in-Picture, IntersectionObserver, MediaSession).
4. Clean up all resources in `disconnect()` (observers, blob URLs, player instances, timers).
5. Persist only intentional client state and reconcile on load.

### Guardrails

- Revoke blob URLs after preview rendering.
- Feature-detect browser APIs (PiP/Web Share/MediaSession).
- Keep frame updates incremental for time-based UI.

### References

| Topic | File |
|---|---|
| Upload previews (blob URLs) | `references/media/2024-09-17-stimulus-image-upload-previews.md` |
| Progressive images + Blurhash | `references/media/2024-04-23-stimulus-progressive-image-loading-blurhash.md` |
| Picture-in-Picture | `references/media/2024-06-04-stimulus-picture-in-picture.md` |
| Video progress persistence | `references/media/2024-10-29-stimulus-video-progress-tracker.md` |
| WaveSurfer marker add | `references/media/2024-07-02-stimulus-wavesurfer-add-markers.md` |
| WaveSurfer marker remove | `references/media/2024-07-30-stimulus-wavesurfer-remove-markers.md` |
| Time-synced lyrics | `references/media/2024-04-09-turbo-frames-scrolling-lyrics.md` |
| Swiper autoplay | `references/media/2025-01-14-turbo-frames-swiper-autoplay.md` |

---

## UX Feedback

Implement cross-cutting feedback and perceived-performance patterns.

### Workflow

1. Identify feedback need: loading, submit activity, progress, optimistic updates, or transitions.
2. Prefer built-in Turbo semantics first (`busy`, progress bar hooks, submit/render lifecycle events).
3. Add optimistic updates only with a clear reconciliation strategy.
4. Keep transition logic bounded to explicit lifecycle events and cache/preview-safe paths.
5. Verify on slow network, back/forward cache restores, and submission failures.

### Guardrails

- No fixed timeouts as proxy for network/render completion.
- Gate animations for previews and cache restores.
- Symmetric submit locking between start and end events.

### References

| Topic | File |
|---|---|
| Progress bar | `references/ux-feedback/2023-07-18-turbo-drive-progress-bar.md` |
| Form activity indicators | `references/ux-feedback/2023-06-06-turbo-drive-form-activity-indicators.md` |
| Render interception | `references/ux-feedback/2023-04-25-turbo-drive-render-interception.md` |
| View transitions (Swiper) | `references/ux-feedback/2024-11-19-turbo-drive-swiper-view-transitions.md` |
| Frame busy spinner | `references/ux-feedback/2026-01-20-turbo-frames-loading-spinner.md` |
| Optimistic UI + morphs | `references/ux-feedback/2024-03-26-optimistic-ui-with-turbo-8-morphs.md` |
| ULID optimistic identity | `references/ux-feedback/2024-08-13-turbo-drive-ulid.md` |

---

## Stimulus Fundamentals

Implement robust Stimulus controllers with clear lifecycle and state boundaries.

### Workflow

1. Define controller contract: targets, values, outlets, actions, and lifecycle expectations.
2. Keep state transitions in value callbacks for reactive updates.
3. Guard callbacks that can run before `connect()` completes.
4. Use `connect()/disconnect()` for setup and teardown symmetry.
5. Isolate DOM event handling from business rules; keep controllers composable.

### Guardrails

- Prefer declarative action parameters over manual dataset parsing.
- Use outlets for controller-to-controller communication.
- Keep target callbacks idempotent; handle repeated connect/disconnect cycles.
- Feature-detect browser APIs before exposing UI affordances.

### References

| Topic | File |
|---|---|
| Value changed callbacks | `references/stimulus/2023-08-29-stimulus-value-changed-callbacks.md` |
| Keyboard events + hotkeys | `references/stimulus/2023-10-24-stimulus-keyboardevent-101.md` |
| MutationObserver sorting | `references/stimulus/2023-12-05-stimulus-auto-sorting.md` |
| Outlets API | `references/stimulus/2023-12-19-stimulus-outlets-api.md` |
| Target callbacks | `references/stimulus/2024-05-07-stimulus-target-callbacks.md` |
| Web Share API | `references/stimulus/2025-11-25-stimulus-web-share-api.md` |
| Core Web Vitals + lazy loading | `references/stimulus/2024-06-18-fundamentals-core-web-vitals.md` |

---

## Troubleshooting

Read `references/troubleshooting-workarounds.md` when debugging broken behavior. Covers 12 common issues:

| Issue | Quick check |
|---|---|
| Form errors don't render in place | Return `422`, not `200` or `302` |
| Event listeners lost after navigation | Use Stimulus or `turbo:load`, not `DOMContentLoaded` |
| Frame content disappears | Response must contain matching `<turbo-frame id>` |
| Stale content on back/forward | Clean up in `turbo:before-cache` |
| Controller connects multiple times | Symmetric `connect()`/`disconnect()` teardown |
| Stream actions silently fail | Check MIME type `text/vnd.turbo-stream.html` and target ID |
| Double form submissions | Use `requestSubmit()`, not `submit()` |
| Third-party scripts break | Wrap in Stimulus controller with `disconnect()` teardown |

---

## Turbo 8 Migration

Read `references/turbo8-migration.md` for Turbo 7 → 8 migration. Covers morph-based page refreshes, new meta tags (`turbo-refresh-method`, `turbo-refresh-scroll`), the `refresh` stream action, `broadcasts_refreshes` vs `broadcast_replace_to`, morph exclusion (`data-turbo-permanent`, `turbo:before-morph-element`), breaking changes, and gotchas.

---

## Turbo Native

Read `references/turbo-native.md` for iOS and Android integration. Covers architecture (shared WebView, visit types), `Navigator` / `HotwireActivity` setup, path configuration JSON (routing URLs to native vs web screens), Bridge/Strada components (web ↔ native communication), server-side detection, and common patterns (auth, tabs, external links).

---

## Testing

Read `references/testing.md` for testing Hotwire features. Covers:

| Layer | Key tools |
|---|---|
| Controller/integration tests | `assert_turbo_stream`, `assert_turbo_frame`, `as: :turbo_stream` |
| Broadcast tests | `assert_turbo_stream_broadcasts`, `capture_turbo_stream_broadcasts` |
| System tests (Capybara) | `connect_turbo_cable_stream_sources`, `wait_for_turbo` helper |
| Stimulus unit tests | Jest/Vitest + jsdom, `Application.start()`/`.stop()` lifecycle |

---

## Asset Pipeline

Read `references/asset-pipeline.md` for JavaScript delivery setup. Covers importmap-rails (no Node, browser ESM), jsbundling-rails (esbuild/rollup/webpack), vite_rails (HMR + code splitting), Stimulus controller loading differences across approaches, and common issues.
