# babysit-pr Specification

## Intent

Automate the feedback-fix-push-wait cycle on a PR until CI is green and review feedback is addressed. Adapted from [Sentry's iterate-pr skill](https://github.com/getsentry/skills/tree/main/skills/iterate-pr) for a Ruby/Rails codebase using GitHub Actions.

## Scope

In scope:
- Fetching and parsing CI check results
- Extracting failure log snippets with Ruby/Rails-aware patterns
- Categorizing PR review feedback by priority
- Monitoring checks until terminal state
- Guiding the fix-verify-push loop

Out of scope:
- Running the full test suite (only targeted verification)
- Rebasing or resolving merge conflicts
- Creating PRs
- Documentation workflow comments (github-actions[bot])

## Users and Trigger Context

- Primary users: developers iterating on open PRs
- Common requests: "fix CI", "make checks green", "address review feedback", "babysit this PR", "iterate on this PR"
- Should not trigger for: creating PRs, reviewing others' code, general testing

## Runtime Contract

- Required first actions: identify PR via `gh pr view`
- Required outputs: fix commits pushed, CI status reported
- Non-negotiable constraints: investigate before fixing, verify locally before pushing, max 2 retries per same real failure, max 1 automatic re-run for suspected flaky tests
- Expected bundled files: 3 Ruby scripts in `scripts/`

## Source and Evidence Model

Authoritative sources:
- [Sentry iterate-pr skill](https://github.com/getsentry/skills/tree/main/skills/iterate-pr) — original design

Data that must not be stored:
- secrets, tokens, API keys
- customer data

## Reference Architecture

- `SKILL.md` contains: workflow, script docs, decision tables
- `scripts/` contains: `fetch_pr_checks.rb`, `fetch_pr_feedback.rb`, `monitor_pr_checks.rb`

## Validation

- Lightweight: scripts parse `--help` without error, `gh` CLI available
- Deeper: run against an actual PR with known check states

## Known Limitations

- Bot detection relies on username patterns — new bots need manual addition
- Feedback categorization is heuristic — no explicit priority markers from reviewers
- Log snippet extraction may miss unusual failure formats
- Sharded test failures (rspec × 4, cucumber × 32) may produce large log output
- Flaky test detection is heuristic — checks PR diff and failure patterns but cannot guarantee a test is truly unrelated

## Maintenance Notes

- When to update `SKILL.md`: new CI checks added, bot patterns change, local verify commands change
- When to update scripts: GitHub API changes, new failure patterns, new bot integrations
