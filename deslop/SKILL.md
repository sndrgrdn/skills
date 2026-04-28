---
name: deslop
description: Review recently written code for over-engineering, paranoia, defensive chaff, and LLM-generated slop. Use when asked to deslop, trim chaff, trim the fat, cut cruft, remove paranoia, check for over-engineering, simplify recent work, or do a critical review before PR. Scans a diff, checks local idiom, proposes numbered cuts, and applies only explicitly approved changes.
---

# Deslop

Review only recently written code that is in scope and understood. Find unnecessary complexity, defensive chaff, premature abstraction, and AI-generated filler. Keep behavior, local idioms, and useful safeguards.

Core question: **is this code more complex than it needs to be?**

Do not turn deslop into general refactoring, redesign, style review, or bug fixing.

## Use When

- after implementing a feature, before push or PR
- after a cross-cutting change where extra scaffolding may have crept in
- when review feedback says code looks over-engineered
- when the user asks to deslop, trim chaff, cut cruft, remove paranoia, or simplify recent work

## Do Not Use When

- no diff or recent scope is available
- tests are failing for a real behavior bug; fix the signal first
- code is vendored, generated, or unfamiliar
- the task is already a pure refactor
- the requested change would require redesign outside the recent diff

## Workflow

| Step | Action | Rule |
|------|--------|------|
| 1 | Find scope | State exact diff/range before scanning |
| 2 | Read neighbors | Check local idiom before flagging |
| 3 | Scan catalogs | Record candidates only; do not edit |
| 4 | Propose cuts | Numbered findings with verdict and neighbor result |
| 5 | Wait for approval | Apply only explicit user picks |
| 6 | Edit and verify | Targeted cuts, syntax/lint/test when feasible |

### Step 1: Find Scope

Use this probe order unless the user specifies a range:

1. `git diff --cached` — staged changes
2. `git diff HEAD` — staged + unstaged changes
3. `git log origin/<base>..HEAD` — branch commits
4. user-specified path, commit, or range

State scope before scanning:

> review `origin/main..HEAD` — 10 commits, 39 files.

Stop and ask if:

- the diff is empty
- the diff is over 100 files; ask for path, commit range, or feature slice
- ownership or intent is unclear enough that cuts would be guesses

### Step 2: Read Neighbors Before Flagging

Do not flag a pattern until checking why it might exist.

Check:

- **same file** — is the pattern already common here?
- **same module/folder** — is it a local convention?
- **file history** — has the pattern existed long enough to be intentional?

| Neighbor result | Action |
|-----------------|--------|
| local idiom | keep; mention only if important |
| novel to file/module | flag if it matches catalog slop |
| mixed/unclear | mark ambiguous; ask or recommend keep |

This is Chesterton's fence: do not remove a safeguard or convention until its purpose is understood.

### Step 3: Load Catalogs and Scan

Always read `references/catalog.md`.

Load language-specific catalogs based on diff contents:

| Extension / pattern | Read |
|---------------------|------|
| `.rb`, `.rake`, `.erb`, `Gemfile`, `app/`, `config/`, `db/` | `references/catalog-ruby.md` |
| `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `package.json` | `references/catalog-javascript.md` |
| other languages | use `references/catalog.md`; flag only high-confidence generic hits |

For each candidate, record:

- file path + line
- snippet
- one-sentence reason
- verdict: **drop**, **keep**, or **not sure**
- neighbor result: **local idiom**, **novel**, or **ambiguous**

Do not edit during scanning.

### Step 4: Propose Findings

Use this format:

````markdown
review `<scope>` — <N> files.

Found <N> candidates:

### 1. <short label>

```<lang>
<snippet>
```

file:line

<why this may be slop. Note behavior/safety tradeoff if any.>

**verdict:** drop | keep | not sure — <reason>
**neighbor:** local idiom | novel | ambiguous — <evidence>
````

End with:

```markdown
Recommended bundle: apply <numbers>, skip <numbers>. Estimated net change: ~<lines> lines.
```

If no good cuts exist, say so directly and list only important keep decisions.

### Step 5: Require Explicit Approval

Apply changes only when the user names a subset, says `all`, or says `recommended bundle` / `your pick`.

Ambiguous approval such as "looks good" is not enough. Ask:

> apply all findings or only the recommended bundle?

### Step 6: Apply and Verify

Make targeted edits only for approved items.

After edits:

1. run syntax/typecheck/lint for changed files when available
2. run focused tests if affected code has tests
3. report unrelated failures separately with exact command and shortest relevant error

Commit only if the user asked for a commit. If committing, use one scoped commit:

```text
<area>: deslop <what>

- drop redundant boolean coercion in foo
- remove unused defensive copy in bar
- inline one-use wrapper in baz
```

## Anti-Patterns

| Do not | Why |
|--------|-----|
| edit during scan | user must approve cuts first |
| skip neighbor check | risks removing local idiom or necessary safeguard |
| widen into redesign | deslop is narrow recent-diff cleanup |
| apply from ambiguous approval | user intent is unclear |
| mark everything as drop | honest uncertainty prevents bad cuts |
| invent findings outside catalogs | taste is not evidence |
| deslop unfamiliar code | guesses break useful fences |
| mix bug fixes with deslop | fix behavior first, simplify second |

## Checklist

Before reporting done:

- [ ] scope stated
- [ ] relevant catalogs loaded
- [ ] neighbor check performed for each candidate
- [ ] every finding cites file:line + snippet
- [ ] every finding has verdict + neighbor result
- [ ] user explicitly approved applied cuts
- [ ] syntax/lint/test run or skipped with reason
- [ ] no unrelated redesign or style-only changes included

## References

- `references/catalog.md` — generic slop categories
- `references/catalog-ruby.md` — Ruby/Rails-specific slop
- `references/catalog-javascript.md` — JS/TS/React-specific slop
