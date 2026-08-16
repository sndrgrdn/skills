---
name: checkout
description: Resolve a remote git repository reference (GitHub/GitLab/Bitbucket URL, git@..., or owner/repo shorthand) to a cached local path so you can read and search the code. Use when a remote repo is referenced and you'll need to look inside it.
---

Every remote repository you're asked to work with gets a stable local checkout at:

`~/.cache/checkouts/<host>/<org>/<repo>`

1. Run `bash scripts/checkout.sh <repo>` with the reference as given.
2. Use the printed path for all searching, reading, and analysis.
3. On later references to the same repo, run the script again; it refreshes the cache automatically.

The script clones on first use (partial clone, `--filter=blob:none`), then fetches and fast-forwards on a throttle. Pass `--force-update` for a fresh copy now; `--help` lists every flag. If a refresh fails (offline), it returns the cached copy anyway, possibly stale.

Don't edit inside the shared cache. Copy files out or create a worktree for task-specific changes.
