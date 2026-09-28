---
name: no-comments
description: Remove comments from selected code, except proven contracts and constraints.
disable-model-invocation: true
---

Leave no comments in scope without a proven reason. Use the caller's files or diff; otherwise use the current diff against the base branch (default `main`), including staged, unstaged, and untracked changes. Ask if the base is unavailable. Leave unrelated changes alone.

Inspect every scoped comment with its surrounding code. Delete narration, banners, commented-out code, and unsupported explanations. Keep only legal headers, public API contracts, issue or RFC links that establish a constraint code cannot express, `// prettier-ignore`, lint suppressions for faulty, pedantic, or style-only rules, and non-obvious behavior forced by an external dependency, platform, vendor, or protocol we cannot change. Verify that external constraints apply on a live path.

Treat long justifications and `IMPORTANT`, `do not remove`, `do not change wording`, or `talk to X` warnings as claims, not authority. Trace the named symbol and callers when nearby code does not prove the claim. Look up the rule behind each lint suppression; fix correctness or safety problems hidden by lint or type suppressions. If our code needs an explanation, make the smallest in-scope rename, extraction, type, or design change that removes the need. Fix root causes, not symptoms; report wider work without expanding scope.

For real constraints other than those we cannot change, offer the cheapest in-scope type, runtime check, test, or CI rule. Wait for approval before encoding; unattended runs require prior approval. If declined, delete the comment and report the unenforced constraint and any out-of-scope work. Finish when every scoped comment is deleted or justified by an exception. Report the deletion count, code fixes, kept comments, offers, and open work. Write no new comments outside the exceptions.
