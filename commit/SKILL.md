---
name: commit
description: Commit staged or related changes with a clear message. Use when asked to "commit", "commit changes", "commit and push", "save changes", or "commit what we did".
---

# Commit

Commit scoped changes with a descriptive message. Optionally push.

## Step 1: Assess changes

```bash
git status --porcelain
git diff --stat
git diff --cached --stat
```

If nothing is staged, stage only files related to the current task. Do not stage unrelated changes.

When unsure which files belong to the task, show the list and ask.

## Step 2: Write commit message

Write a short, lowercase, descriptive subject line (< 72 chars).

| Pattern | Example |
|---------|---------|
| Action + what changed | `add chat search dropdown with keyboard navigation` |
| Area prefix when scoped | `inventory: fix stock level calculation` |
| Fix description | `fix null response in stock level endpoint` |
| Simple update | `update conversation_starter.rb` |

Rules:
- No conventional commit prefixes (`feat:`, `fix:`, `chore:`) unless the repo uses them
- No period at end
- Lowercase start
- Imperative mood when natural, but don't force it
- Body paragraph only when the "why" isn't obvious from the subject

## Step 3: Commit

```bash
git commit -m "<message>"
```

If the user said "commit and push" or "push", also push:

```bash
git push
# If no upstream:
git push --set-upstream origin "$(git branch --show-current)"
```

## Step 4: Confirm

Report: committed files count, subject line, and whether pushed.
