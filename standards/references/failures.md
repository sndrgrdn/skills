# Failures

## Expected failures and defects

Expected failures are values. Defects may throw or panic.

An expected failure is part of normal operation, such as rejected input, denied authorization, unavailable required data, a declined payment, or a classified dependency failure. Make it part of the operation's public contract so callers handle or propagate it deliberately.

A defect means correct execution is impossible because an internal invariant or programming assumption is broken. Do not turn defects into plausible business failures.

## Preserve meaning

Preserve an expected failure until the boundary that can render it as a valid protocol, interface, or operational outcome. Domain behavior does not choose HTTP status codes, and transport code does not erase domain meaning before rendering it.

Give failure modes distinct identities when callers handle them differently or they require different recovery, security, or diagnostic behavior. Combine them when the distinction has no caller value and useful context remains available.

A failure carries:

- a stable identity;
- safe structured context;
- an actionable message when recovery is possible; and
- the original cause when it is useful and safe.

Classify failures by identity and fields rather than matching message text.

## Boundary translation

Translate transport, provider, storage, and framework failures at the boundary that owns the dependency. Preserve already-correct application failures and retain useful causes safely.

Classify an HTTP response by status before decoding it as a successful representation. Otherwise a valid error response can be misreported as a malformed success response.

Treat a timeout, interruption, or missing response from a remote mutation as uncertainty, not proof that the mutation failed. Reconcile or retry only from actual evidence about the remote outcome and idempotency guarantee.

## Completion check

Every expected failure has an intentional identity and public path. Defects remain distinct. Translation occurs at the boundary that understands the source and target meanings, diagnostics retain safe context, and uncertain remote outcomes are not misclassified as known failures.
