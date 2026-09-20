---
name: to-pr
description: Prepare or publish reviewable GitHub pull requests. Use when composing a PR title or body, creating or updating a PR, or publishing a PR stack.
---

# To Pull Request

Keep intent, validation, confirmation, commit, push, and PR publication in the main session.

## 1. Select the operation

Infer the smallest operation authorized by the user:

- **Compose:** Write a proposed title and body. Do not commit, push, create, or update a PR.
- **Update:** Update an existing PR's title or body. Do not commit or push unless the user also requested those actions.
- **Publish:** Validate and commit changes that match the confirmed intent, push the current branch, and create its PR. A request to create a PR authorizes this push.
- **Publish stack:** Publish or update the requested PR stack.

An explicit invocation of `to-pr` with no narrower instruction means create or update the PR for the current branch. An earlier instruction to wait, not push, or not publish remains a hard stop until the user explicitly withdraws it.

## 2. Establish intent

Find these facts in the conversation and any issue, plan, or task artifact that the user supplied:

- the problem this change solves
- why the change is needed

If either fact is missing, ask:

> Before preparing this PR, I need to understand its intent.
>
> What problem does this solve, and why is the change needed?

Continue when the PR's reason can be stated without guesswork.

## 3. Resolve repository and pull request state

For publication, resolve `scripts/resolve-pr-context.sh` relative to this `SKILL.md`, then run it once from the target repository:

```bash
bash "<skill-directory>/scripts/resolve-pr-context.sh"
```

Retain and reuse its `repository`, `visibility`, `current_branch`, `remote_branch_exists`, and `default_branch` values. Pass `--repo "<repository>"` explicitly on every `gh pr` command. Stop when `repository` or `current_branch` is empty, or when `visibility` is `UNKNOWN`, because the publication target or safety policy cannot be selected. When `visibility` is `PUBLIC`, read [`public-repository.md`](public-repository.md) and apply every gate it defines.

Use the existing PR's base when updating it. For a new PR, use `default_branch` unless the user named another base. Ask when the intended base is unclear.

For publish or update operations, run `gh stack view --json` and branch on its exit status:

- Exit 0: the current branch belongs to a stack. Read [`stacked-pull-requests.md`](stacked-pull-requests.md).
- Exit 2: no local stack exists. Read [`stacked-pull-requests.md`](stacked-pull-requests.md) for a requested stack; otherwise continue with a single PR.
- Command unavailable: continue with a single PR when no stack was requested. For a requested stack, explain that the official `github/gh-stack` extension is required and get approval before installing it.
- Any other failure: report the actionable error and stop.

The stack workflow replaces the remaining single-PR publication steps.

## 4. Inspect and validate the change

Read committed, staged, unstaged, and untracked work, not only summary statistics:

```bash
git status --short
git diff
git diff --cached
git diff <base_branch>...HEAD
git log --oneline <base_branch>..HEAD
```

For an update that does not include a push, use the published PR as the body source of truth:

```bash
gh pr diff <number> --repo "<repository>"
```

Do not describe unpushed commits or worktree changes as part of that PR. Read surrounding code and supplied task artifacts until every changed behavior and its owning module can be explained. Every change included in the PR must match the intent. If the work contains unrelated changes, stop and ask whether to include, split, or exclude them. Leave unrelated work untouched until the user decides.

For single-PR publication:

- When `current_branch` equals the base branch, propose a descriptive feature branch and wait for confirmation before creating it.
- When the remote branch does not exist and the current branch name does not describe the confirmed intent, propose a descriptive rename and wait for confirmation.
- Leave the current branch name unchanged when `remote_branch_exists` is true.

Commit only validated changes when publication needs a commit. Write the commit message as a subject, a blank line, then one paragraph per unwrapped line. Pass it with `git commit -F <path>`. Push with upstream tracking:

```bash
git push -u origin <current_branch>
```

This step is complete when every included diff hunk matches the intent and every commit selected for publication is on the remote branch.

## 5. Write the title and body

Read [`pull-request-description.md`](pull-request-description.md) and apply every rule in it. Base the title and body on the intent and the authoritative diff selected in step 4, not the sequence of revisions.

For publication, write the body to a temporary file with the `write` tool, one paragraph per line. Do not pass the body inline to a shell command and do not wrap it at terminal width.

For a compose operation, return the proposed title and body without publishing them. Save them only when the user requested a file.

## 6. Create or update the single PR

Check for an existing PR on the current branch:

```bash
gh pr view --json number,url,title,baseRefName,headRefName 2>/dev/null
```

Update an existing PR when requested, or when an explicit `to-pr` invocation finds one:

```bash
gh pr edit <number> --repo "<repository>" --title "<title>" --body-file "<path>"
```

Create a missing PR only for a publish operation:

```bash
gh pr create --repo "<repository>" --base "<base_branch>" --title "<title>" --body-file "<path>"
```

Add `--draft` only when the user requested a draft PR. Completion means `gh` returns or confirms the PR URL.

## Output

Keep intermediate work silent. Output only:

- the intent question when intent is missing
- a decision question when a gate stops the workflow
- the public-repository warning and proposed publication content when confirmation is required
- the proposed title and body for a compose operation
- the PR URL, or ordered stack of PR URLs, after publication
- the actionable error when a command fails
