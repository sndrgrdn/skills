---
name: pr-description
description: Write concise, evidence-backed PR descriptions. Use when creating a PR or writing or updating its title and body.
---

Make the change cheap to understand and verify. Gather evidence thoroughly; publish only what matters.

## Understand and demonstrate

Read the actual PR diff and enough surrounding code to establish the problem, changed behavior, and consequential decisions.

For each material behavioral claim, gather a focused observation that demonstrates the outcome. Prefer the same reproduction before and after the change. Quantify meaningful outcomes: duration, queries, bytes, retries, or affected cases, rather than counts of passing tests.

Use comparable workloads and conditions; record enough setup and sample information to interpret or reproduce measurements. Keep claims within what the observations establish, and state material evidence gaps.

## Write the body

Use this template. Omit `Review notes` when there is nothing consequential to flag.

```markdown
## Summary

[Problem and delivered behavior, in a few sentences or one small visual.]

## Evidence

[Strongest observed results, preferably before → after, with enough context to interpret them. Link supporting detail. State material evidence gaps.]

## Review notes

[Consequential trade-offs, compatibility or rollout concerns, and remaining uncertainty that needs reviewer attention.]
```

When a small visual explains the change faster than prose, use the `show-me` skill to produce the smallest GitHub-renderable view. An explanatory visual shows the mechanism; execution evidence demonstrates the outcome. For visual changes, prefer comparable screenshots or a short recording.

Scale the content to the change. For a small PR, one summary sentence and one evidence bullet can be enough. Use the repository's domain language and include only information the reviewer needs beyond the diff and CI.

Write a direct title naming the delivered behavior.

## Finish

Every line must explain the change, substantiate a claim, or direct review. Cut repetition and supporting detail that belongs behind a link. The body is ready when material claims have evidence or an explicit limitation, and the reviewer can identify what still needs judgment without reconstructing the change from the diff.
