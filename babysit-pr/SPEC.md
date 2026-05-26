# babysit-pr Specification

## Intent

The `babysit-pr` skill drives a pull request through actionable CI failures and actionable review feedback until the work is locally fixed, pushed, and rechecked.

Adapted from [Sentry's iterate-pr skill](https://github.com/getsentry/skills/tree/main/skills/iterate-pr) for a Ruby/Rails codebase using GitHub Actions.

Its purpose is CI and feedback iteration, not merge readiness. It must not wait indefinitely for human approvals, required review decisions, draft PR state changes, or other gates that an agent cannot resolve by editing code.

## Scope

In scope:

- Identifying the PR for the current branch.
- Fetching and categorizing PR review feedback.
- Fixing high and medium priority review feedback.
- Asking the user which low priority suggestions to address.
- Fetching CI checks, failed logs, and failure snippets.
- Fixing CI failures with local verification before pushing.
- Monitoring checks until they pass, fail, or reach a non-actionable stop state.
- Reporting draft/no-checks and human review/approval gates without polling forever.

Out of scope:

- Waiting for or requesting human approval.
- Marking draft PRs ready for review unless the user explicitly asks.
- Merging PRs.
- Rebasing branches without user direction.
- Treating Codecov, Dependabot, or other informational comments as review feedback.

## Users And Trigger Context

- Primary users: engineers and coding agents iterating on existing pull requests.
- Common user requests: fix CI on this PR, babysit this PR until checks pass, address PR feedback, keep pushing fixes until green.
- Should not trigger for: creating a PR, writing commits without a PR, reviewing unrelated code, or monitoring merge approval state only.

## Runtime Contract

- Required first actions: resolve the current PR, read `isDraft` and `reviewDecision`, fetch current review feedback, and fetch current CI state before editing.
- Required outputs: concise progress updates, commits and pushes when fixes are made, and a final state that distinguishes passing CI from non-actionable review/draft/approval gates.
- Non-negotiable constraints: investigate failures before editing, verify locally before pushing, do not push known-broken fixes, do not wait for human approval, and do not treat draft PRs with no checks as pending forever.
- Expected bundled files loaded at runtime: `SKILL.md` and, when needed, scripts under `scripts/`.

## Source And Evidence Model

Authoritative sources:

- [Sentry iterate-pr skill](https://github.com/getsentry/skills/tree/main/skills/iterate-pr) — original design
- GitHub CLI PR and checks output.
- Repository-level agent instructions.
- Bundled script behavior documented in `SKILL.md`.

Useful improvement sources:

- positive examples: PRs where CI failures were fixed and checks passed after the loop.
- negative examples: PRs where the agent waited on draft status, required review, or approval gates.
- issue or PR feedback: reviewer comments about missing fixes, false positives, or feedback categorization.
- validation results: script syntax checks.

Data that must not be stored:

- secrets
- customer data
- private URLs or identifiers not needed for reproduction
- full CI logs when small failure snippets are enough

## Reference Architecture

- `SKILL.md` contains the runtime workflow, script contracts, feedback handling rules, CI loop, and exit conditions.
- `SPEC.md` contains this maintenance contract.
- `scripts/` contains non-interactive helpers for PR checks, PR feedback, and check monitoring.

## Validation

- Lightweight validation: scripts parse without error, `gh` CLI available.
- Script validation: `ruby -c scripts/*.rb` after script changes.
- Holdout examples: a draft PR with no registered checks, a PR with `reviewDecision: REVIEW_REQUIRED` but passing checks, a PR with an actionable pending CI bot check, and a PR with failed CI logs.
- Acceptance gates: scripts compile, draft/no-check states terminate with a report, human review gates are not treated as actionable pending CI, and actionable CI failures still route back to investigation and fixes.

## Known Limitations

- Human-gate detection depends on check names, states, and descriptions exposed by GitHub or CI integrations.
- Some repositories may intentionally model deployment or approval workflows as status checks; this skill reports those as blocked/non-actionable unless the user asks to manage that gate.
- The helper scripts use GitHub CLI output and can drift if `gh pr checks` changes its JSON schema.
- Bot detection relies on username patterns — new bots need manual addition.
- Feedback categorization is heuristic — no explicit priority markers from reviewers unless LOGAF-style prefixes are used.

## Maintenance Notes

- Update `SKILL.md` when the runtime loop, script contracts, feedback policy, or exit conditions change.
- Update `SPEC.md` when the skill's scope, validation expectations, or non-actionable gate policy changes.
- When to update scripts: GitHub API changes, new failure patterns, new bot integrations.
- Keep public inventories pointed at the canonical `babysit-pr` skill, not mirrors or aliases.
