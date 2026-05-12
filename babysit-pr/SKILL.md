---
name: babysit-pr
description: Babysit a PR until CI passes and review feedback is addressed. Use when asked to "fix CI", "fix failing checks", "babysit PR", "iterate on PR", "address review feedback", "make CI green", "fix the build", or "keep pushing until it passes".
---

# Babysit PR Until CI Passes

Continuously iterate on the current branch until all CI checks pass and review feedback is addressed.

**Requires**: GitHub CLI (`gh`) authenticated, Ruby available.

**Important**: Run all scripts from the repository root. Use full path via `${SKILL_ROOT}` to reference scripts.

## Bundled Scripts

### `scripts/fetch_pr_checks.rb`

Fetch CI check status and extract failure snippets from logs.

```bash
ruby ${SKILL_ROOT}/scripts/fetch_pr_checks.rb [--pr NUMBER]
```

Returns JSON:
```json
{
  "pr": {"number": 123, "branch": "feat/foo"},
  "summary": {"total": 5, "passed": 3, "failed": 2, "pending": 0},
  "checks": [
    {"name": "rspec_tests", "status": "fail", "log_snippet": "...", "run_id": 123},
    {"name": "rubocop", "status": "pass"}
  ]
}
```

### `scripts/fetch_pr_feedback.rb`

Fetch and categorize PR review feedback by priority.

```bash
ruby ${SKILL_ROOT}/scripts/fetch_pr_feedback.rb [--pr NUMBER]
```

Returns JSON with feedback categorized as:
- `high` — must address before merge (blockers, security, changes requested)
- `medium` — should address (standard feedback)
- `low` — optional (nit, style, suggestion)
- `bot` — informational automated comments (skip silently)
- `resolved` — already resolved threads

Review bot feedback (Copilot, Devin, Cursor, Bugbot, CodeQL) appears in `high`/`medium`/`low` with `review_bot: true` — NOT in the `bot` bucket.

### `scripts/monitor_pr_checks.rb`

Monitor PR checks until all reach a terminal state.

```bash
ruby ${SKILL_ROOT}/scripts/monitor_pr_checks.rb [--pr NUMBER]
```

Prints one terminal marker followed by a tab-separated check summary:
- `ALL_CHECKS_PASSED`
- `CHECKS_DONE_WITH_FAILURES`

## Workflow

### 1. Identify PR

```bash
gh pr view --json number,url,headRefName
```

Stop if no PR exists for the current branch.

### 2. Gather Review Feedback

Run `fetch_pr_feedback.rb` to get categorized feedback.

### 3. Handle Feedback by Priority

**Auto-fix (no prompt):**
- `high` — must address (blockers, security, changes requested)
- `medium` — should address (standard feedback)

When fixing feedback:
- Understand root cause, not just surface symptom
- Check for similar issues in nearby code or related files
- Fix all instances, not just the one mentioned

Review bot feedback (items with `review_bot: true`) — treat same as human feedback:
- Real issue → fix it
- False positive → skip, but explain why
- Never silently ignore review bot feedback

**Prompt user for selection:**
- `low` — present numbered list:

```
Found 3 low-priority suggestions:
1. [nit] "Consider renaming this variable" - @reviewer in app/models/order.rb:42
2. [style] "Could use a guard clause" - @reviewer in app/controllers/orders_controller.rb:18
3. [minor] "Add a comment" - @reviewer in app/interactors/create_order.rb:55

Which would you like to address? (e.g., "1,3" or "all" or "none")
```

**Skip silently:**
- `resolved` threads
- `bot` comments (github-actions, dependabot, etc.)

### 4. Check CI Status

Run `fetch_pr_checks.rb` to get structured failure data.

**Wait if pending:** If review bot checks (Copilot, Devin, CodeQL) are still running, wait — they post actionable feedback. Info bots (codecov) are not worth waiting for.

### 5. Triage CI Failures — Flaky vs Real

Before fixing, determine whether each failure is **real** (caused by PR changes) or **flaky** (pre-existing / intermittent).

**Flaky test indicators** (any of these suggest flakiness):
- Failure is in code not touched by the PR (`git diff main...HEAD` doesn't include the failing file or its direct dependencies)
- Timing/race condition patterns: element not visible, timeout, connection refused, "expected X to be on page"
- The same test passed in a previous CI run on the same branch
- Infrastructure errors: container startup, network, OOM, service unavailable

**When flaky tests are detected:**

1. Confirm flakiness — check PR diff to rule out indirect causes
2. Re-run only the failed jobs:
   ```bash
   gh run rerun <run_id> --failed
   ```
3. Monitor the re-run with `monitor_pr_checks.rb`
4. If the same test fails again after re-run, investigate whether the PR could be an indirect cause (e.g., adding a gem that changes global behavior, changing shared infrastructure)
5. **Max 1 automatic re-run per workflow run.** After that, report the persistent failure and ask for guidance
6. If confirmed unrelated after investigation, note it and move on — do not block the PR on pre-existing flaky tests

### 6. Fix Real CI Failures

**Investigation is mandatory before any fix.** Do not guess from the check name or surface error.

For each failure:

1. **Read the full log.** Use `gh run view --log-failed` if the snippet is truncated. Identify the exact failing assertion, exception, or lint rule.
2. **Trace backwards from failure to cause.** Follow the stack trace into source code. Read relevant functions and call sites. Do not stop at the first plausible explanation.
3. **Verify understanding before touching code.** State: "This fails because X, which was introduced/affected by Y." If you cannot state that clearly, keep investigating.
4. **Do not assume feedback is wrong.** Investigate fully before concluding false positive.
5. **Check for related instances.** If a bug exists at one call site, search for the same pattern nearby. Fix all instances.
6. **Fix root cause with minimal changes.** No papering over symptoms.
7. **Extend tests when needed.** If the fix introduces uncovered behavior, add a test case.

### 7. Verify Locally, Then Commit and Push

Before committing, verify fixes locally:

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

### 8. Monitor CI and Address Feedback

Loop instead of blocking:

1. Run `fetch_pr_checks.rb` for current CI status
2. All checks passed → proceed to exit conditions
3. Any checks failed (none pending) → return to step 5 (triage flaky vs real)
4. Checks still pending:
   a. Run `fetch_pr_feedback.rb` for new review feedback
   b. Address any new high/medium feedback immediately
   c. If changes needed, commit and push (restarts CI), continue monitoring
   d. Sleep 30 seconds, repeat from sub-step 1
5. After all checks pass, wait 10 seconds, then run `fetch_pr_feedback.rb`. Address any new high/medium feedback — if changes needed, return to step 6.

### 9. Repeat

If step 8 required code changes (new feedback after CI passed), return to step 2 for a fresh cycle.

## Exit Conditions

**Success:** All checks pass (or only confirmed-flaky tests remain), post-CI feedback re-check is clean, user has decided on low-priority items.

**Ask for help:** Same real failure after 2 attempts, feedback needs clarification, infrastructure issues, flaky test persists after re-run and indirect cause is suspected.

**Stop:** No PR exists, branch needs rebase.

## Fallback

If scripts fail, use `gh` CLI directly:
- `gh pr checks`
- `gh run view --log-failed`
- `gh api repos/{owner}/{repo}/pulls/{number}/comments`
