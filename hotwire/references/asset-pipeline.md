# Asset Pipeline & Hotwire

## Contents
- [Decision guide](#decision-guide)
- [importmap-rails](#importmap-rails)
- [jsbundling-rails (esbuild)](#jsbundling-rails-esbuild)
- [vite_rails](#vite_rails)
- [Stimulus controller loading](#stimulus-controller-loading)
- [Turbo installation](#turbo-installation)
- [Common issues](#common-issues)

---

## Decision guide

| Criterion | importmap | jsbundling (esbuild) | vite_rails |
|---|---|---|---|
| Node required | ❌ | ✅ | ✅ |
| TypeScript | ❌ | ✅ (add plugin) | ✅ native |
| Tree-shaking | ❌ | ✅ | ✅ |
| HMR | ❌ (full reload) | ❌ (full reload) | ✅ |
| npm packages | CDN/vendor only | full npm | full npm |
| CJS packages | ❌ ESM only | ✅ | ✅ |
| Code splitting | ❌ | ⚠️ limited | ✅ |
| Build step | ❌ | ✅ | ✅ (prod only) |
| Rails default | ✅ (7+) | ❌ | ❌ |

**Use importmap when:** Standard server-rendered Rails app, few JS dependencies, no TypeScript, prefer simplicity.

**Use jsbundling (esbuild) when:** Need npm ecosystem, TypeScript, complex build transforms.

**Use vite_rails when:** Heavy frontend work, React/Vue islands, need true HMR, TypeScript-heavy.

---

## importmap-rails

No Node, no bundling. Browser-native import maps resolve bare specifiers to URLs. HTTP/2 multiplexing handles many small files.

### Setup

```bash
rails new myapp                      # importmap is the default
# or add to existing:
./bin/bundle add importmap-rails
./bin/rails importmap:install
```

### Configuration: `config/importmap.rb`

```ruby
pin "application"                                      # app/javascript/application.js
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# External CDN
pin "react", to: "https://ga.jspm.io/npm:react@19.1.0/index.js"

# Lazy load (not preloaded)
pin "md5", preload: false
```

### Adding packages

```bash
./bin/importmap pin lodash-es         # download + vendor from jspm.org
./bin/importmap pin react --from unpkg
./bin/importmap unpin react
./bin/importmap outdated              # check for updates
./bin/importmap audit                 # security audit
```

Vendored files go to `vendor/javascript/` (committed to source control).

### Layout

```erb
<%= javascript_importmap_tags %>
```

### Limitations

- No TypeScript compilation, no tree-shaking, no CSS processing
- ESM-only packages (CJS won't work)
- No code splitting beyond lazy `preload: false`
- Safari ≤ 15 needs `es-module-shims` polyfill

---

## jsbundling-rails (esbuild)

Node-based bundler compiles `app/javascript/` → `app/assets/builds/` → served by Propshaft/Sprockets.

### Setup

```bash
rails new myapp -j esbuild
# or add to existing:
./bin/bundle add jsbundling-rails
./bin/rails javascript:install:esbuild
```

### Build config (package.json)

```json
{
  "scripts": {
    "build": "esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets"
  }
}
```

### Development

```bash
./bin/dev                  # starts Rails + yarn build --watch via Procfile.dev
```

### Layout

```erb
<%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>
```

### Build integration

`javascript:build` hooks into `assets:precompile` and `test:prepare` automatically.

---

## vite_rails

Vite dev server with HMR in development; tree-shaking + code splitting in production.

### Setup

```bash
# Gemfile: gem 'vite_rails'
bundle install && bundle exec vite install
```

### Configuration

`config/vite.json`:
```json
{
  "all": { "sourceCodeDir": "app/frontend" },
  "development": { "autoBuild": true, "port": 3036 }
}
```

`vite.config.ts`:
```typescript
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
export default defineConfig({ plugins: [RubyPlugin()] })
```

### Layout

```erb
<%= vite_client_tag %>                    <%# HMR client (dev only) %>
<%= vite_javascript_tag 'application' %>
<%= vite_stylesheet_tag 'application' %>
```

### Development

```bash
bin/vite dev     # Vite dev server
bin/rails s      # Rails (proxy handles /vite-dev/ requests)
```

---

## Stimulus controller loading

### importmap: automatic eager/lazy loading

```javascript
// app/javascript/controllers/index.js
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
```

`eagerLoadControllersFrom` reads the inline `<script type="importmap">` JSON and registers every key matching `controllers/*_controller`. Switch to `lazyLoadControllersFrom` for MutationObserver-based lazy loading.

### Bundler: static imports via manifest

```javascript
// app/javascript/controllers/index.js (auto-generated)
import { application } from "./application"
import HelloController from "./hello_controller"
application.register("hello", HelloController)
```

Re-run after adding controllers:
```bash
./bin/rails stimulus:manifest:update
# or: ./bin/rails generate stimulus hello  (auto-updates manifest)
```

### Vite: import.meta.glob

```javascript
const controllers = import.meta.glob('./**/*_controller.js', { eager: true })
for (const path in controllers) {
  const name = path.replace('./controllers/', '').replace('_controller.js', '').replace(/\//g, '--')
  application.register(name, controllers[path].default)
}
```

---

## Turbo installation

### importmap

```ruby
# config/importmap.rb (added by turbo:install)
pin "@hotwired/turbo-rails", to: "turbo.min.js"
```

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
```

The gem ships `turbo.min.js` as a vendored asset.

### Bundler

```bash
yarn add @hotwired/turbo-rails
```

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"  // auto-starts Turbo, sets window.Turbo
```

If using webpack and want to avoid loading the gem's vendored JS:
```ruby
config.after_initialize do
  config.assets.precompile -= Turbo::Engine::PRECOMPILE_ASSETS
end
```

---

## Common issues

### importmap: "Failed to resolve module specifier"

Module imported but not pinned. Add to `config/importmap.rb`:
```ruby
pin "some-package"
```

### importmap: Package uses CommonJS

Find the ESM build (`lodash-es` instead of `lodash`) or pin from a CDN that provides ESM:
```bash
./bin/importmap pin lodash-es
```

### importmap: Propshaft 404 on local modules

Propshaft won't serve `app/javascript/` files unless pinned:
```ruby
pin_all_from "app/javascript/src", under: "src"
```

### jsbundling: `application.css not in asset pipeline`

Ensure `app/assets/builds/.keep` exists and is committed:
```bash
mkdir -p app/assets/builds && touch app/assets/builds/.keep
```

### jsbundling: Stimulus controller not found after generation

Re-run manifest updater:
```bash
./bin/rails stimulus:manifest:update
```

### jsbundling: esbuild overwrites cssbundling CSS

Both output `application.css` to `app/assets/builds/`. Rename one output in `package.json`.

### importmap: Stimulus controller not loading

1. File must be named `*_controller.js`
2. Must be in the pinned directory
3. `eagerLoadControllersFrom("controllers", application)` must be called
4. Debug: `JSON.parse(document.querySelector('script[type=importmap]').text).imports`

### CSS without Node (importmap apps)

Use standalone gems instead of cssbundling-rails:
- `tailwindcss-rails` — standalone Tailwind binary, no Node
- `dartsass-rails` — standalone Dart Sass binary, no Node
