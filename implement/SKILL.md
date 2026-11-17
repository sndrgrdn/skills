---
name: implement
description: Implement agreed work: features, defect fixes, or behavior-preserving structure changes.
argument-hint: "What should be built?"
disable-model-invocation: true
---

Build and verify the work. Scale each step to the size of the change.

## 1. Ready the work

Start from the working document the user points at, when they have one.

- **No working document yet, and the work needs seams or slices.** Call the Skill tool with "plan" and finish it before editing.
- **Unaligned goal.** Call the Skill tool with "grill-me", then Call the Skill tool with "plan" when a working document is needed, before editing.
- **Defect.** Call the Skill tool with "diagnosing-bugs" first when cause is not yet evidenced. Edit only once the cause is evidenced or the remaining blocker is explicit.
- **Behavior-preserving structure change.** Capture current behavior before editing: tests, characterization, recorded outputs, or an equivalence harness. Typecheck alone does not establish behavior. Prefer an expand/migrate/contract sequence when the working document called for it.

## 2. Build

Take the next slice on the **frontier** (blockers done), or the whole change when there is a single slice. Call the Skill tool with "coding-standards" and run its working loop for that slice only. Keep application decisions and effect order visible. Observe through the named seams. Stop at the slice boundary; open the next frontier slice only after this one's checks have run.

## 3. Tighten

Call the Skill tool with "simplify" on the slice (or accumulated) diff while preserving behavior.

Call the Skill tool with "code-review". Fix what the review earned. Call the Skill tool with "simplify" again when the fixes or the diff still carry noise. Run a second code-review only when the first left material unresolved questions or large follow-up edits.

## 4. Next slice or prove

If frontier slices remain, return to step 2. When the slices are done, Call the Skill tool with "prove-it" against the done check and seams. Match evidence to the work: real commands and outputs always; screenshots or a short recording when the change is visual; whatever artifact makes the claim checkable when it is not.

Commit only when the user asks.
