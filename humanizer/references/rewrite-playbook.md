# Rewrite Playbook

Use this after spotting AI tells. The goal is not to hide detection artifacts. The goal is better writing.

## Rewrite sequence

1. Preserve: extract claims, facts, intended tone, venue, and audience.
2. Remove scaffolding: delete chatbot talk, filler, fake transitions, generic conclusions.
3. Replace generic meaning with concrete meaning: dates, actors, actions, limits, tradeoffs.
4. Simplify grammar: use `is`, `has`, and active verbs where natural.
5. Vary shape: mix sentence lengths, merge fake triplets, avoid uniform bullets.
6. Add human judgment only when genre allows it.
7. Re-read aloud and cut anything that sounds like a brochure, compliance bot, or tutorial intro.

## Specificity ladder

Prefer the highest available rung. Do not invent higher rungs.

1. verifiable fact: who did what, when, where
2. observed consequence: measurable or directly stated effect
3. attributed interpretation: named person/source says X
4. bounded uncertainty: what is unknown and why
5. generic claim: broader importance, impact, significance

Rewrite generic claims by moving up the ladder or deleting them.

## Replacement moves

| Bad move | Better move |
|---|---|
| delete all formal words | replace only clustered or unnatural formalism |
| add slang everywhere | match sample/venue |
| insert fake anecdote | use concrete but source-neutral phrasing |
| add first person to every piece | use first person only when appropriate |
| remove citations because they look AI-ish | preserve real citations; flag suspicious ones |
| turn every list into prose | keep lists when they genuinely help scanning |
| overcorrect dashes/quotes mechanically | follow target venue conventions |

## Voice strategies

| Desired voice | Do |
|---|---|
| professional human | direct verbs, fewer abstractions, modest confidence |
| casual personal | contractions, shorter sentences, natural asides |
| analytical | specific claims, named uncertainty, no grand conclusions |
| persuasive | concrete stakes, plain contrasts, less ceremony |
| developer/docs | imperative steps, code terms preserved, no marketing |

## Human texture without fakery

Safe:
- mild uncertainty: "probably", "I don't think", "hard to tell" when appropriate
- concrete constraints: "this breaks when...", "the source only says..."
- plain preference: "I'd keep this shorter"
- uneven rhythm: one short sentence between longer ones

Unsafe:
- invented lived experience
- invented quotes/interviews
- unverifiable statistics
- fake named sources
- excessive self-conscious messiness

## Before/after micro-patterns

### Grandiosity to fact

Before:
> The project marks a pivotal shift in the evolving landscape of civic technology.

After:
> The project lets residents report road damage through a mobile form instead of calling city hall.

### Chatbot intro to direct start

Before:
> Let's dive into the key things you need to know about password managers.

After:
> A password manager stores your logins and generates stronger passwords than most people will create by hand.

### Policy-bot to human comment

Before:
> My intention is to contribute constructively while adhering to all relevant standards.

After:
> I added the source because it covers the resignation directly. If you think it is too close to the subject, I'll replace it.

## Final read-aloud check

Ask:

- Would a person say this sentence without being paid by the word?
- Does this claim apply to almost any topic?
- Did I add specificity I cannot support?
- Is the structure too symmetrical?
- Did I keep the user's actual point?
