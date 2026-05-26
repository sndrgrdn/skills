---
name: create-pr
description: Creates or updates GitHub pull requests with intent-focused descriptions. Use when asked to create PR, open PR, submit PR, make PR, update PR title, update PR description, edit PR, push and create PR, prepare changes for review, or draft a pull request. Handles both new PRs and updates to existing ones.
---

# Create PR

Create or update GitHub pull requests. Explain why, not what. Requires `gh` authenticated.

## Constraints

| Rule | Detail |
|------|--------|
| Intent | Ask for WHY before writing if the user only stated WHAT |
| Body content | Why-not-what only; no How section, file lists, change narration, test plans, or speculative risks |
| Prose | Single-line paragraphs; no hard wraps at arbitrary column widths |
| Body file | `PR_BODY_FILE=$(mktemp /tmp/pr_body.XXXXXX.md)` — never reuse `/tmp/pr_body.md` |
| Updates | Rewrite title and body against the current diff; do not append update logs |
| UI PRs | Include before/after screenshots when the change is visual |
| Issue links | Use `Fixes` / `Completes` for Linear; escape accidental `#NUMBER` in prose |
| Links section | Include `## Links` only when there is at least one link — never publish an empty heading |

## Workflow

### 1. Confirm feature branch

```bash
DEFAULT=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')
BRANCH=$(git branch --show-current)
```

Stop if `"$BRANCH" = "$DEFAULT"`. Create a feature branch, commit there, then continue.

### 2. Look for intent

Did the user state what problem they're solving and why they need this change?

If not, ask before any PR work:

```text
Before creating this PR, I need to understand the intent behind this change.

What problem does this solve, and why is this change needed?
```

### 3. Determine base branch

```bash
UPSTREAM=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null || true)
BASE="$DEFAULT"
if [ -n "$UPSTREAM" ] && [ "${UPSTREAM#origin/}" != "$BRANCH" ]; then
  BASE="${UPSTREAM#origin/}"
fi
```

Use `$DEFAULT` unless the current branch intentionally targets another integration branch. If uncertain, ask. Always pass `--base "$BASE"` to `gh pr create` — branch name only (e.g. `full`), not `origin/full`.

### 4. Validate diff matches intent

```bash
git status --porcelain
git diff "$BASE"...HEAD --stat
```

Compare changed files against what was discussed. Stop if unexpected files appear:

```text
I notice the diff includes changes to files we didn't discuss:
- <file>

These may be leftover from a previous session. Should I:
1. Proceed with all changes in one PR
2. Help split these into separate commits/PRs
3. Exclude them (stash or reset those files)
```

After the user chooses, continue to Step 5. Do not re-ask unless they chose split or exclude and need help.

### 5. Commit and push

```bash
git status --porcelain
git push
# If no upstream yet:
git push --set-upstream origin "$(git branch --show-current)"
```

Commit uncommitted changes first when present.

### 6. Draft and write body file

**Title:** `Area: Description` (e.g. `AI: Stop nested spinners on sub-agent steps`). Omit area prefix when changes span multiple areas.

**Template** — default when there are no issue or Slack links:

```markdown
## Why

<Problem being solved — not a narration of changes.>
```

Add `## Links` only when the user provided at least one link:

```markdown
## Why

<Problem being solved — not a narration of changes.>

## Links

Fixes https://linear.app/booqable/issue/PROJ-1234
```

```bash
PR_BODY_FILE=$(mktemp /tmp/pr_body.XXXXXX.md)
trap 'rm -f "$PR_BODY_FILE"' EXIT

# single-quoted EOF prevents $variable expansion
cat > "$PR_BODY_FILE" << 'EOF'
<description body here>
EOF
```

Before calling `gh`, confirm the file:

1. First line is exactly `## Why`
2. Matches the PR title and diff topic
3. Passes Constraints table, especially no How section or generated footer
4. No `## Links` heading unless at least one link follows it

Rewrite the file if any check fails.

### 7. Create or update

```bash
gh pr view --json number,title,body 2>/dev/null
```

**Existing PR:** rewrite title and body against the current diff. Keep title only if it still matches the dominant change.

```bash
gh pr edit --title "<title>" --body-file "$PR_BODY_FILE"
```

If `gh pr edit` fails because of the Projects deprecation API issue:

```bash
gh api -X PATCH "repos/{owner}/{repo}/pulls/$(gh pr view --json number -q '.number')" \
  -f title="<title>" \
  -F body=@"$PR_BODY_FILE"
```

**New PR:**

```bash
gh pr create --draft --base "$BASE" --title "<Area>: <Description>" --body-file "$PR_BODY_FILE"
```

**After create or edit**, verify:

```bash
gh pr view --json body -q '.body'
```

Re-run edit with the same file if the published body does not match `"$PR_BODY_FILE"`.

## Issue reference syntax

| Syntax | Effect |
|--------|--------|
| `Fixes <linear-url>` | Closes Linear issue on merge |
| `Completes <linear-url>` | Closes Linear issue on merge |
| `Fixes #1234` | Closes GitHub issue on merge |
| `Refs <linear-url>` | Links without closing |

## Example

Title: `Inventory: Fix null response in stock level endpoint`

```markdown
## Why

The stock level endpoint returns null for soft-deleted products, causing dashboard crashes when accessing inventory properties.

## Links

Fixes https://linear.app/booqable/issue/PROJ-5678
```

## Completion

Return to the user:

1. PR URL
2. Whether the PR was created or updated
3. Final title
4. Confirmation that published body matched the verified draft
