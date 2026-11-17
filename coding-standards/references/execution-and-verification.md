# Execution and verification

Apply the sections matching the current work. These rules govern investigation and execution; the domain, ownership, persistence, security, and testing references retain their contracts.

## Resolve uncertainty without routine handoffs

**Never Block on the Human.** Within the authorized goal, investigate observable facts and make reversible technical decisions using repository evidence. Ask only when the answer changes product intent, required compatibility, authorization, or a material trade-off that evidence cannot settle. Present the decision needed, your recommendation, and its consequence.

Prefer a command, source inspection, or minimal experiment when it can answer the question. Access to a tool is not permission to publish, send messages, mutate shared systems, deploy, delete data, or expand scope. Honor explicit checkpoints and the environment's authorization rules. When blocked on access or a consequential choice, report the blocker and continue independent, in-scope work where useful.

## Explore consequential designs

**Exhaust the Design Space.** When a novel interaction or unresolved ownership, state, or interface choice could materially change the implementation, compare at least two structurally different shapes. Begin with caller usage, a state model, or a small sketch. Use a throwaway prototype when runtime behavior or interaction feel decides; use a tracer bullet when the question is whether a real integration path works.

Compare contract fit, interface depth, locality, reader load, compatibility, and runtime and operational costs. Choose and proceed when evidence resolves a technical choice. Keep a user-requested design checkpoint. A familiar local change does not require a bakeoff, a new abstraction, or parallel agents.

## Correct defects and test premises

**Fix Root Causes.** Reproduce the wrong observable behavior before changing production code when practical. Trace it to the first broken contract or unhandled legitimate state. Instrument the actual path when evidence is missing.

A guard is correct when it handles a legitimate state owned by that location. When the state violates an established producer invariant, correct the producer rather than hiding its output. Inspect demonstrated recurrence paths and prevent the failure at their narrowest practical owner, following the ownership reference's mistake-proofing rules.

Use a failing regression test first when there is a reliable, proportionate path through a real interface. Confirm it fails for the intended reason, implement the fix, and rerun it. When that path is impractical, use the closest trustworthy reproduction or executable check and report the coverage gap. The testing reference still determines required coverage; an inconvenient harness does not silently waive it.

**Attack the Premise.** After two attempted fixes sharing an assumption fail the same gate, stop patching. Write their shared premise in one sentence. Find and run a check whose outcome would differ if it were false. Follow that evidence before another fix. Unsupported does not mean disproved, and repeated failure does not itself identify the cause.

## Refactor against established behavior

Before changing structure, establish the observable contract with existing tests, characterization, baseline outputs, or an equivalence check. Preserve required failures, effects, ordering, and compatibility as well as successful outputs. Static checks alone do not establish behavioral equivalence.

**Migrate Callers Then Delete Legacy APIs.** For internal contracts with no independent compatibility obligation, migrate all callers and remove the old surface and obsolete tests in the same coordinated change. Delete tests that only protect the old implementation shape. Preserve tests for behavior the new interface must still provide. Inspect published or separately deployed consumers before assuming callers can move together.

**Outcome-Oriented Execution.** For a planned migration, identify verification boundaries and any deliberately incomplete intermediate state. Keep temporary breakage local, recoverable, and outside deployed or shared baselines. Run relevant checks at each declared boundary and full applicable verification at completion. Prefer safe incremental delivery when deployment or compatibility requires it.

## Build leverage and control shared writes

**Build the Lever.** For error-prone sweeps, repeated transformations, or complex comparisons, prefer the smallest deterministic codemod, script, query, or verification harness that makes the work repeatable and reviewable. First establish a representative expected result, then check the tool against it. Reuse existing tooling when possible. A direct edit or existing command is enough when it is easier to verify than a new tool. Retain custom tooling when rerunning or auditing the work has continuing value.

**Separate Before Serializing Shared State.** Before concurrent execution, identify every shared mutable target. Give independent facts separate owners and write targets. If one canonical target is a real invariant, enforce coordination structurally with the appropriate transaction, lock, single writer, or atomic conditional operation. Instructions to avoid collisions are not synchronization. Respect resource scope, cancellation ownership, and retry safety in their owning references.

**Guard the Context Window.** Keep large payloads in inspectable artifacts and retrieve relevant portions. Maintain a compact record of the goal, decisions, current state, blockers, and next verification boundary when work spans phases. Delegate only when authorized and useful; specify bounded ownership, write scope, and acceptance checks. Review returned artifacts and verify relevant claims rather than forwarding a success summary.

## Explain measured results

**Explain the Number.** Before measuring, state the decision the number would change and the noise floor that would make the effect untrustworthy. Stop when run-to-run spread exceeds the claimed effect. Before using a measurement to choose or claim an improvement, state the claim and inspect what the harness measures. Confirm the intended work actually ran, outputs are correct, and errors or skipped work did not produce the result.

Compare equivalent workloads and relevant production-like settings. Identify the limiting resource or code path from runtime evidence; inspect the load generator as well as the system. Repeat and interleave comparisons to expose noise and drift. Report units, sample count, spread, relevant settings, and evidence for the limiter. Check physical plausibility and end-to-end relevance before extrapolating a microbenchmark.

An explicitly requested ballpark may use a single run labeled as such, but still requires correct output and evidence that the work ran. Label close, confounded, or unexplained comparisons inconclusive rather than selecting a winner.

## Make recurring lessons enforceable

**Encode Lessons in Structure.** When a demonstrated mistake recurs, look first for an owning representation, interface, constraint, or existing enforcement path that prevents it. Add a focused regression when prevention is impractical. Change instructions only when the lesson requires judgment that the system cannot enforce. Keep the mechanism proportional to demonstrated recurrence and verify that it rejects the mistake without rejecting required behavior. When a structural check prevents the mistake, remove the duplicated admonition rather than keeping both.

