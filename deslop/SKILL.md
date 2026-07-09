---
name: deslop
description: Scan a recent diff for slop — unnecessary complexity, defensive chaff, premature abstraction, LLM-generated filler. Use when asked to deslop, trim chaff, cut cruft, simplify, or review before PR.
---

# Deslop

Core question: **is this code more complex than it needs to be?**

Scope: recently written code you understand. Not refactoring, not redesign, not bug fixing.

## Workflow

### 1. Find scope

Probe order unless the user specifies a range:

1. `git diff --cached`
2. `git diff HEAD`
3. `git log origin/<base>..HEAD`
4. user-specified path, commit, or range

State scope before scanning:

> review `origin/main..HEAD` — 10 commits, 39 files.

Stop and ask if the diff is empty, over 100 files, or ownership is unclear.

### 2. Check fences

Chesterton's fence: understand a safeguard before cutting it. Nearby slop is not evidence that new slop should stay.

Before marking a candidate **drop**, check enough context to answer:

- **behavior:** preserves an API, framework, or compatibility contract?
- **safety:** protects a realistic failure path?
- **consistency:** would removing it create risky inconsistency?

Lightest check first: same file → same module → file history (only for safeguards, public API, or unclear intent).

| Context result | Action |
|----------------|--------|
| required fence | keep — explain the contract |
| repeated slop | flag — note repetition |
| novel slop | flag if catalog match |
| unclear intent | not sure — ask or keep |

### 3. Load catalogs and scan

Always read `references/catalog.md`.

| Diff contents | Also read |
|---------------|-----------|
| `.rb`, `.rake`, `.erb`, `Gemfile`, `app/`, `config/`, `db/` | `references/catalog-ruby.md` |
| `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `package.json` | `references/catalog-javascript.md` |

For each candidate, record: file:line, snippet, one-sentence reason, verdict (**drop** / **keep** / **not sure**), context result. Do not edit.

### 4. Propose findings

```markdown
review `<scope>` — <N> files.

### 1. <label>

`file:line`

```lang
<snippet>
```

<why this is slop. note tradeoff if any.>

**verdict:** drop | keep | not sure — <reason>
**context:** required fence | repeated slop | novel slop | unclear intent — <evidence>

---

Recommended bundle: apply <numbers>, skip <numbers>. Net: ~<lines> lines.
```

No good cuts? Say so. List only important keep decisions.

### 5. Wait for approval

Apply only when the user names specific numbers, says `all`, or says `recommended bundle`.

Ambiguous ("looks good") → ask: *apply all or recommended bundle?*

### 6. Apply and verify

Targeted edits for approved items only.

Completion: every approved cut applied, syntax/typecheck/lint passes (or skip reason stated), focused tests green if they exist, no unrelated changes introduced.

Commit only if asked:

```
<area>: deslop <what>

- drop redundant boolean coercion in foo
- remove unused defensive copy in bar
- inline one-use wrapper in baz
```

## References

- `references/catalog.md` — generic slop categories
- `references/catalog-ruby.md` — Ruby/Rails slop
- `references/catalog-javascript.md` — JS/TS/React slop
