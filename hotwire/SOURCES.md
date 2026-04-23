# Sources

Provenance and coverage status for the hotwire skill.

## Source inventory

| Source | Trust tier | Confidence | Usage constraints |
|---|---|---|---|
| Hotwire official docs (hotwired.dev, native.hotwired.dev) | Primary / Official | High | Public documentation, no license constraints |
| Turbo GitHub repository (hotwired/turbo) | Primary / Official | High | MIT licensed source code and changelogs |
| Stimulus GitHub repository (hotwired/stimulus) | Primary / Official | High | MIT licensed source code and changelogs |
| Turbo Rails GitHub repository (hotwired/turbo-rails) | Primary / Official | High | MIT licensed, Rails integration layer + test helpers |
| Hotwire Native iOS (hotwired/hotwire-native-ios) | Primary / Official | High | MIT licensed, iOS integration |
| Hotwire Native Android (hotwired/hotwire-native-android) | Primary / Official | High | MIT licensed, Android integration |
| Strada Web (hotwired/strada-web) | Primary / Official | High | MIT licensed, bridge components |
| importmap-rails / jsbundling-rails / vite_rails repos | Primary / Official | High | MIT licensed, asset pipeline integrations |
| TheHotwireClub/hotwire_club-skills | Primary / Curated | High | Source corpus for domain reference articles |
| SupeRails tutorials and screencasts | Secondary / Community | Medium–High | Educational content, verified against official docs |
| GoRails tutorials | Secondary / Community | Medium–High | Educational content, community-validated patterns |
| Hotwire community discussions (GitHub, Discord) | Secondary / Community | Medium | Community-sourced, cross-checked against source |

## Coverage matrix

| Dimension | Status |
|---|---|
| API surface | Covered — `references/api-surface.md` covers Turbo Drive, Frames, Streams, and Stimulus descriptors |
| Config/runtime options | Covered — meta tags, data attributes, and frame attributes documented in API surface |
| Common use cases | Covered — `references/common-use-cases.md` with 10 concrete patterns |
| Known issues/workarounds | Covered — `references/troubleshooting-workarounds.md` with 12 issue/fix entries |
| Version/migration variance | Covered — `references/turbo8-migration.md` covers morph refreshes, meta tags, breaking changes, broadcasts_refreshes vs broadcast_replace_to, gotchas |
| Forms & validation patterns | Covered — 6 reference files in `references/forms/` |
| Navigation & content patterns | Covered — 9 reference files in `references/navigation/` |
| Real-time & streaming patterns | Covered — 7 reference files in `references/realtime/` |
| Media & rich content patterns | Covered — 8 reference files in `references/media/` |
| UX feedback patterns | Covered — 7 reference files in `references/ux-feedback/` |
| Stimulus fundamentals | Covered — 7 reference files in `references/stimulus/` |

| Turbo Native (iOS/Android) | Covered — `references/turbo-native.md` covers architecture, iOS/Android setup, path config, Strada bridge components, server-side detection |
| Testing patterns | Covered — `references/testing.md` covers controller/integration tests, broadcast tests, Capybara system tests, Stimulus unit tests |
| Asset pipeline integration | Covered — `references/asset-pipeline.md` covers importmap-rails, jsbundling-rails, vite_rails, Stimulus loading, Turbo installation |
| Advanced custom stream actions | Covered — existing references include multi-action orchestration (video playlist), localStorage side-effects, View Transitions API integration |

## Open gaps

- Turbo Native Strada bridge: more complex bridge component examples beyond form submit (camera, geolocation, biometrics)
- Testing Turbo Native path configuration routing in isolation
- Performance profiling and optimization patterns for large Hotwire applications
- Turbo 8 morphing interaction with specific third-party libraries (Trix, ActionText, Select2)
