# Persistence and operations

## Persistence ownership

Design persistence boundaries around cohesive domain capabilities. Keep table layout, queries, schema details, raw records, and ORM mechanics private to their owner.

Select a persisted representation from version, discriminator, or storage authority before decoding it. Malformed current data does not become legacy data through fallback parsing. Translate identified legacy representations explicitly and re-establish remaining domain invariants.

Validate migrations and imports before committing writes. Preserve invalid source evidence for diagnosis. Treat a code name, physical resource identity, and persisted-state contract as separate concerns.

## Independent lifecycles

Persisted data with its own creation cadence, mutation rules, write ownership, retention, cleanup, or deletion schedule has evidence of an independent lifecycle. Give it a named owner rather than attaching it to a convenient host record whose lifecycle differs.

A dedicated cleanup job or retention policy is a strong signal that the data may deserve its own persisted concept. Keep data with its host when their lifecycles genuinely match.

## Transactions and durable coordination

Use:

- an ordinary call when no atomic state change is required;
- a database transaction when changes in one datastore must commit or roll back together; and
- a durable workflow or saga when progress must survive process loss, long delays, redelivery, compensation, approval, or multiple commit boundaries.

Close database transactions before network calls or long-running work. Record durable intent when external work must reliably follow a committed state change.

## Duplicate execution and retries

Define an idempotency strategy for every real duplicate-execution path. Put the strategy at the layer that owns duplication. Valid strategies include stable request keys, natural uniqueness constraints, deduplication records, guarded state transitions, transactional outboxes, and transactional inboxes.

Place retry policy at the boundary that understands the failure and can prove repeated execution is safe. Avoid nested retries owned by several layers.

Define each repeated operation's behavior after success, expected failure, defect, interruption, retry exhaustion, and individual item failure. An intentionally permanent worker still has an explicit continuation and termination policy.

Match retry timing to the failure. Bound attempts or elapsed time, add jitter when synchronized callers can amplify failure, and honor provider retry guidance. Preserve the final classified failure unless a truthful fallback handles it.

## Uncertain outcomes

A timeout or lost response from a remote mutation does not prove that the mutation failed. Preserve request identity, receipts, checkpoints, and recovery intent when they are required to reconcile, retry, or compensate safely. Define the operation's point of no return.

## Completion check

Persistence mechanics remain private to a cohesive capability. Representation authority is explicit, independently living data has its own owner, migrations commit only validated state, and transaction scope contains only atomic database work. Every duplicate path, retry, repeated operation, and uncertain remote mutation has an explicit owner and safety policy.
