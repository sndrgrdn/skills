# Code structure and tooling

## Names and operation inputs

Name parsing, construction, predicates, and assertions according to what they do:

- parsing converts an external or less-trusted representation into a meaningful value;
- construction creates a value from meaningful parts and establishes its invariants;
- a predicate answers a question; and
- an assertion stops normal execution when a required condition is false.

Use booleans for predicates and genuinely independent choices. Give behavior-selecting inputs named policies or domain values.

Keep the primary input obvious and name additional policy choices. Add an option only when a real caller requires that behavior.

Name capabilities by what they provide, not by the consumer that currently uses them. Put use-case specificity in operation names. Use architecture suffixes only when they express the capability's established meaning.

## Public structure and files

Reference abstractions through their owning modules or intentional package, gem, or subsystem entrypoints. Aggregation layers represent deliberate public APIs rather than import convenience.

Expose only what intended callers should use. Review consumers and compatibility before changing a public contract, including consumers outside the current repository when the code is published.

Organize files around cohesive, searchable subjects rather than arbitrary size limits. Keep private helpers beside their owner, split unrelated concepts, and move a helper when its meaning becomes genuinely generic and stable.

## Comments

Keep comments short and accurate. Comment only where code cannot show intent, ownership, invariants, trade-offs, or caller-visible contracts. Delete narration.

Use durable domain vocabulary that readers can search for. Keep temporary planning, ticket, migration-phase, and internal storage terminology out of public language.

## Dependencies and enforcement

Select dependency APIs from the project's pinned version and version-matched source or documentation. Do not infer API availability or behavior from memory or current upstream material alone.

Make enforcement claims only when active tooling can prove them. Inspect the actual configuration, command graph, checked paths, plugin entrypoints, and available semantic information. Distinguish installed rules from proposals.

Treat a passing check as evidence only for what its configuration and implementation inspect. Avoid automatic fixes when correctness requires domain, provenance, or public-contract decisions.

Keep rule catalogs and numeric thresholds in configuration rather than duplicating them in prose.

## Completion check

Names expose actual behavior and ownership, inputs expose caller-selected policy, files remain cohesive and searchable, and public surfaces contain only intentional contracts. Comments add information unavailable from code. Dependency and enforcement claims cite the active version, configuration, and evidence source.
