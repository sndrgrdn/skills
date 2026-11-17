---
name: no-comments
description: Remove comments from selected code, except proven contracts and constraints.
disable-model-invocation: true
---

Leave no comments in scope without a proven reason. Use the caller's files or diff; otherwise the current diff against the base branch (default `main`), including staged, unstaged, and untracked. Ask if the base is unavailable. Leave unrelated changes alone.

Delete narration, banners, commented-out code, and unsupported explanations. Keep only legal headers, public API contracts, issue or RFC links that state a constraint code cannot express, formatter or linter directives for faulty, pedantic, or style-only rules, and non-obvious behavior forced by an external dependency, platform, vendor, or protocol we cannot change. Verify those external constraints on a live path.

Treat long justifications and keep-or-else warnings as claims. Trace the named symbol and callers when nearby code does not prove the claim. Look up each suppression; fix correctness or safety problems it hides. Prefer the smallest in-scope rename, extraction, type, or design change that removes the need for an explanation. Fix root causes; report wider work without expanding scope.

For real constraints other than those we cannot change, offer the cheapest in-scope type, runtime check, test, or CI rule. Wait for approval before encoding; unattended runs need prior approval. If declined, delete the comment and report the unenforced constraint and any out-of-scope work. Finish when every scoped comment is deleted or justified. Report deletions, fixes, kept comments, offers, and open work. Add no comments outside the exceptions.
