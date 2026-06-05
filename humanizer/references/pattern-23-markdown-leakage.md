# Pattern 23: Markdown leakage in non-Markdown contexts

Open this when the text may contain **markdown leakage in non-markdown contexts**.

## Signals

## headings; **bold**; - bullets; ``` fences; [text](url); --- breaks

## Why it reads AI-generated

Chatbots default to Markdown. Raw Markdown in email, docs, forms, or pasted prose is a strong artifact.

## False positives

- Human writers may use this pattern deliberately for genre, emphasis, or local style.
- Treat one instance as weak evidence. Treat repeated use with other tells as stronger.
- Preserve the pattern if it is required by a style guide, quote, code, citation, or the user's sample voice.

## Rewrite strategy

Convert to the target format or natural prose.

## Before

> ## Key Takeaways
- **Performance:** 2x faster

## After

> The new build is about twice as fast.

## Audit question

Does the rewritten sentence say something specific that the original actually supports, or did it merely hide the tell?
