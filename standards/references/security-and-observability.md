# Security and observability

## Sensitive data

Treat personal data as private by default. Include only approved, minimal representations in logs, traces, metrics, error reports, and snapshots. Prefer opaque identifiers, operation names, dependency names, state tags, failure identities, retry counts, and bounded sanitized summaries.

Keep secrets out of diagnostics, jobs, URLs, headers, and automatic instrumentation. Limit raw access to operations that require it. Use the platform's established storage and filtering mechanisms, and use a redacted runtime representation when it provides useful additional protection.

Inspect framework and client instrumentation as well as application logging. Filtering an application field does not prove that outer HTTP spans, exception causes, request bodies, or redirect locations are safe.

## Observability

Use the repository's established logging, tracing, metrics, and error-reporting paths. Preserve safe operation, dependency, state, failure, retry, and correlation context across relevant requests, jobs, workflows, and external calls.

Place instrumentation at the boundary that understands the operation. Verify the emitted diagnostic representation rather than assuming a logging call or inner filter controls every reporter.

## Authentication and authorization

Separate these responsibilities:

- Boundary code verifies credentials and establishes a parsed actor, principal, or session.
- Domain policy defines permission decisions over meaningful values.
- Application behavior gathers context, enforces the decision, and performs the operation.
- The outer boundary translates missing credentials and denied operations into protocol outcomes.

Do not treat parameter filtering as authorization.

## Completion check

Every diagnostic field is safe and necessary, secrets remain outside observable outputs, established telemetry remains connected, and correlation context crosses relevant boundaries. Credential verification, permission policy, enforcement, and protocol translation each have an explicit owner.
