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
- [Unused imports / requires](#unused-imports--requires)
- [Semantic duplication](#semantic-duplication)
- [Test slop](#test-slop)
- [Placeholder and stub](#placeholder-and-stub)
- [Dead code after return / throw](#dead-code-after-return--throw)
- [Type escape hatch](#type-escape-hatch)

Every flag runs through **neighbor check** before proposing drop. local idiom = keep. novel = flag.

## Defensive chaff

Defensive code that serves no purpose.

- `x || false` — `x` already boolean
- `x || []` — `x` already array
- `x.to_s` / `str(x)` — downstream accept both
- `Array(x)` / `[x].flat()` — `x` already array
- nil/None-guard on value caller just assert non-nil
- `thing&.method(x) || false` — belt AND suspenders
- double-check: `if x is not None and x:` when `if x:` covers it

## Dead insurance

Protection against conditions that cannot occur.

- `.freeze` / `Object.freeze` on class-level state never mutated at runtime
- `.flatten` on splat (`*args` / `...rest` already flat)
- `.uniq` / `new Set(...)` on source that can't produce duplicate
- `.compact` / `.filter(Boolean)` on array built from non-nil
- `defined?(@var)` / `hasattr(self, "x")` guard when always set
- `@var ||= ...` / `self.x = self.x or ...` when method called exactly once

## Paranoid rescue / catch

Error handling for code paths that cannot raise.

- `rescue => e; raise e` / `catch(e) { throw e }` — identity no-op
- `rescue => e; logger.error(e); raise` — framework already log re-raise
- `rescue StandardError` / `except Exception` when block can't raise
- **empty rescue** — `rescue => e; end` / `catch(e) {}` / `except: pass` — swallow real bug, very bad
- `begin/rescue` / `try/except` around one line that can't fail (`hash[:key]`, `dict["k"]`)

## Identity and redundant op

Operations that produce no effect.

- `.map { |x| x }` / `.map(x => x)` — identity
- `.reject(&:nil?)` followed `.compact` — redundant
- `.dup.dup`, `.to_a.to_a`, `[...arr]` of `[...arr]`
- `x.nil? ? nil : x` — return `x` unchanged
- `x.present? && x.present?` — same check twice
- `return nil` / `return undefined` at end of method already returning that
- `if x then x else y end` — use `x || y`

## Pedantic normalization

Type conversions where the value is already the target type.

- `.to_sym` on literal string (already interned)
- `.deep_dup` when `.dup` enough
- `.with_indifferent_access` when one code path, one key style
- `String(x)` when `x` is already `string`
- `Number(x)` on numeric literal

## Premature factoring

Structure introduced before the code has settled. Good cut points emerge from the codebase — don't force them early.

- private method, one caller, 1-2 line body
- constant for value used once
- wrapper that only renames (`def fetch_user; find_user; end`)
- stacked wrappers — `a()` calls `b()` calls `c()`, each single-use 1-liner. collapse chain to inline expression at call site
- namespace module with one class inside
- base class with one implementor
- generic parameter with one type
- thin library wrapper — wrapping a 3rd-party lib with a pass-through layer "in case we swap it later." wait until you actually swap it

## YAGNI abstraction

Extensibility for requirements that don't exist.

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

Comments and docs that add noise, not signal.

- comment restate code (`# increment counter` above `counter += 1`)
- YARD / JSDoc `@param`/`@return` on 1-line method where signature obvious
- long docstring for self-evident method
- commented-out code "for reference" — git remember
- `TODO:` no issue link, no owner — never happen
- markdown fence inside comment the tool not render
- **buzzword comment** — "robust", "comprehensive", "elegant", "powerful", "seamless", "gracefully handle". AI tell. human rarely write in comment. flag hard.
- **doc-to-code ratio red flag** — 20 line method body, 15 line comment. heavy slop. consolidate or cut.

## Log and debug noise

- `Rails.logger.debug "Entered method X"` — obvious trace. log useful branches, not obvious entry points
- `puts` / `p` / `pp` / `binding.pry` leftover from debug session
- `console.log` wasn't there before
- `print(...)` / `pprint(...)` leftover
- structured log on non-diagnostic path
- telemetry / metric emission with no consumer

## Unused imports / requires

Imports for modules no symbol references.

- `import` / `require` for module no symbol references
- AI generates imports associated with a task even when implementation doesn't use them
- leftover after refactor removed the last usage

## Semantic duplication

Same utility reimplemented in a different file.

- two or more functions with same intent, different names, slightly different behavior (`formatDate` in 3 files with 3 input types)
- AI generates each in a fresh prompt session without knowing the other exists
- grep for common suspects: date formatting, error wrapping, API response shaping, string normalization
- not same as copy-paste duplication — the implementations differ, the intent is identical

## Test slop

if diff include spec / test file.

- `it "works"` / `it "should work"` — empty semantic assertion
- mock object test didn't need isolate
- setup create record that assertion never touch
- `expect(true).to be_truthy` / `assert True`
- multiple test asserting same branch
- weak / existence-only assertion — `toBeDefined()`, `toBeTruthy()`, `not_to be_nil` without checking actual value. test specific outcomes

## Placeholder and stub

Incomplete implementations with no plan to finish.

- `def foo; raise NotImplementedError; end` with no caller plan
- `// TODO: add logic here` inside empty body
- method body only `pass` / `...` / `return nil` with no task
- if no plan to fill, cut or delete until plan exist

## Dead code after return / throw

- line after `return`, `throw`, `raise` that never run
- unreachable `else` after exhaustive `if`
- code past early-return that should've been noticed

## Type escape hatch

Silencing type system warnings without fixing the cause.

- TypeScript: `as any`, `@ts-ignore`, `@ts-expect-error` with no reason comment
- Ruby: `.send(:private_method)` for access shortcut, `.instance_variable_get`
- Python: `# type: ignore` with no reason, `cast(Any, x)`

Type system warns for a reason. Silence without fix = slop. Silence with a reason comment = possibly acceptable.
