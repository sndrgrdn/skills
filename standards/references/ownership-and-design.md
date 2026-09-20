# Ownership and design

## Deep modules

A module is anything with an interface and an implementation, including a function, class, interactor, package, or larger slice. Its interface is everything a caller must know to use it correctly: inputs, outputs, invariants, ordering, failures, configuration, and relevant performance characteristics.

Prefer deep modules. A deep module gives callers substantial behavior through a small interface. Depth creates leverage for callers and keeps implementation knowledge local for maintainers.

When shaping an interface, ask whether it can expose fewer operations, accept simpler inputs, or hide more policy and mechanics without concealing caller-relevant behavior.

## Meaningful boundaries

Start a meaningful service from an explicit caller-facing interface. In languages without formal interfaces, use an intentional public protocol. Keep framework, provider, and storage details private unless callers need them.

A service boundary earns its place through a meaningful capability or cohesive operation, whether pure or effectful. Pure domain behavior may be owned by a service, class, interactor, module, function, or value when that form gives the capability a cohesive owner.

Prefer composition, a functional core, and an imperative shell. The functional core owns deterministic decisions and transformations. The imperative shell obtains runtime information, coordinates effects, and makes their order visible.

## Responsibility and dependencies

Give each domain rule, application policy, technology mechanism, and composition concern one clear owner.

Make dependencies that affect behavior explicit, including persistence, external services, configuration, time, randomness, identity generation, authorization evidence, and telemetry. Provide each dependency at the boundary matching its lifetime and meaning. Keep request-specific state out of long-lived services.

The owner of an application operation makes its decisions, effect order, and expected early exits visible. Give cross-cutting behavior such as logging, tracing, retries, timeouts, cleanup, metrics, and error translation a clear owner without requiring one implementation shape.

## Earn abstractions

Apply YAGNI. Build the smallest coherent solution for current requirements. Introduce flexibility, abstractions, dependencies, and operational machinery only when a current need earns them.

Prefer the repository's paved road. Before introducing machinery, identify the capability it provides and inspect established mechanisms for the same capability in the same execution context. Extend the established mechanism when it fits. Parallel machinery is an intentional architectural choice with continuing lifecycle, failure, deployment, and observability costs.

Apply the deletion test. An abstraction earns its place when removing it would spread meaningful complexity, coupling, policy, or provider mechanics into callers.

Keep a concrete dependency private until a separate abstraction hides meaningful mechanics, serves multiple owners, or supports real implementation variation. Avoid wrappers that only rename and forward another operation.

Expose only what intended callers should use. Treat the public surface as a compatibility boundary.

## Cohesive refactoring

Treat complexity metrics as investigation signals, not design targets.

Refactor by assigning a calculation, policy, translation, persistence operation, or effect to a clear owner. Preserve visible control flow, data flow, domain decisions, and effect order in the coordinating operation.

Give extracted behavior explicit inputs and outputs. Methods that communicate through shared mutable instance state redistribute complexity rather than reduce it. Evaluate reasoning burden at both definition and call sites. Report a remaining metric conflict instead of mechanically partitioning cohesive behavior.

## Completion check

Every changed responsibility and dependency has one owner. Modules provide useful depth, application policy and effect order remain visible, and public interfaces expose caller-relevant concepts. New machinery follows the paved road or has a current need that justifies its separate cost, each abstraction passes YAGNI and the deletion test, and refactoring reduces reasoning burden across both definitions and callers.
