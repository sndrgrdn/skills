---
name: create-pr
description: Create or update GitHub pull requests for the current branch or an existing branch stack. Use when the user asks to open a PR, publish a stack, or push changes and open PRs.
---

# Create Pull Requests

Run this workflow in the main session. Keep intent, confirmation, commit, push, and PR publication in the same context.

A request to create a PR authorizes the push needed to create it. An earlier instruction to wait, not push, or not create a PR remains a hard stop until the user explicitly withdraws it.

This skill requires Bash, Git, GitHub CLI (`gh`), `jq`, and an authenticated GitHub session.

## 1. Establish intent

Most sessions will not include intent. A request such as “add a button” states the change, not the problem it solves or why it is needed.

Find both parts in the conversation:

- the problem this change solves
- why the change is needed

If either part is missing, ask:

> Before creating this PR, I need to understand the intent behind this change.
>
> What problem does this solve, and why is this change needed?

Continue when the answer supplies the PR's `Why?` without guesswork.

## 2. Read repository context

Resolve `scripts/check-pr-context.sh` relative to this `SKILL.md`, then run it once from the target repository:

```bash
bash "<skill-directory>/scripts/check-pr-context.sh"
```

Run the script during the current workflow before any `gh pr create`. Retain and reuse its result rather than inferring `repo`, `visibility`, `branch`, `already_pushed`, or `default_branch`. Pass `--repo "<repo>"` explicitly on every `gh pr` command, so the repository the visibility gate was computed for is the one published to.

Stop when `visibility` is `UNKNOWN`; publication safety cannot be selected without it. When `visibility` is `PUBLIC`, read [`public-repository.md`](public-repository.md) and apply every gate it defines.

Use `default_branch` as the base unless the user named another base. Ask when the intended base is unclear.

## 3. Select normal or stacked publication

Run `gh stack view --json` and branch on its exit status:

- Exit 0: the current branch belongs to a stack. Read [`stacked-pull-requests.md`](stacked-pull-requests.md).
- Exit 2: no local stack exists. Continue with a normal PR unless the user explicitly requested a stack.
- Command unavailable: for a requested stack, explain that the official `github/gh-stack` extension is required and get approval before installing it.
- Any other failure: read stderr and stop with the actionable error.

A stack request also uses [`stacked-pull-requests.md`](stacked-pull-requests.md). Its workflow replaces the remaining normal-PR steps; return its ordered PR URLs on completion. Normal PR publication continues below only when no stack workflow applies.

## 4. Validate the normal PR

Inspect committed, staged, unstaged, and untracked work:

```bash
git status --short
git diff --stat
git diff --cached --stat
git diff <base>...HEAD --stat
git log --oneline <base>..HEAD
```

Every change included in the PR must match the intent from step 1. If the work contains unrelated changes, stop and ask whether to include, split, or exclude them. Leave unrelated work untouched until the user decides.

If the unpushed branch name is meaningless or unrelated to the intent, propose a descriptive name and wait for confirmation before `git branch -m`. Skip renaming when `already_pushed` is true.

Commit only validated changes when needed. Write the commit message like the PR body: a subject line, a blank line, then one paragraph per line with no wrapping. Pass it with `git commit -F <path>`; a hard-wrapped message becomes permanent line breaks in published history. Push the current branch with upstream tracking:

```bash
git push -u origin <branch>
```

This step is complete when every published change matches the intent and the branch tracks its remote branch.

## 5. Write the PR

Use the user's intent for `Why?` and the actual diff for `How?`:

```markdown
### Why?

[The problem and reason stated by the user]

### How?

[The high-level approach in one or two sentences]
```

For a small, self-evident change, write one concise paragraph covering both instead of the template.

Include an implementation plan in a collapsed `<details>` block only when the current conversation identifies its file path. Paste the plan's Markdown without its local path. Do not search agent-specific plan directories.

Apply these body rules:

- Write the body with the `write` tool to a temporary file, one paragraph per line. Never pass the body inline in a shell command, and never wrap text at a terminal width; a wrapped line becomes a hard line break in the published PR.
- Omit file lists and test-plan sections.
- Add `### Decisions` only for trade-offs the user discussed.
- Add `### Risks` only for risks the user stated.
- Reference an issue only when verified from the user's words, the branch name, commits, or tracker output. Use `- Fixes #123` to close it and `- Refs #123` to link it.
- Reserve `#NUMBER` for intentional GitHub links; rephrase or escape other number signs.
- Keep customer and organization names, email addresses, support-ticket contents, and secrets out of the title and body whatever the repository visibility.

## 6. Create or update the normal PR

Check for an existing PR on the current branch:

```bash
gh pr view --json number,url 2>/dev/null
```

Write the body to a temporary file as required by step 5. Refresh an existing PR's body when follow-up commits materially change the change's scope, approach, or risk; typo-only, formatting-only, and rename-only follow-ups leave the body alone. Base the refreshed body on the current full diff, not the sequence of revisions:

```bash
gh pr edit <number> --repo "<repo>" --body-file "<path>"
```

Otherwise create it with an explicit base and title:

```bash
gh pr create --repo "<repo>" --base "<base>" --title "<title>" --body-file "<path>"
```

Add `--draft` only when the user requested a draft. Completion means `gh` returns the PR URL.

## Output

Keep intermediate work silent. Output only:

- the intent question when intent is missing
- a decision question when a gate stops the workflow
- the public-repository warning and proposed publication content when confirmation is required
- the PR URL, or ordered stack of PR URLs, on success
- the actionable error when a command fails
