# Catalog of Slop — JavaScript / TypeScript

Load when diff touch `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `package.json`.

## JavaScript

- `async` function that never `await`
- `try { ... } catch (e) { console.log(e) }` — log and swallow
- single-export barrel `index.js` re-exporting one thing
- `module.exports = { foo }` when `module.exports.foo = foo` is file's pattern (or vice versa) — novel inconsistency
- `Object.assign({}, obj)` when `{...obj}` is the file idiom
- `arr.filter(Boolean).filter(x => x)` — redundant
- `new Promise((res, rej) => { ... res(x) })` wrapping value already a promise
- `.then(x => x)` identity then
- `await Promise.resolve(x)` on non-promise

## TypeScript

- `as any` / `as unknown as T` with no reason comment
- `@ts-ignore` / `@ts-expect-error` with no reason comment
- `: void` return annotation on arrow that infer fine
- `interface Foo { ... }` used once, never extended — prefer inline or `type`
- enum with one member
- generic parameter `<T>` used exactly once inside signature, not returned

## React

- `useMemo` / `useCallback` wrap literal or value with no dependency pressure
- `useEffect` with empty deps calling parent-safe init that constructor-equivalent would do
- `useState` never setter-called after mount — should be constant or prop
- `<Fragment>` wrapping single child
- `React.memo` on component that always re-render from parent anyway
- prop drill one level when `children` or direct pass work
- `useRef` holding value never `.current`-read

## Node / backend

- `process.env.X || "default"` where `"default"` is the only value ever set in repo
- custom `EventEmitter` subclass with no extra method
- middleware that only calls `next()`
- `Router()` split into own file with one route

## Test (Jest / Vitest)

- `it("works", () => { expect(true).toBe(true) })`
- `describe` that contains one `it` with same text
- `beforeEach` setup nobody's assertion touch
- manual mock when `vi.mock` / `jest.mock` auto-mock works for file's pattern

## Neighbor check examples (JS/TS)

- repo uses `useCallback` on every handler → new `useCallback` is **local idiom**, keep
- repo never uses `as any` → new `as any` is **novel**, flag hard
- file already has 3 `console.log` (intentional tracing?) — ambiguous, ask
