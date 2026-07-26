---
name: writing-for-agents
description: Reference for predictable agent-facing documents.
disable-model-invocation: true
---

Agent-facing documents exist to wrangle determinism out of a stochastic system. **Predictability** — the agent taking the same _process_ every run, not producing the same output — is the root virtue; every lever below serves it. This applies to system prompts, rules files, `AGENTS.md`, skill bodies, and documents reached through pointers. What differs between those surfaces is how they load.

**Bold terms** are defined in [`GLOSSARY.md`](GLOSSARY.md); look them up there for the full meaning.

When the document is a skill, read [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md) for frontmatter, invocation choice, descriptions, and router skills.

## The two loads

Every document and pointer spends one of two budgets:

- **Context load** — the cost of always-loaded material on the agent's context window: a system prompt, rules file, `AGENTS.md` line, or model-invoked skill description spends tokens and attention every turn whether or not it matters. Material reached only through a pointer escapes that load at the price of the pointer itself.
- **Cognitive load** — the cost to the human of remembering which documents exist and when to reach for them. The human is the index. Spend this where human judgement matters; remove it where the agent should discover the material itself.

The choice is a tradeoff, not a minimisation problem. An always-loaded surface earns the hardest pruning; material with no pointer avoids context load but rides entirely on cognitive load.

## Context pointers

A **context pointer** names out-of-context material and encodes when to reach it. Its wording, not its target, decides whether the agent follows it reliably. A pointer does two jobs: state what the material is, and name each **branch** that should trigger it. Because the pointer itself is always loaded, prune it harder than the body:

- **Front-load the leading word** that should trigger the material.
- **Use one trigger per branch.** Collapse synonyms that restate the same case; keep only genuinely distinct branches.
- **Cut identity already carried nearby.** Do not restate what the pointer's heading, skill name, or leading word already conveys.

If must-have material is missed, sharpen the pointer before pulling the material inline.

## Information hierarchy

Instructions are built from two content types — **steps** and **reference** — that mix freely: a document can be all steps, all reference, or both. The core decision is which to use and where each sits on the **information hierarchy**, a ladder ranked by how immediately the agent needs the material:

1. **In-file step** — an ordered action in the main file, the primary tier: what the agent does, in order. Each step ends on a **completion criterion**, the condition that tells the agent the work is done. Make it _checkable_ (can the agent tell done from not-done?) and, where it matters, _exhaustive_ ("every modified model accounted for", not "produce a change list"). A vague criterion invites **premature completion**: sharpen the criterion first; only when it is irreducibly fuzzy and the agent demonstrably rushes should you hide the **post-completion steps** across a real context boundary such as a hand-off or subagent dispatch.
2. **In-file reference** — a definition, rule, or fact in the main file, consulted on demand. Often a legitimately flat peer-set (every rule of a review on one rung) — a fine arrangement, not a smell. _This document is all reference._
3. **External reference** — reference pushed out of the main file into a separate one, reached by a **context pointer**, loaded only when the pointer fires. (Spans _disclosed_ reference — a sibling file like `GLOSSARY.md`, still part of the same unit — through fully **external reference** that lives outside any document and anything can point at.)

A demanding completion criterion drives thorough **legwork** — the digging the agent does within the work — whether the document has steps or not, since "every rule applied" binds flat reference just as "every step done" binds a sequence.

Push too little down and the top bloats; push too much and you hide material the agent actually needs. That tension is the whole decision.

**Progressive disclosure** is the move down the ladder — out of the main file into a linked one — so the top stays legible. Some instructions are used in more than one way, and each distinct way is a **branch** — different runs taking different paths through them. Branching is the cleanest disclosure test: inline what every branch needs, and push behind a pointer what only some branches reach.

Where the ladder decides _how far down_ a piece sits, **co-location** decides _what sits beside it_ once there: keep a concept's definition, rules, and caveats under one heading rather than scattered, so reading one part brings its neighbours with it.

**Sprawl** is the failure mode here: a document can be too long even when every line is live and unique. Attention thins across the excess. Cure it with the ladder — disclose reference behind pointers, and split by branch or sequence so each path carries only what it needs.

## Pruning

Keep each meaning in a **single source of truth**. **Duplication** costs maintenance and tokens, and gives repeated guidance more prominence than it deserves.

Check every line for **relevance**: does it still bear on what the instructions do? Without pruning, stale layers become **sediment** that obscures the live guidance.

Then hunt **no-ops** sentence by sentence: does this change behaviour versus the model's default? When one fails, delete the whole sentence rather than trim it. A weak leading word (_be thorough_ when the model is already thorough-ish) is also a no-op; replace it with a stronger word such as _relentless_.

## Leading words

A **leading word** is a compact concept already living in the model's pretraining that the agent thinks with while following the instructions (e.g. _lesson_, _fog of war_, _tracer bullets_). Repeated throughout the text (though not necessarily - a strong leading word might only be needed once), it accumulates a distributed definition and anchors a whole region of behaviour in the fewest tokens, by recruiting priors the model already holds.

It serves predictability twice. In the body it anchors _execution_: the agent reaches for the same behaviour every time the word appears. In a trigger surface — a skill's description, a rule's applies-to line — it anchors _invocation_: when the same word lives in your prompts, docs, and code, the agent links that shared language to the instructions and fires them more reliably.

Hunt for opportunities to refactor instructions to use leading words. A triad spelled out at three sites (**duplication**), a sentence spent gesturing at one idea — each is a passage begging to **collapse** into a single token. Examples include:

- "fast, deterministic, low-overhead" -> _tight_ — one quality restated across a phase — into a single pretrained word (a _tight_ loop).
- "a loop you believe in" -> _red_ — converts a fuzzy gate into a binary observable state (the loop goes _red_ on the bug, or it doesn't).

You win twice over: fewer tokens, _and_ a sharper hook for the agent to hang its thinking on. Assume every document is carrying restatements that leading words retire — go find them.

**Negation** is the failure mode beside this lever: steering by prohibition makes the forbidden behaviour more available. _Don't think of an elephant_, and the elephant is all there is. Prompt the **positive** target instead; retain a prohibition only as a hard guardrail that cannot be phrased positively, and pair it with what to do.
