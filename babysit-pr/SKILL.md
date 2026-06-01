---
name: babysit-pr
description: Babysit a PR until actionable CI passes and high/medium review feedback is addressed. Use for PR CI failures, review feedback, or green-check loops; do not wait for human approval, draft status, or merge gates.
---

# Babysit PR Until CI Passes

Goal: fix actionable CI failures and high/medium review feedback. Stop and report human approval, draft-readiness, and merge-readiness gates.

Requires:
- authenticated `gh`
- Ruby available
- target repository root as cwd
- skill-root-relative script paths, for example `${SKILL_ROOT}/scripts/fetch_pr_checks.rb`

## Bundled Scripts

| Script | Run | Output |
|--------|-----|--------|
| `scripts/fetch_pr_checks.rb` | `ruby ${SKILL_ROOT}/scripts/fetch_pr_checks.rb [--pr NUMBER]` | JSON: `pr`, `summary`, `checks` with `annotations` (fast path) or `log_snippet` (fallback) |
| `scripts/fetch_pr_feedback.rb` | `ruby ${SKILL_ROOT}/scripts/fetch_pr_feedback.rb [--pr NUMBER]` | JSON buckets: `high`, `medium`, `low`, `bot`, `resolved` |
| `scripts/monitor_pr_checks.rb` | `ruby ${SKILL_ROOT}/scripts/monitor_pr_checks.rb [--pr NUMBER]` | terminal marker plus tab-separated checks |

Check summary fields include `failed`, `pending`, `actionable_pending`, and `human_gate_pending`.

Monitor markers:
- `ALL_CHECKS_PASSED`
- `CHECKS_DONE_WITH_FAILURES`
- `NO_CHECKS_REGISTERED`
- `DRAFT_PR_WITH_NO_CHECKS`
- `CHECKS_BLOCKED_BY_REVIEW_GATE`

## Workflow

### 1. Identify PR

Run:
```bash
gh pr view --json number,url,headRefName,isDraft,reviewDecision
```

Stop when:
- no PR exists
- draft PR has no checks after monitor grace period: report `DRAFT_PR_WITH_NO_CHECKS`

Draft rule: inspect existing checks/feedback only. Do not mark ready for review unless asked.

### 2. Handle Feedback

Run `ruby ${SKILL_ROOT}/scripts/fetch_pr_feedback.rb [--pr NUMBER]`.

| Bucket | Action |
|--------|--------|
| `high` | fix |
| `medium` | fix |
| `low` | ask user which to address |
| `bot` | skip informational comments |
| `resolved` | skip |

Feedback fix checklist:
- verify root cause
- search related code
- fix all instances
- for `review_bot: true`: fix real issues, explain false positives

Low-priority prompt format:
```text
Found 3 low-priority suggestions:
1. [l] "Consider renaming this variable" - @reviewer in app/models/order.rb:42
2. [nit] "Could use a guard clause" - @reviewer in app/controllers/orders_controller.rb:18
3. [style] "Add a comment" - @reviewer in app/interactors/create_order.rb:55

Which should I address? ("1,3", "all", or "none")
```

### 3. Check CI Status

Run `ruby ${SKILL_ROOT}/scripts/fetch_pr_checks.rb [--pr NUMBER]`.

| State | Action |
|-------|--------|
| `failed > 0` and `actionable_pending == 0` | fix failures |
| `actionable_pending > 0` | wait; poll feedback while waiting |
| `pending > 0` and `actionable_pending == 0` | report `CHECKS_BLOCKED_BY_REVIEW_GATE` |
| no checks after grace period | report `NO_CHECKS_REGISTERED` or `DRAFT_PR_WITH_NO_CHECKS` |
| all actionable checks passed | run post-CI feedback check |

Wait for actionable review bots: copilot, devin, cursor, bugbot, codeql.
Do not wait for approval, `isDraft`, `REVIEW_REQUIRED`, Codecov, or informational bots.

### 4. Fix CI Failures

For each failure:
1. check `annotations` array first — each entry has `path`, `line`, `title`, `message`; use these to jump directly to source
2. if no annotations, read full log: `gh run view <run-id> --log-failed`
3. trace from assertion/exception/lint rule to source
3. state the cause before editing: "fails because X, affected by Y"
4. search related call sites/patterns
5. fix root cause, not symptom
6. add focused test coverage when needed

### 5. Verify Locally, Then Commit and Push

Before commit:

| Failure type | Local verify command |
|---|---|
| RSpec test | `bin/rspec path/to/spec.rb:line` |
| Cucumber | `BROWSER=headless_chrome bin/cucumber path/to/feature.feature:line` |
| JS test | `pnpm test path/to/*.test.js` |
| Lint (rubocop/eslint) | `bin/fix-lint` |
| yaml_lint | `yamllint file_or_path` |

If local verification fails, fix before pushing — do not push known-broken code.

```bash
git add <files>
git commit -m "<lowercase descriptive message>"
git push
```

Commit style: lowercase, descriptive, no conventional commit prefix. Match existing repo convention.

### 6. Monitor CI and Address Feedback

Loop:
1. run `ruby ${SKILL_ROOT}/scripts/fetch_pr_checks.rb`
2. handle table in step 3
3. while `actionable_pending > 0`, run `ruby ${SKILL_ROOT}/scripts/fetch_pr_feedback.rb`
4. fix new high/medium feedback immediately
5. if changed, verify, commit, push, restart loop
6. otherwise sleep 30 seconds and repeat
7. after checks pass, wait 10 seconds, fetch feedback once more
8. if new high/medium feedback exists, return to step 4

Optional: run `ruby ${SKILL_ROOT}/scripts/monitor_pr_checks.rb` in background; restart after every push.

## Exit Conditions

| Exit | Conditions |
|------|------------|
| Success | actionable CI passed; post-CI feedback clean; low-priority choice handled |
| Ask user | same failure after 2 attempts; feedback unclear; infrastructure issue |
| Stop | no PR; branch needs rebase; no checks; draft no-checks; only human gates remain |

## Fallback

If scripts fail, use `gh` CLI directly:
- `gh pr view --json number,url,headRefName,isDraft,reviewDecision`
- `gh pr checks --json name,state,bucket,description,link`
- `gh run view <run-id> --log-failed`
- `gh api repos/{owner}/{repo}/pulls/{number}/comments`
