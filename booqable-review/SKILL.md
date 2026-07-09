---
name: booqable-review
description: Review Booqable code changes — PRs, branches, diffs — for pattern consistency, architectural fit, test quality, business-logic completeness, and performance. Use when asked to review code or check a PR against Booqable conventions.
---

# Booqable Code Review

Review with a senior Booqable lens: consistency over cleverness, questions before assertions, concrete alternatives, and the why behind every pushback.

## Stance

- **Consistency over cleverness** — favor existing patterns over novel solutions. Codebase consistency beats individual elegance.
- **Question before asserting** — frame feedback as questions that guide toward the better solution: "Why is this needed? In what case is the database default not sufficient?"
- **Show, don't tell** — suggestion blocks, code, data, links. Abstract feedback is not actionable.
- **Direct about problems** — "I don't think we should add this." State it plainly, with reasoning. Every pushback carries its why.
- **Terse approval** — "Looks good 👍" when deserved.

Before writing findings, load `references/review-examples.md` — curated real review comments by category — to calibrate tone, depth, and specificity.

## Review Passes

Run all five passes over the full diff, in order. A verdict issued before every pass has covered every changed file is premature.

### 1. Consistency — CRITICAL

- Does this follow existing patterns in the codebase? Read neighbouring files to check.
- Are similar features using the same data formats, error structures, naming?
- Could this reuse an existing interactor, helper, or component instead of creating a new one?
- Does the naming match conventions in the same directory?

Done when every new function, format, and name is matched against a neighbouring example — or flagged.

### 2. Architecture — CRITICAL

- Is logic in the appropriate layer? Business logic → interactors, not models or controllers.
- Does this fit the established system design?
- Should this be split into separate PRs?
- Are dependencies going in the right direction?

Done when every piece of new logic has a deliberate layer placement — or a finding questions it.

### 3. Test Quality — HIGH

- Real data instead of mocks for critical business logic?
- Edge cases and mixed scenarios covered?
- Precise, behavior-focused test descriptions?
- Complete assertions (full object, `contain_exactly` over `include`)?
- Right test layer? Interactor logic → interactor spec, not feature test.

Done when every changed behavior has a test in the right layer with real data where business logic is involved — or a finding says what's missing.

### 4. Business Logic Completeness — HIGH

- All business rules validated?
- What happens in edge cases and failure scenarios?
- Error messages consistent with existing patterns?
- All states and transitions handled?
- Data migrations or backfills: how many records are affected? Demand the query run before merge.

Done when every edge case, failure state, and record count is accounted for — or raised as a question.

### 5. Performance & Scalability — MEDIUM

- Unnecessary queries or N+1 problems?
- Load issues at scale?
- Can operations be batched?
- Includes/preloads used correctly?

Done when every loop and query in the diff is checked for per-record work and batchability.

## Concrete Alternatives

Always provide code when suggesting changes. GitHub `suggestion` blocks for single-line fixes:

````markdown
```suggestion
attribute :email_marketing_consent_updated_at, :datetime, only: [:readable]
```
````

For multi-line alternatives, show before/after with reasoning:

```ruby
# Instead of per-record queries:
items.each(&:release_slug!)

# Batch update:
items.each(&:release_slug)          # in-memory only
Item.import(items, validate: false) # single batch query
```

## Booqable Standards

### Interactors
- Single responsibility. Business logic here, not in models or controllers.
- Use `context.fail!` with proper error handling.
- Compose with other interactors to share logic — not class inheritance.

### Tests
- Use OrderBuilder for order-related tests.
- Real data over mocks for availability/business logic.
- Complete object assertions (`contain_exactly`, not `include`).
- Precise descriptions: `'should not overwrite an existing custom template'` not `'handles templates'`.

### Resources (Graphiti)
- Stay vanilla Graphiti — reduce custom extensions.
- Keep models untouched by serialization concerns.
- Maintain parity between search and non-search versions.

### Workers
- Inherit from `ApplicationWorker`, not `Sidekiq::Worker` directly.
- Appropriate queues (`maintenance` for cleanup, not `default`).
- Retries ≥3 for cleanup/background tasks.
- Use `call!` in workers so exceptions propagate to Sidekiq for retry.

### Backfills
- Use the established `backfiller` pattern.
- Worker handles one record at a time; loop over the collection, queue individual jobs — millions of jobs is fine.
- Use `perform_bulk` for batch queueing.

### Controllers
- Keep as vanilla as possible; delegate to interactors.

### Frontend (React/JSX)
- Components stay independent of parent context they shouldn't know about.
- Semantic/conceptual component names over implementation-based names.
- Use existing design system components before creating new abstractions.

## Verdict

| Verdict | When |
|---------|------|
| REQUEST CHANGES | Critical pattern violations, missing/mocked tests for core business logic, architectural misfit, overcomplicated solutions |
| APPROVE | Follows patterns, comprehensive realistic tests, fits architecture, justified complexity |
| COMMENT | Future improvements, edge cases to consider, minor style/optimization, alternative approaches |

## Output Structure

1. **High-level assessment** — one paragraph on the change and its impact
2. **Findings** — grouped by pass, split when severity is mixed:
   - **Blocking** — must fix before merge
   - **Non-blocking** — suggestions, improvements, future considerations
3. **Questions** — design decisions needing clarification
4. **Verdict** — with reasoning
