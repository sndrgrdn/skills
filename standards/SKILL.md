---
name: standards
description: Build software correct by construction. Use when designing, implementing, or refactoring domain models, services, integrations, persistence, configuration, resources, failures, security, observability, operational workflows, or tests.
---

# Engineering standards

Build correct by construction. Parse data into meaningful representations, make expected failures explicit, assign behavior and effects to clear owners, and keep application policy visible.

## Define behavior before implementation

1. Read the nearest repository instructions, configuration, architecture decisions, and conventions.

   **Complete when:** the applicable local rules and each relevant runtime and dependency version are identified from repository evidence.

2. State the change's purpose and the material factual premises behind its proposed shape. Verify those premises against repository, runtime, data, or pinned-dependency evidence. An author's explanation establishes intent, not truth.

   **Complete when:** every material premise is supported, disproved, or explicitly unknown, and the proposed shape does not depend silently on a false premise.

3. Trace the caller-visible operation from each input through its decisions, effects, failures, state transitions, and output. Classify each concern as domain behavior, application policy, technology mechanics, or composition and resource wiring.

   **Complete when:** every changed input, output, failure, dependency, effect, and state transition has an identified role and owner.

4. Apply Design by Contract before choosing the implementation. Define the public input and preconditions, output and postconditions, expected failures, invariants and guarantees, and relevant effects. Read every applicable reference completely:

   - [`references/correctness-and-data.md`](references/correctness-and-data.md) when parsing data, changing schemas or domain models, representing state or optionality, or using an unchecked operation.
   - [`references/failures.md`](references/failures.md) when behavior can fail, absence may be ordinary, or an external response must be classified or translated.
   - [`references/ownership-and-design.md`](references/ownership-and-design.md) when changing services, interactors, modules, dependencies, effect order, abstractions, complexity, or behavior across system boundaries.
   - [`references/configuration-and-resources.md`](references/configuration-and-resources.md) when reading configuration, acquiring resources, performing startup work, using time or randomness, or touching global state.
   - [`references/persistence-and-operations.md`](references/persistence-and-operations.md) when reading or writing persisted data, changing transactions or migrations, calling remote mutations, retrying work, or coordinating durable operations.
   - [`references/security-and-observability.md`](references/security-and-observability.md) when handling personal data, secrets, authentication, authorization, logs, traces, metrics, or error reporting.
   - [`references/testing.md`](references/testing.md) when behavior, public inference, tests, or test implementations change.
   - [`references/code-structure-and-tooling.md`](references/code-structure-and-tooling.md) when changing names, operation inputs, files, imports, exports, comments, compiler settings, lint policy, or dependency APIs.

   **Complete when:** the caller-facing contract is explicit and every applicable reference rule is satisfied or has a narrow, evidence-backed exception.

5. Implement the complete changed behavior while keeping the change scoped to its stated purpose. Keep necessary supporting work with the behavior that requires it, and separate unrelated improvements into their own changes.

   **Complete when:** every traced path is implemented through its owning interface, expected failures remain explicit, external representations stop at their boundaries, application policy remains visible, and every changed hunk traces to the stated purpose.

## Completion criterion

Complete when every relevant changed input, output, failure, dependency, effect, state transition, external representation, and resource has an intentional contract and owner; each new abstraction passes the deletion test and YAGNI; every changed hunk traces to the stated purpose; and every applicable exception is narrow and supported by concrete evidence.
