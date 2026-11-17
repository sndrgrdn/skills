---
name: plan
description: Produce a seams-forward working document and slice graph for a piece of work.
argument-hint: "What are we planning?"
disable-model-invocation: true
---

Settle **where you observe** the outcome and **in what slices** you build it. Edit no product code here.

## 1. Confirm alignment

Start from the user's description and any grilling outcome already in the conversation. If the goal is still unaligned, Call the Skill tool with "grill-me" and finish it first.

## 2. Name the seams

**Seams** are where you observe behavior (the public boundary a check can hit). Prefer existing seams over new ones. Prefer the highest seam that still catches the behavior. Keep the seam count low; one is ideal when it covers the outcome.

For each seam, note whether it is existing or new, what it catches, and what it misses. Confirm the set with the user before treating it as settled.

Call the Skill tool with "show-me" for a seam map or call tree when prose would force the user to hold the shape in their head.

## 3. Cut the slices

Split the work into **vertical slices**: each cuts a narrow but complete path through every layer the change needs (not a horizontal batch of one layer). Each finished slice is demoable or verifiable on its own, and sized to one focused build pass.

Put prefactor that makes the change easy before feature slices. Give each slice its blockers so later work runs on the **frontier**: only slices whose blockers are done. Small work stays one slice.

Wide mechanical moves (one rename or retype whose blast radius spans the codebase) are the exception: sequence expand, then migrate in green batches, then contract, instead of forcing a fake tracer bullet.

Call the Skill tool with "show-me" for the slice graph. Present titles, blockers, and what each slice delivers; iterate until the user accepts granularity and edges.

## 4. Write the working document

Write or update the document at the path the user names or agrees. Default to `docs/plans/<slug>.md`, creating `docs/plans/` when needed. If the repo already keeps plans under another docs path, use that convention instead. Follow [WORKING-DOCUMENT.md](WORKING-DOCUMENT.md).

Return the document path to the user.
