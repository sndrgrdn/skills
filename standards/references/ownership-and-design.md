# Ownership and design

## Deep modules

A module is anything with an interface and an implementation, including a function, class, interactor, package, or subsystem. Its interface is everything a caller must know to use it correctly: inputs, outputs, invariants, ordering, failures, configuration, and relevant performance characteristics.

Apply information hiding. Keep each design decision behind the interface of its owner. Treat the same design knowledge appearing across modules as evidence of information leakage, then place it behind one owner unless the meanings differ.

Prefer deep modules. A deep module gives callers substantial behavior through a small interface. Depth creates leverage for callers and keeps implementation knowledge local for maintainers.

Push complexity down into the module that owns it when doing so simplifies callers without concealing caller-relevant behavior. When shaping an interface, ask whether it can expose fewer operations, accept simpler inputs, or hide more policy and mechanics under that constraint.

## Service boundaries

Define a service boundary through an explicit caller-facing interface. In languages without formal interfaces, use an intentional public protocol. Keep framework, provider, and storage details private unless callers need them.

A service boundary earns its place through a meaningful capability or cohesive operation, whether pure or effectful. Pure domain behavior may be owned by a service, class, interactor, module, function, or value when that form gives the capability a cohesive owner.

Prefer composition, a functional core, and an imperative shell. The functional core owns deterministic decisions and transformations. The imperative shell obtains runtime information, coordinates effects, and makes their order visible.

## Responsibility ownership and dependencies

Give each domain rule, application policy, technology mechanism, and composition concern one clear owner.

Make dependencies that affect behavior explicit, including persistence, external services, configuration, time, randomness, identity generation, authorization evidence, and telemetry. Provide each dependency at the boundary matching its lifetime and meaning. Keep request-specific state out of long-lived services.

The owner of an application operation makes its decisions, effect order, and expected early exits visible. Give cross-cutting behavior such as logging, tracing, retries, timeouts, cleanup, metrics, and error translation a clear owner without requiring one implementation shape.

## Mistake-proofing

When correcting an observed defect, identify the condition that made the failure possible. Where practical, remove that condition at the narrowest owner shared by all demonstrated recurrence paths.

Prefer the smallest enforceable mechanism:

1. an existing domain representation or invariant;
2. a narrower API or workflow;
3. a storage or configuration constraint;
4. existing compiler, static-analysis, or CI enforcement; or
5. detection through an existing test seam when prevention is not practical.

Prevent the demonstrated failure class, not hypothetical variants. New abstractions, tooling, and operational mechanisms must still satisfy YAGNI and the deletion test.

## Abstraction requirements

Apply YAGNI. Build the smallest coherent solution for current requirements. Introduce flexibility, abstractions, dependencies, and operational mechanisms only when a current need earns them.

Prefer established repository mechanisms. Before introducing a mechanism, identify the capability it provides and inspect established mechanisms for the same capability in the same execution context. Extend the established mechanism when it fits. A parallel mechanism is an intentional architectural choice with continuing lifecycle, failure, deployment, and observability costs.

Apply the deletion test. An abstraction earns its place when removing it would spread meaningful complexity, coupling, policy, or provider mechanics into callers.

Keep a concrete dependency private until a separate abstraction hides meaningful mechanics, serves multiple owners, or supports real implementation variation. Avoid wrappers that only rename and forward another operation.

## End-to-end implementation

When a change crosses system boundaries or depends on an unproven architectural path, begin with a tracer bullet: the smallest end-to-end implementation through the real boundaries that produces an observable result and can evolve into the final implementation. Use it to test architectural assumptions before expanding the implementation.

Extend the system through vertical slices. Each slice completes one caller-visible behavior across every required component. Avoid horizontal layer batches that postpone integration evidence.

Use a throwaway prototype instead when the code exists only to answer a design question.

## Cohesive refactoring

Treat complexity metrics as investigation signals, not design targets.

Refactor by assigning a calculation, policy, translation, persistence operation, or effect to a clear owner. Preserve visible control flow, data flow, domain decisions, and effect order in the coordinating operation.

Give extracted behavior explicit inputs and outputs. Methods that communicate through shared mutable instance state redistribute complexity rather than reduce it. Evaluate reasoning burden at both definition and call sites. Report a remaining metric conflict instead of mechanically partitioning cohesive behavior.

## Completion criterion

Every changed responsibility and dependency has one owner. Modules provide useful depth, application policy and effect order remain visible, and public interfaces expose caller-relevant concepts. For each corrected defect, the enabling condition is removed at its owner where practical, or the remaining recurrence path is explicit. Each new mechanism extends an established repository mechanism when one fits or has a current need that justifies its separate cost, and each abstraction passes YAGNI and the deletion test. Each unproven cross-boundary path has an observable tracer bullet before expansion, each vertical slice completes caller-visible behavior, and refactoring reduces reasoning burden across both definitions and callers.
