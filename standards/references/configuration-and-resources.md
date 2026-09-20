# Configuration and resources

## Configuration

Read and parse configuration at startup or the earliest composition boundary, then pass meaningful values inward. Inner application and domain code does not repeatedly read and reinterpret raw environment values.

Apply defaults only to missing configuration. Reject malformed configuration. Define replacement, fallback, and precedence among configuration sources explicitly rather than relying on incidental load order.

Construct a dependency through its owning composition interface when that interface carries configuration, lifecycle, instrumentation, memoization, or wiring behavior. Bypassing the interface must not silently omit behavior.

## Lifecycles

Every acquired resource has a lifecycle owner and a matching release strategy, either locally or through an explicit framework lifecycle. Release resources after success and failure and when the runtime interrupts their scope.

Keep runtime-bound handles inside their valid request, transaction, thread, process, component, or invocation scope. A stable resource identity or cache key does not extend a live handle's validity.

Keep planning and construction separate from runtime execution. Acquire contextual resources only in the phase that owns them. Ensure required runtime resources are ready before exposing handlers that depend on them.

## Ambient state and effects

Keep ordinary module loading inert. Perform startup effects only in explicit entrypoints or framework-owned hooks.

Confine mutable global state to an explicit framework or runtime boundary with a defined lifecycle and synchronization policy. Pass operation-specific values inward explicitly rather than using ambient state as hidden domain input.

Treat time, randomness, and identity generation as explicit dependencies when they affect behavior. Pure calculations receive concrete timestamps and generated values.

## Completion check

Every configuration value is parsed once at an owning boundary, malformed values fail, and precedence is explicit. Every acquired resource has a valid scope and release strategy. Runtime work occurs in its owning phase, module loading is inert, and ambient mutable state remains contained.
