---
name: code-review
description: Review code for correctness and unnecessary complexity. Use when the user asks to review a diff, branch, pull request, working-tree changes, or selected code.
---

Review thoroughly within the requested scope. Find defects and simpler designs that preserve the required behavior. Diagnose and report; leave files unchanged unless the user requests edits.

## Review procedure

1. **Establish scope and purpose.** Resolve the requested files or comparison, including staged, unstaged, and untracked work when requested. Read the applicable repository instructions, requirements, and decisions. Ask when ambiguity changes the review target or required behavior; distinguish missing evidence from inferred intent.

2. **Understand the change.** Read every changed part in scope and the surrounding callers, implementations, and tests needed to understand it. Trace caller-visible behavior, guarantees, state transitions, failures, and effects. Verify material premises rather than treating the author's explanation as proof.

3. **Apply relevant principles.** Use the index below to select and read the applicable standards references completely. Apply their engineering rules to the reviewed work, not their implementation workflow. Documented repository requirements override these defaults. Investigate both broken behavior and unnecessary complexity; preserve justified boundaries and real case distinctions.

4. **Substantiate findings.** Trace each concern to a reachable failure, a concrete maintenance burden, or a violated applicable requirement. Look for counterevidence in contracts, callers, constraints, and existing mechanisms. For a simplification, show what becomes easier and account for the behavior, invariants, compatibility, and costs it must preserve. Run relevant existing checks or a focused, non-mutating reproduction when useful and safe. State what the evidence establishes and what remains unknown.

5. **Report.** Prioritize findings by consequence, consolidate shared root causes, and suggest the smallest useful remedy. Attribute findings to the reviewed work; inspect unchanged context without turning unrelated debt into findings. Separate unresolved material questions from confirmed issues. State the reviewed scope, checks, and limitations. If no supported issues remain, say **no findings**.

## Principles

The engineering rules live in the shared standards references. Activate a principle when the reviewed work touches its subject:

- **Ownership and simplicity:** [ownership and design](../standards/references/ownership-and-design.md) for modules, dependencies, interfaces, abstractions, branching complexity, or responsibility changes. Assess reader load, information hiding, current need, and simpler equivalent designs.
- **Meaningful representations:** [correctness and data](../standards/references/correctness-and-data.md) for input parsing, schemas, state, optionality, contracts, or unchecked operations.
- **Explicit failures:** [failures](../standards/references/failures.md) for changed failure modes, recovery, absence, or dependency-error translation.
- **Owned lifetimes:** [configuration and resources](../standards/references/configuration-and-resources.md) for configuration, startup, resources, asynchronous tasks, time, randomness, or ambient state.
- **Durable operations:** [persistence and operations](../standards/references/persistence-and-operations.md) for storage, migrations, retention, transactions, remote mutations, retries, or duplicate execution.
- **Safe boundaries:** [security and observability](../standards/references/security-and-observability.md) for sensitive data, authentication, authorization, or diagnostics.
- **Behavioral evidence:** [testing](../standards/references/testing.md) for changed behavior, tests, or public type inference. Examine whether the tests would detect the relevant regression, not merely whether they pass.
- **Clear public surfaces:** [code structure and tooling](../standards/references/code-structure-and-tooling.md) for names, operation inputs, exports, file organization, comments, dependency APIs, or tooling claims.

A pattern is an investigation signal, not a verdict. Establish what is wrong here before prescribing a different structure. Omit preference-only findings and checks already covered by verified active tooling.

## Finding format

For each finding, give:

- **Location and problem:** the smallest useful code location and a direct description.
- **Consequence and evidence:** the affected behavior or maintenance burden, the relevant path or contract, and a reproduction or rule citation when applicable.
- **Remedy:** a proportionate correction or concrete simplification direction.

Distinguish required corrections from non-blocking improvements. No finding quota applies.

## Completion criterion

Every changed part in scope has been inspected, relevant principles applied, and candidate findings supported or discarded. Report blocked investigations explicitly; do not present incomplete coverage as a clean review.
