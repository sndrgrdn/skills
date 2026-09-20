# Correctness and data

## Boundary parsing and invariants

Preserve established evidence. Parse external representations and establish new invariants at their owner. Do not discard precise information by converting meaningful values back into generic strings, numbers, maps, or unknown representations.

Treat database rows, cache entries, events, workflow state, and other serialized data as boundary data whenever they re-enter executing code. A library declaration describes a representation but does not prove runtime integrity.

## Valid state representation

- Make illegal states unrepresentable where practical.
- Give identifiers, units, and constrained values distinct domain representations when they carry invariants or meaningful mix-up risk.
- Construct constrained values through parsers or constructors that establish their invariants.
- Resolve optionality before calling behavior that requires a value. Keep optionality when it is part of the domain.
- Model absence according to the operation. Use ordinary absence when the caller interprets it, and an expected failure when presence is required.
- Represent omission, null, absence, and defaults according to their actual semantics.
- Handle closed internal variants exhaustively. Give unknown external variants an explicit ignore, reject, preserve, or dead-letter policy.

## Producer contracts

Treat recurring defensive checks across multiple established consumers as evidence that their producer may be missing a contract. One consumer keeps its requirement local. Two similar consumers reveal duplication but do not establish a shared invariant.

Move an invariant to its producer only when the producer can truthfully guarantee it for all consumers. Keep use-case-specific requirements in the application operation that owns them. Remove downstream defenses only after the stronger contract is enforced.

## Representation separation

Introduce a separate protocol or persistence representation only when its fields, encoding, naming, optionality, authority, or semantics differ meaningfully from the application contract. Translate it at the owning boundary.

Reuse a definition only when its meaning and invariants are the same. Use explicit translation when similarity is merely structural. Derive dependent contracts from their owning definition instead of maintaining equivalent declarations separately.

## Unchecked operations

An unchecked operation requires:

- a concrete runtime invariant that makes the operation safe;
- containment in the smallest responsible owner; and
- an explanation of what the language or framework cannot express.

Unchecked operations include unchecked casts, untyped values, unchecked deserialization, raw interpolation, skipped validations, and visibility-bypassing reflection or metaprogramming.

## Completion criterion

Every changed value has an identified producer, established invariants, remaining invariants, and owner. Boundary data is parsed into meaningful representations, valid states are explicit, recurring consumer defenses have been checked for an established producer contract, semantically distinct contracts remain separate, and each unchecked operation has concrete evidence and narrow containment.
