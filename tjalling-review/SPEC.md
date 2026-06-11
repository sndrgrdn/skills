# Tjalling-Review Specification

## Intent

Code review skill that reproduces Tjalling van der Wal's review style: consistency-first, question-driven, concrete, and direct. Targets the Booqable codebase.

## Scope

In scope:
- Reviewing code changes for consistency, architecture, test quality, business logic, and performance
- Providing feedback in Tjalling's communication style
- Enforcing Booqable-specific patterns (interactors, Graphiti, testing conventions)

Out of scope:
- Automated CI checks or linting
- Non-code review tasks (design review, product review)
- General refactoring advice outside a review context

## Users And Trigger Context

- Primary users: developers reviewing Booqable PRs or asking for senior-level code feedback
- Common user requests: "review this code", "Tjalling-style review", "thorough code review", "check this PR"
- Should not trigger for: generic linting, formatting, test execution, or bug fixing

## Runtime Contract

- Required first actions: read the diff or code under review, check codebase context for pattern consistency
- Required outputs: structured review with high-level assessment, specific findings, questions, and verdict
- Non-negotiable constraints: always question before asserting, always provide concrete alternatives, always explain the why
- Expected bundled files loaded at runtime: `references/review-examples.md` (optional, for calibration)

## Source And Evidence Model

Authoritative sources:
- 4586 real review comments from Tjalling's GitHub history
- Synthesized skill drafts from prior analysis

Data that must not be stored:
- customer data, private URLs, or internal company secrets

## Reference Architecture

- `SKILL.md` contains: core review process, communication patterns, decision framework, Booqable standards
- `references/` contains: `review-examples.md` — curated real examples by category

## Known Limitations

- Frontend patterns thinner than backend (limited React review data in source)
- Cannot access real codebase history or PR context at runtime without explicit tool use

## Maintenance Notes

- When to update `SKILL.md`: when review priorities or Booqable patterns change
- When to update `references/review-examples.md`: when better examples are found or patterns shift
