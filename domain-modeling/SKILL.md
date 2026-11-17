---
name: domain-modeling
description: "Build and sharpen a project's domain model: its glossary and its RFCs. Use when discussing codebase terminology, editing GLOSSARY.md, recording a decision or rule as an RFC, or setting up docs/rfcs in a project."
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline: challenging terms, inventing edge-case scenarios, and writing the glossary and the RFCs down the moment they crystallise. (Merely *reading* `GLOSSARY.md` for vocabulary is not this skill: that's a one-line habit any skill can do. This skill is for when you're changing the model, not just consuming it.)

## File structure

```
/
├── GLOSSARY.md
├── docs/
│   └── rfcs/
│       ├── domains.yml                     ← number blocks and their domains
│       ├── INDEX.md                        ← generated: every statement, by domain
│       ├── 0001-rfcs.md                    ← how this project writes RFCs
│       └── 0201-single-database-tenancy.md
├── bin/
│   └── rfcs                                ← checks the RFCs, writes INDEX.md
└── src/
```

If a `GLOSSARY-MAP.md` exists at the root, the repo has multiple contexts, each with its own `GLOSSARY.md`. The map points to where each one lives. The RFCs stay in one `docs/rfcs/`, with a domain per context.

Create files lazily: only when you have something to write. If no `GLOSSARY.md` exists, create one when the first term is resolved. If no `docs/rfcs/` exists, set it up with [RFC-SETUP.md](./RFC-SETUP.md) when the first RFC is needed. If the project still keeps ADRs in `docs/adr/`, RFC-SETUP.md also covers moving them.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `GLOSSARY.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account': do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible. Which is right?"

### Update GLOSSARY.md inline

When a term is resolved, update `GLOSSARY.md` right there. Don't batch these up: capture them as they happen. Use the format in [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md).

`GLOSSARY.md` should be totally devoid of implementation details. Do not treat `GLOSSARY.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Record rules and decisions as RFCs

An RFC holds what the code and its tools cannot say on their own, as numbered **statements**: one MUST or SHOULD rule each, such as `RFC-0403.4`. Agents read the statements in `docs/rfcs/INDEX.md` and cite them in reviews.

Offer an RFC in two cases:

- **A decision** that is hard to reverse, surprising without context, and the result of a real trade-off. If any of the three is missing, skip it: an easy decision gets reversed, an obvious one needs no record, and a choice with no alternative has nothing to explain.
- **A rule** that applies across the codebase and that no tool can check. When a linter, a type, or a test could check the rule, write the check instead, because a prose copy drifts from it.

Before writing, read the statements of the domain in `docs/rfcs/INDEX.md`. When the new rule contradicts one, say so in the open and ask the user. Write or change the RFC with [RFC-FORMAT.md](./RFC-FORMAT.md). Changing a rule is an edit to its RFC, never a new RFC. The project's own `docs/rfcs/0001-*.md` wins where it differs.

The RFC is done when `bin/rfcs --write` and then `bin/rfcs` pass, and the change that applies the decision lands in the same pull request.
