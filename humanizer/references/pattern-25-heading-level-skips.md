# Pattern 25: Skipped or inconsistent heading levels

Open this when the text may contain **skipped or inconsistent heading levels**.

## Signals

starts at ###; jumps from h2 to h4; inconsistent heading hierarchy

## Why it reads AI-generated

AI often guesses heading syntax and violates document hierarchy.

## False positives

- Human writers may use this pattern deliberately for genre, emphasis, or local style.
- Treat one instance as weak evidence. Treat repeated use with other tells as stronger.
- Preserve the pattern if it is required by a style guide, quote, code, citation, or the user's sample voice.

## Rewrite strategy

Normalize hierarchy or remove unnecessary headings.

## Before

> ### Background
##### Details

## After

> ## Background
### Details

## Audit question

Does the rewritten sentence say something specific that the original actually supports, or did it merely hide the tell?
