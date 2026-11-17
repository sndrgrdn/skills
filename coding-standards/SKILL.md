---
name: coding-standards
description: Design and change code with clear ownership, meaningful data models, and verified behavior. Use for implementation, bug fixes, refactoring, architecture, integrations, persistence, configuration, resources, failures, security, observability, operational workflows, and tests.
---

Build correct by construction. Own the technical decisions within the requested goal: investigate facts, choose the design, implement it, and verify the result. Keep the user responsible for product intent and consequential authorization, not routine code placement.

## Working loop

Scale the work to uncertainty and impact. For a local, established change, make these decisions briefly and proceed; a separate plan or design document is unnecessary. For a new responsibility, changed public contract, persistent state, or cross-module policy, make the contract and owner explicit before editing. Surface consequential choices and uncertainty, not a recital of principles.

### 1. Establish the outcome

**Experience First.** State who consumes the behavior, what they should observe, and the check that will establish success. Include the maintainer's burden when changing structure. Distinguish a feature, a defect correction, and behavior-preserving refactoring.

Read repository instructions, relevant configuration, architecture decisions, callers, tests, and established implementations. Identify applicable runtime and dependency versions. Verify material factual premises against repository, runtime, data, or pinned-dependency evidence; an author's explanation establishes intent, not truth.

**Complete when:** the requested outcome, relevant constraints, baseline behavior, and verification path are known; material unknowns have an investigation or are reported as blockers.

### 2. Choose the shape and owner

**Foundational Thinking.** Trace the caller-visible operation through inputs, decisions, effects, expected failures, transitions, and outputs. Choose meaningful data and state representations before writing their logic.

**Model the Domain.** For each changed responsibility, identify whether it is domain behavior, application policy, technology mechanics, or composition and resource wiring. Inspect the existing owner and its callers before choosing a file. Put a rule with the domain knowledge and invariants it governs; put use-case decisions and effect order with the application operation; keep provider and storage mechanics with their dependency owner; keep construction and lifetimes with composition. Execution order alone does not define module ownership.

Sketch a real caller's usage and the input, output, failures, invariants, and effects of a new or materially changed interface. Extend an established owner when it fits. Introduce a new module when it owns cohesive knowledge or a distinct lifecycle and its interface hides meaningful complexity. Treat file proximity and similar syntax as clues, not ownership evidence.

**Redesign from First Principles.** Ask what shape would make the current requirement natural if it had existed from the start. Compare that shape with a local extension when the extension adds contradictory state, repeated rules, or knowledge leaking into callers. Choose the smallest coherent solution that preserves required behavior and compatibility. Explore alternatives only when a material design uncertainty could change that choice.

**Complete when:** every changed concern has an intentional owner, the caller-facing contract is explicit, and the chosen shape accounts for the complete operation without speculative flexibility.

### 3. Load the applicable contracts

Read every applicable reference completely. Existing instructions and safety constraints remain binding.

- [Correctness and data](references/correctness-and-data.md): parsing, schemas, models, state, optionality, unchecked operations.
- [Failures](references/failures.md): expected failures, absence, dependency responses, failure translation.
- [Ownership and design](references/ownership-and-design.md): modules, services, dependencies, effects, abstractions, complexity, cross-system behavior.
- [Configuration and resources](references/configuration-and-resources.md): configuration, startup, resources, asynchronous tasks, time, randomness, global state.
- [Persistence and operations](references/persistence-and-operations.md): stored data, migrations, transactions, remote mutations, retries, durable coordination.
- [Security and observability](references/security-and-observability.md): personal data, secrets, credentials, authorization, diagnostics.
- [Testing](references/testing.md): behavior, public inference, tests, test implementations.
- [Code structure and tooling](references/code-structure-and-tooling.md): names, inputs, files, public surfaces, comments, compiler and lint policy, dependency APIs.
- [Execution and verification](references/execution-and-verification.md): defects, refactoring, unresolved design alternatives, repeated failed attempts, multi-step migrations or sweeps, concurrency, measurements, delegated work, long-running work.

**Complete when:** applicable rules are satisfied by the design or have narrow, evidence-backed exceptions; an unverified premise cannot silently determine the implementation.

### 4. Make the smallest coherent change

**Laziness Protocol.** Consolidate decisions rather than repeating them. Prefer the smallest change that solves the complete problem, not the fewest edited lines at the expense of a correct owner.

**Subtract Before You Add.** Remove obsolete behavior and supporting references made unnecessary by this change. Reuse existing mechanisms before adding another. Keep unrelated cleanup separate.

**Minimize Reader Load.** Prefer deep modules, explicit data flow, and narrow mutable scope. Apply YAGNI and the deletion test to new abstractions. Judge a layer by what it hides, not its caller count, function size, or metric score.

**Sequence Work into Verifiable Units.** Complete one caller-visible slice and run its relevant checks before expanding. Establish a tracer bullet through unproven real boundaries first. Keep application decisions and effect order visible throughout.

**Complete when:** every traced path is implemented through its owner, supporting changes serve the stated purpose, obsolete paths are removed where compatibility permits, and each completed slice has direct verification evidence.

### 5. Prove it works

**Prove It Works.** Exercise the real public interface and inspect observable outcomes. Verify required failure paths, invariants, effects, and changed public inference using the applicable references. A passing typecheck or another agent's report proves only what it actually checks.

Review the whole diff against the outcome and chosen ownership. Check callers and obsolete references after moves or interface changes. Report what changed, consequential design choices, commands and results, and remaining uncertainty. Distinguish verified behavior from inference and checks not run.

**Complete when:** each changed contract has supporting evidence or a concrete reported verification blocker, every changed hunk serves the goal, and no known unmet requirement is represented as complete.
