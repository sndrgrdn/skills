# Catalog of Slop (Language-Agnostic)

## Contents

- [Defensive chaff](#defensive-chaff)
- [Dead insurance](#dead-insurance)
- [Paranoid rescue / catch](#paranoid-rescue--catch)
- [Identity and redundant op](#identity-and-redundant-op)
- [Pedantic normalization](#pedantic-normalization)
- [Premature factoring](#premature-factoring)
- [YAGNI abstraction](#yagni-abstraction)
- [Over-parameterized signature](#over-parameterized-signature)
- [Comment and doc slop](#comment-and-doc-slop)
- [Log and debug noise](#log-and-debug-noise)
- [Test slop](#test-slop)
- [Placeholder and stub](#placeholder-and-stub)
- [Dead code after return / throw](#dead-code-after-return--throw)
- [Type escape hatch](#type-escape-hatch)

Remember: every flag runs through **neighbor check** before grug propose drop. local idiom = keep. novel = flag.

## Defensive chaff

grug add defense code don't need.

- `x || false` — `x` already boolean
- `x || []` — `x` already array
- `x.to_s` / `str(x)` — downstream accept both
- `Array(x)` / `[x].flat()` — `x` already array
- nil/None-guard on value caller just assert non-nil
- `thing&.method(x) || false` — belt AND suspenders
- double-check: `if x is not None and x:` when `if x:` covers it

## Dead insurance

grug add protection nobody use.

- `.freeze` / `Object.freeze` on class-level state never mutated at runtime
- `.flatten` on splat (`*args` / `...rest` already flat)
- `.uniq` / `new Set(...)` on source that can't produce duplicate
- `.compact` / `.filter(Boolean)` on array built from non-nil
- `defined?(@var)` / `hasattr(self, "x")` guard when always set
- `@var ||= ...` / `self.x = self.x or ...` when method called exactly once

## Paranoid rescue / catch

grug catch error that can't happen.

- `rescue => e; raise e` / `catch(e) { throw e }` — identity no-op
- `rescue => e; logger.error(e); raise` — framework already log re-raise
- `rescue StandardError` / `except Exception` when block can't raise
- **empty rescue** — `rescue => e; end` / `catch(e) {}` / `except: pass` — swallow real bug, very bad
- `begin/rescue` / `try/except` around one line that can't fail (`hash[:key]`, `dict["k"]`)

## Identity and redundant op

grug write code do nothing.

- `.map { |x| x }` / `.map(x => x)` — identity
- `.reject(&:nil?)` followed `.compact` — redundant
- `.dup.dup`, `.to_a.to_a`, `[...arr]` of `[...arr]`
- `x.nil? ? nil : x` — return `x` unchanged
- `x.present? && x.present?` — same check twice
- `return nil` / `return undefined` at end of method already returning that
- `if x then x else y end` — use `x || y`

## Pedantic normalization

grug change type don't need change.

- `.to_sym` on literal string (already interned)
- `.deep_dup` when `.dup` enough
- `.with_indifferent_access` when one code path, one key style
- `String(x)` when `x` is already `string`
- `Number(x)` on numeric literal

## Premature factoring

grug make structure too early. grugbrain.dev §Factoring:

> early on in project everything very abstract and like water ... good cut points emerge from code base

- private method, one caller, 1-2 line body
- constant for value used once
- wrapper that only renames (`def fetch_user; find_user; end`)
- namespace module with one class inside
- base class with one implementor
- generic parameter with one type

## YAGNI abstraction

grug future-proof for future not come.

- config option / kwarg with one value ever passed
- default never overridden
- hook / callback with no subscriber
- strategy pattern with one strategy
- feature flag always on / always off in same commit
- callable that accept block nobody pass

## Over-parameterized signature

- optional kwarg never passed from any caller
- `**opts` / `...rest` when one key ever read
- positional + keyword mix used by nobody

## Comment and doc slop

grug or AI write word nobody read.

- comment restate code (`# increment counter` above `counter += 1`)
- YARD / JSDoc `@param`/`@return` on 1-line method where signature obvious
- long docstring for self-evident method
- commented-out code "for reference" — git remember
- `TODO:` no issue link, no owner — never happen
- markdown fence inside comment the tool not render
- **buzzword comment** — "robust", "comprehensive", "elegant", "powerful", "seamless", "gracefully handle". AI tell. human rarely write in comment. flag hard.
- **doc-to-code ratio red flag** — 20 line method body, 15 line comment. heavy slop. consolidate or cut.

## Log and debug noise

- `Rails.logger.debug "Entered method X"` — obvious trace. grugbrain.dev §Logging: log useful branch, not obvious enter
- `puts` / `p` / `pp` / `binding.pry` leftover from debug session
- `console.log` wasn't there before
- `print(...)` / `pprint(...)` leftover
- structured log on non-diagnostic path
- telemetry / metric emission with no consumer

## Test slop

if diff include spec / test file.

- `it "works"` / `it "should work"` — empty semantic assertion
- mock object test didn't need isolate
- setup create record that assertion never touch
- `expect(true).to be_truthy` / `assert True`
- multiple test asserting same branch

## Placeholder and stub

grug or AI leave half-done work.

- `def foo; raise NotImplementedError; end` with no caller plan
- `// TODO: add logic here` inside empty body
- method body only `pass` / `...` / `return nil` with no task
- if no plan to fill, cut or delete until plan exist

## Dead code after return / throw

- line after `return`, `throw`, `raise` that never run
- unreachable `else` after exhaustive `if`
- code past early-return that should've been noticed

## Type escape hatch

grug or AI silence type system warn, no fix.

- TypeScript: `as any`, `@ts-ignore`, `@ts-expect-error` with no reason comment
- Ruby: `.send(:private_method)` for access shortcut, `.instance_variable_get`
- Python: `# type: ignore` with no reason, `cast(Any, x)`

grugbrain.dev §Type Systems: type system warn for reason. silence without fix = slop. silence WITH reason comment = maybe ok.
