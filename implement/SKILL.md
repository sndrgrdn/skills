---
name: implement
description: Implement agreed work: features, defect fixes, or behavior-preserving structure changes.
argument-hint: "What should be done?"
disable-model-invocation: true
---

Turn the user's goal into verified code. Engineering rules live in coding-standards; this skill is the **order of work**. Scale each step to the size of the change: a one-file edit may be a single slice with a short plan; a cross-seam change runs every step fully.

## 1. Ready the work

Start from the user's description and any working document they point at.

- **Unaligned goal.** Call the skill grill-me and finish it before editing. Land a shared understanding of what to build and what "done" looks like.
- **Defect.** Call the skill diagnosing-bugs first. Edit only once the cause is evidenced or the remaining blocker is explicit.
- **Behavior-preserving structure change.** Capture current behavior before editing: tests, characterization, recorded outputs, or an equivalence harness. Typecheck alone does not establish behavior.

When the plan needs a durable surface, write or update a working document the user names or agrees (`./tmp` if it exists, else the system temporary directory, or a path in the repo). Record the outcome, constraints, closed questions, and the slice list once you have one. No fixed template.

**Complete when:** the outcome, success check, and constraints are known; defect causes or structure baselines are in place when those branches apply; material unknowns are under investigation or reported as blockers.

## 2. Slice

When the work is large enough to thrash shared owners, split it into **vertical slices** with named **seams**. Each slice delivers one caller-visible cut across the stack. Agree order with the user when order matters. Small work stays one slice.

**Complete when:** the slice list and order are explicit (or the work is deliberately one slice).

## 3. Build

For the current slice only, Call the skill coding-standards and run its working loop. Keep application decisions and effect order visible. Stop at the seam; open the next slice only after this one's checks have run.

**Complete when:** the slice satisfies coding-standards' completion criteria and its relevant checks have been run.

## 4. Tighten

Call the skill simplify on the slice (or accumulated) diff while preserving behavior.

Call the skill code-review. Fix what the review earned. Call simplify again when the fixes or the diff still carry noise. Run a second code-review only when the first left material unresolved questions or large follow-up edits.

**Complete when:** review findings are absorbed or explicitly deferred with reason, and the diff is free of noise you would not want merged.

## 5. Next slice or prove

If slices remain, return to step 3. When the agreed slices are done, Call the skill prove-it. Match evidence to the work: real commands and outputs always; screenshots or a short recording when the change is visual; whatever artifact makes the claim checkable when it is not.

Commit only when the user asks.

**Complete when:** the success check from step 1 holds on the real surface, prove-it has shown what is verified and what remains unproven, and every changed hunk serves the outcome.
