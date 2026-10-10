---
name: checkout
description: Resolve a remote git repository reference (GitHub/GitLab/Bitbucket URL, git@..., or owner/repo shorthand) to a cached local path so you can read and search the code. Use when a remote repo is referenced and you'll need to look inside it.
---

Every remote repository you're asked to work with gets a stable local checkout at:

`~/.cache/checkouts/<host>/<org>/<repo>`

1. Resolve `scripts/checkout.sh` relative to this SKILL.md, then run `bash <absolute-script-path> <repo>` with the reference as given.
2. Use the printed path for all searching, reading, and analysis. The step is complete when that path is available.
3. On later references to the same repo, run the script again; it checks for updates on a throttle.

The script clones on first use (shallow partial clone, `--depth=1 --filter=blob:none`), then fetches and attempts a fast-forward. Pass `--force-update` to fetch now, even during the throttle interval. For work that needs current code, use `--status` and check `update` and `fast_forward` before relying on the checkout; report a failed fetch or skipped fast-forward. If a refresh fails (offline), the cached copy remains available, possibly stale.

Don't edit inside the shared cache. Copy files out or create a worktree for task-specific changes.
