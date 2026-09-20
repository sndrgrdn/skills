# Pull Request Title and Body

Write the body as a reviewer cover note, not a changelog or validation log. Lead with changed behavior and affected surfaces, then include only what reduces the reviewer's reconstruction work.

## Title

State the delivered behavior in the repository's domain language. Prefer a direct present-tense phrase.

## Description structure

For a small, self-evident change, write one concise paragraph that covers the reason and approach. Otherwise start with:

```markdown
## Why

[The problem, reason, and intended outcome.]

## Change outline

[The changed behavior and implementation structure.]
```

When structure communicates faster than prose, load the `show-me` skill and use the smallest text visual that explains the change in `Change outline`. Introduce it with one sentence that tells the reviewer what to notice. Do not create or embed an HTML artifact in a PR body.

Optional sections:

```markdown
## Evidence

- [Focused regression result or observed behavior that materially improves confidence]
- [Screenshot or recording for a visual change]

## Review notes

- [Migration, compatibility constraint, deliberate omission, or surprising decision.]

## Merge risk

- **Reversibility:** Easy | Difficult
- **Blast radius:** [Concrete affected behavior, data, or consumers.]
```

Include `Evidence` only when an observed result proves the important behavior or changes the risk assessment. Prefer screenshots or recordings for visual changes and focused regression results for bugs. Omit routine validation that CI already reports. Never invent evidence.

Include `Review notes` only for facts that change how the PR should be reviewed or released. Omit it instead of writing `None`.

Include `Merge risk` when rollback is difficult or the impact is not obvious from the outline. Describe the actual affected area rather than assigning a generic risk level.

## Title and body constraints

- Include an implementation plan in a collapsed `<details>` block only when the current conversation identifies its file path. Paste the plan's Markdown without its local path. Do not search agent-specific plan directories.
- Reference an issue only when verified from the user's words, the branch name, commits, or tracker output. Use `- Fixes #123` to close it and `- Refs #123` to link it.
- Reserve `#NUMBER` for intentional GitHub links. Rephrase or escape other number signs.
- Omit file lists and generic test plans.
- Keep private customer data, organization data, email addresses, support-ticket contents, internal identifiers, and secrets out of the title and body regardless of repository visibility.
