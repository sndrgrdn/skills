# Stacked Pull Requests

Use this branch when the user requests stacked PRs or `gh stack view --json` shows that the current branch belongs to a local stack.

A stack is ordered from trunk through bottom to top. Each PR targets the branch immediately below it, so each diff contains one reviewable layer.

## 1. Confirm capability and scope

Run:

```bash
gh stack --version
gh stack view --json
```

If the extension is unavailable, get approval before installing the official extension with `gh extension install github/gh-stack`.

If the current work is not a stack, require at least two branches in an explicit bottom-to-top order. Verify that every named branch already exists before adopting it:

```bash
gh stack init --base "<trunk>" <bottom-branch> ... <top-branch>
```

Creating or rewriting branches to split one large change is a separate design task. Stop and agree the layer boundaries before changing history.

Show the stack order and identify every branch that the operation will push or publish. Continue when the user confirms that scope.

## 2. Establish intent per layer

Most sessions will not contain enough intent for every layer. Record:

- the overall problem and why the stack is needed
- the purpose of each layer

The overall intent can supply `Why?` across the stack. Each layer's actual diff supplies its own `How?`. Ask when a layer's purpose cannot be stated without guessing.

## 3. Validate every layer

Use `gh stack view --json` as the source of truth for trunk, branch order, current branch, and existing PRs. For each active layer, compare it with the branch immediately below it:

```bash
git diff <parent-branch>...<layer-branch> --stat
git log --oneline <parent-branch>..<layer-branch>
```

Also inspect `git status --short`, `git diff --stat`, and `git diff --cached --stat` for the checked-out branch. Every included change must belong to exactly one confirmed layer. Stop on unrelated work or unclear ownership. Commit validated work to its owning layer, then require a clean working tree before publication.

Check `needsRebase` for every layer in the stack JSON. If any layer needs a rebase, show the affected layers and get approval before `gh stack rebase`, because it rewrites branch history.

When the repository is public, apply [`public-repository.md`](public-repository.md) to every layer before push.

This step is complete when branch order, layer ownership, and all included changes match the confirmed stack intent, the working tree is clean, and no layer needs a rebase.

## 4. Prepare titles and bodies

Prepare one title and body per layer using the format and body rules in `SKILL.md`. List them bottom-to-top for review.

For public repositories, show the complete ordered set and obtain the confirmation required by `public-repository.md` before publication.

## 5. Push, create, and link

Use explicit remote arguments so agent execution does not depend on interactive remote selection:

```bash
gh stack push --remote origin
```

For each layer, bottom-to-top:

1. Use the existing PR from `gh stack view --json`, or query by head branch.
2. Write each body to its own temporary file with the `write` tool, one paragraph per line; see the body rules in `SKILL.md`.
3. Update an existing PR's title and body with `gh pr edit <number> --repo "<repo>" --title "<title>" --body-file "<path>"`.
4. Otherwise run `gh pr create --repo "<repo>" --head "<layer>" --base "<parent>" --title "<title>" --body-file "<path>"`.
5. Add `--draft` only when the user requested that layer as a draft.
6. Record the PR URL.

After every layer has a PR, link the PRs in bottom-to-top order:

```bash
gh stack link --base "<trunk>" --remote origin <bottom-pr-url> ... <top-pr-url>
```

Do not use bare `gh stack submit` in an agent session: it can open an interactive editor, while `--auto` publishes generated metadata before the prepared titles and bodies are applied.

Run `gh stack view --json` again. Completion means every intended layer has the correct parent PR, all PRs belong to one GitHub stack, and the output supplies every PR URL.

## Failure handling

- Exit 2 from `gh stack view --json`: the current branch is not in a local stack.
- Exit 3 from a stack operation: report the rebase conflict; continue only after the user chooses resolution or abort.
- Exit 9: stacked PRs are unavailable for this repository; report that limitation and offer a normal PR.
- Any other nonzero exit: report stderr and stop before further publication.
