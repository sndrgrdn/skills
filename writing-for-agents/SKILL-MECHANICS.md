# Skill mechanics

The skill-specific branch of [`writing-for-agents`](SKILL.md): frontmatter, invocation choice, descriptions, splitting by invocation, and router skills. The universal writing guidance remains in `SKILL.md`.

## Invocation

Choose between two invocation modes, trading the two loads:

- A **model-invoked** skill is visible to the agent, so it can fire autonomously and other skills can reach it. It remains available to the human too. Its description is permanently loaded, spending **context load** for discoverability. Omit `disable-model-invocation` and write a model-facing description carrying the trigger branches.
- A **user-invoked** skill is reachable only when the human names it. It spends no context load but adds **cognitive load** because the human must remember it exists. Set `disable-model-invocation: true`; its description is a short human-facing summary without trigger phrasing.

Use model invocation only when the agent or another skill must discover the skill independently. If it only fires by hand, keep it user-invoked.

For OpenAI metadata, keep the invocation policy aligned with the frontmatter: `allow_implicit_invocation: true` for model-invoked skills and `false` for user-invoked skills.

## Descriptions

A model-invoked description is the skill's top-level **context pointer**. Apply the pointer-writing rules from `SKILL.md`: front-load the leading word, use one trigger per branch, and cut identity already conveyed by the skill name or nearby metadata.

A user-invoked description is an interface for the human choosing a skill, not a model trigger. Keep it to one line describing what the skill provides.

## Splitting by invocation

Split off a model-invoked skill when it has a distinct leading word that should trigger independently, or another skill must reach it. That independent reach must justify the context load of another always-loaded description.

Shared reference needed by multiple user-invoked skills belongs in a plain file they can each point to. User-invoked skills cannot invoke one another because the model cannot discover them.

## Router skills

When user-invoked skills multiply beyond what the human can remember, add one user-invoked **router skill** that names the others and explains when to choose each. It reduces the human's index to one entry, but it can only guide the human; it cannot invoke skills hidden from the model.
