# create-pr Specification

## Intent

Create and update GitHub pull requests with a clear why, correct base branch, and safe body publishing. Based on Intercom's intent-first workflow with Booqable conventions and portable tooling.

## Scope

In scope:
- Feature-branch checks before PR creation
- Intent validation before commit/push and PR work
- Base branch selection
- Diff validation against session intent
- PR title and description authoring
- Draft PR creation and PR updates via `gh`
- Post-publish body verification
- Rewriting existing PR title/body against the current diff

Out of scope:
- Rebasing, conflict resolution, or merge
- CI babysitting (use `babysit-pr`)
- Splitting unrelated diffs without user confirmation
- Conventional-commit title format (Booqable uses `Area: Description`)

## Runtime Contract

- Required first actions: confirm not on default branch, check intent, determine base branch, validate diff — all before commit/push
- Required outputs: PR URL, verified published body matches intended draft
- Non-negotiable constraints: ask for missing why before PR work, no How section in body, no empty `## Links` heading, use `mktemp` for body files, verify before and after `gh`, rewrite updated PRs instead of appending
- Runtime-loaded files: `SKILL.md` only
- No runtime dependency on other skills

## Source Model

Lineage (not loaded at runtime):

- [Intercom create-pr skill (gist)](https://gist.github.com/gregolsen/2aefc99aab6a44f5bc4e06638ad4f163) — intent-first workflow; excluded Claude-specific parts (allowed-tools, plan-mode, ~/.claude/plans, How section, generated footer)
- [Sentry pr-writer skill](https://github.com/getsentry/skills/tree/main/skills/pr-writer) — update/rewrite patterns
- GitHub CLI `gh pr create`, `gh pr edit`, `gh pr view`

## Intercom Delta

| Area | Intercom | create-pr |
|------|----------|-----------|
| Name | create-pr | create-pr |
| Body | Why + How | ## Why only |
| Plan file | provider lookup | cut |
| Footer | generated-by | cut |
| Tools frontmatter | allowed-tools | cut |
| PR create | inline body | mktemp + --body-file |
| PR type | normal | draft |
| Links | GitHub cards | Linear Fixes/Completes |
| Updates | body edit | title+body rewrite + verify |
| Feature branch | none | Step 1 guard |

## Validation

- Not on default branch
- Temp file uses `mktemp`
- First line is `## Why`
- No `## Links` heading unless at least one link follows it
- Post-`gh` body matches file

## Model Adapters

| Family | Adapter |
|--------|---------|
| Claude | Markdown headings sufficient |
| GPT | Do not skip Step 6 verification or Step 7 post-publish check; never add a How section |

## Known Limitations

- Cannot upload screenshots to GitHub automatically; user must attach assets for UI PRs
- `gh pr edit` may fail on Projects deprecation; REST fallback documented in `SKILL.md`

## Maintenance Notes

- Update `SKILL.md` when upstream reference patterns, `gh` flags, base-branch logic, or Booqable PR conventions change
