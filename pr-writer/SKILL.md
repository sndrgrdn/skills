---
name: pr-writer
description: ALWAYS use this skill when creating or updating pull requests — never create or edit a PR directly without it. Trigger on any create PR, open PR, submit PR, make PR, update PR title, update PR description, edit PR, push and create PR, prepare changes for review task, or request for a PR writer.
---

# PR Writer

Create pull requests with clear intent and proper issue linking.

**Requires**: GitHub CLI (`gh`) authenticated and available.

## Core Rules

1. **Never fabricate intent.** If the user hasn't explained WHY the change is needed, ask before creating the PR. "Do X" describes WHAT, not WHY.
2. **Never list files changed.** GitHub already shows this.
3. **Never narrate code changes.** The diff shows the implementation.
4. **Never speculate on risks.** Only include risks the user explicitly mentioned.
5. **Never include a "Test plan" section.** Testing is implicit in QA processes.

## Process

### Step 1: Commit and Push

```bash
git status --porcelain
```

If there are uncommitted changes, commit them first. Then ensure the branch is pushed:

```bash
git push
# If the remote branch doesn't exist yet:
git push --set-upstream origin "$(git branch --show-current)"
```

### Step 2: Determine Base Branch

```bash
# Get default branch
gh repo view --json defaultBranchRef -q '.defaultBranchRef.name'

# Check upstream tracking branch
git rev-parse --abbrev-ref @{upstream} 2>/dev/null
```

If the upstream tracking branch differs from the default branch, use the upstream's remote branch as the base. If uncertain, ask the user. Always pass `--base <branch>` to `gh pr create`.

### Step 3: Validate Diff

```bash
git diff <base>...HEAD --stat
```

Compare changed files against what was discussed in the session. If there are **unexpected files** not part of the conversation, stop and present options:

1. Proceed with all changes in one PR
2. Help split into separate commits/PRs
3. Exclude them (user stashes or resets those files)

Only proceed once the user confirms the diff is intentional.

### Step 4: Write the PR Description

If intent (the WHY) is not clear from the conversation, ask the user before writing.

**Description template:**

```markdown
## Why

<Why this change is needed — the problem being solved, not a narration of changes.>

## Links

<Linear issues or Slack discussions. Use "Fixes [link]" or "Completes [link]" to auto-close Linear issues on merge. Omit section if no links.>
```

**Do NOT include:**
- File lists or change summaries
- "Test plan" sections or testing checklists
- Speculative risks
- Narration of what the diff already shows

**Do include:**
- Clear explanation of why, not what
- Links to Linear issues or Slack discussions
- Before/after screenshots or recordings for UI changes (always include visual evidence for UI changes)
- Context that isn't obvious from the code

### Step 5: Create or Update PR

Check if a PR already exists for this branch:

```bash
gh pr view --json number 2>/dev/null
```

**If PR exists**, update it:

```bash
gh pr edit --title "<title>" --body "<body>"
```

If `gh pr edit` fails (known GitHub API issue with Projects deprecation), use the REST API directly:

```bash
cat > /tmp/pr_body.md << 'EOF'
<description body here>
EOF

gh api -X PATCH "repos/{owner}/{repo}/pulls/$(gh pr view --json number -q '.number')" \
  -f title="<title>" \
  -F body=@/tmp/pr_body.md
```

**If no PR exists**, create one. Always write the body to a temp file — inline `--body` with heredocs breaks on quotes and backticks:

```bash
cat > /tmp/pr_body.md << 'EOF'
<description body here>
EOF

gh pr create --draft --base "<base>" --title "<Area>: <Description>" --body-file /tmp/pr_body.md
```

**Title format** — prefix with the area or feature, then a colon:
- `Orders: Improved bundle sorting`
- `Inventory: Fix stock level calculation`
- `Auth: Add SSO support for enterprise accounts`

Omit the prefix when changes span multiple areas.

## PR Description Examples

### Feature PR

Title: `Orders: Add Slack thread replies for alert notifications`

```markdown
## Why

When an alert is updated or resolved, a new Slack message is created each
time, flooding the channel. Thread replies keep related notifications
grouped and reduce noise.

## Links

Completes https://linear.app/booqable/issue/PROJ-1234
```

### Bug Fix PR

Title: `Inventory: Fix null response in stock level endpoint`

```markdown
## Why

The stock level endpoint returns null for soft-deleted products, causing
dashboard crashes when accessing inventory properties. This adds a null
check and returns a proper 404 response.

## Links

Fixes https://linear.app/booqable/issue/PROJ-5678
```

### Refactor PR

Title: `Validation: Extract shared validation module`

```markdown
## Why

Duplicate validation logic across orders, issues, and products endpoints
makes it easy to introduce inconsistencies. Extracting to a shared module
prepares for adding new validation rules without duplication.
```

## Issue References

| Syntax | Effect |
|--------|--------|
| `Fixes <linear-url>` | Closes Linear issue on merge |
| `Completes <linear-url>` | Closes Linear issue on merge |
| `Fixes #1234` | Closes GitHub issue on merge |
| `Refs <linear-url>` | Links Linear issue without closing |
| `Refs #1234` | Links GitHub issue without closing |

**Avoid accidental issue links:** `#42` auto-links to issue 42 on GitHub. Only use `#NUMBER` for intentional references. In prose, rephrase ("the top cause" not "the #1 cause") or escape with `\#`.

## Guidelines

- **One PR per feature/fix** — Don't bundle unrelated changes
- **Keep PRs reviewable** — Smaller PRs get faster, better reviews
- **Explain the why** — Code shows what; description explains why
- **Mark WIP early** — Use draft PRs for early feedback

## Anti-Patterns

| Don't | Why |
|-------|-----|
| Fabricate intent | User didn't explain why → ask, don't invent |
| List files changed | GitHub already shows this |
| Narrate code changes | The diff shows the implementation |
| Speculate on risks | Only include if user mentioned them |
| Add "Test plan" section | Testing is implicit; clutters the PR |
| Use `#NUMBER` in prose | Auto-links to issues — rephrase or escape |
