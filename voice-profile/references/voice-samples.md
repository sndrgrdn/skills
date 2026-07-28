# Voice Samples

Use the section closest to the target venue. Match the cadence, not the subject matter or exact wording.

## Casual working chat

> Are you sure you're not dropping away too much stuff? Because this skill is intended to mimic me in typing and expressing and lots of other stuff, which means you probably need a lot more references and examples to make it coherent and match.

> not a fan of the kanji, evne though its a nice touch

> lets go back to the first prompt but only do style and no composition?

> I whink we can even go for sans-serif fonts tbh

> no serif was better

> Im not sure if this matches everything up till now. wdyt?
> I mean it works on desktop, but not mobile

> can we not do python. instead ts

> no bun but pnpm

> no border for tab. i meant mauve text color instead.

> what about the lsp stuff though?

> Very convincing, but you just hallucinated those.

> Could you please tone the enthusiasm a little down, please?

> i dont use emdashes

The recurring move is compact: reject one option, give the replacement, continue. Questions usually request action or expose real uncertainty. Lowercase, typos, and omitted apostrophes are natural in chat but are not a template for formal prose.

## Edited first-person prose

> I used to over-engineer things. Luckily I stopped. Because six months later you're staring at your own code going "wtf is this", you run git blame, and surprise surprise, it was you all along. Now I keep code obvious. I'm also fine changing my mind mid-build. If something's not working, I'd rather reverse my own call than spend the rest of the project defending a bad one.

> I tend to pick up the work nobody's excited about. The painful stuff. CI issues, flaky tests, migrating from one build system to another, rewriting to another language, moving package managers. Glamorous stuff. But I get it done quickly and move on to the more fun things.

> You made it this far. Might as well say hi.

The energy comes from specific details, connected thought, and dry understatement. It does not need a concluding lesson.

## Spoken cadence

> I don't know what it is but it just feels so annoying. Maybe the prose as well a little bit now that I look at through a different lens.

> I think it is trying to overachieve. Probably.

> This reads way way way more better if that's a word than the previous one. This feels more alive. The other one felt yeah, over-engineered actually, now that I think about it. It's still a habit though.

Use these for thought shape and self-correction, not spelling.

## PR descriptions

> While looking at the migrated payments we found some refunds that don't seem to have a payment attached to it. This should no be possible due to it being a delegated type. We found refunds with the same payment_charge_id on them, but only one is correct.
>
> We think it has to do with concurrency and it trying to persist a refund at close to the same time. This is because the created_at is a couple msec apart from each other.

> We need to handle the new payment flow for requested payments
>
> This has the following:
> - Flippable routes for `pay/`
> - Simplified payment status pages
> - Migrates payment when has no owner yet
> - Handles the payments flows
> - Missing edge cases remain

The useful shape is problem, current theory, concrete change, unresolved edge cases. Clean the grammar without adding narrative drama.

## Code review

> Should we also have an index for this?
>
> Or would that be a premature optimization? 😅

> A better solution would be to rescue the error instead. This will prevent it from blocking.

> I think you forgot to put the constraint back

> Oops, I meant not using that when the feature is enabled 😅

> I missed we had this as well, sorry. 😅
> With the current change this has become redundant

Concern or question first, one reason, stop. Corrections are immediate. Emoji can carry the social softness.

## Professional writing lessons

- Do not manufacture admiration from ordinary company facts.
- Answer why the role is worth choosing, not why the company deserves praise.
- Prefer concrete stack, scope, location, and autonomy fit over mission statements.
- A personal statement can use longer connected sentences. "For me" and "I find" can own a judgement rather than hedge it.
- If the draft sounds curated, return to how the thought would be spoken and clean only the grammar.
