# Pattern 44: AI URL tracking leakage

Open this when the text may contain **ai url tracking leakage**.

## Signals

utm_source=chatgpt.com; utm_source=openai; utm_source=copilot.com; referrer=grok.com

## Why it reads AI-generated

The URL may have been copied from an AI tool. This proves tool involvement in sourcing, not necessarily prose authorship.

## False positives

- Human writers may use this pattern deliberately for genre, emphasis, or local style.
- Treat one instance as weak evidence. Treat repeated use with other tells as stronger.
- Preserve the pattern if it is required by a style guide, quote, code, citation, or the user's sample voice.

## Rewrite strategy

Strip tracking parameters and check whether the source actually supports the claim.

## Before

> https://news.example/story?utm_source=chatgpt.com

## After

> https://news.example/story

## Audit question

Does the rewritten sentence say something specific that the original actually supports, or did it merely hide the tell?
