# Pattern 45: Invalid or hallucinated citations

Open this when the text may contain **invalid or hallucinated citations**.

## Signals

invalid DOI/ISBN; DOI points elsewhere; book without page for precise claim; unused named refs; irrelevant PMID

## Why it reads AI-generated

LLMs can fabricate plausible citations or misuse real identifiers.

## False positives

- Human writers may use this pattern deliberately for genre, emphasis, or local style.
- Treat one instance as weak evidence. Treat repeated use with other tells as stronger.
- Preserve the pattern if it is required by a style guide, quote, code, citation, or the user's sample voice.

## Rewrite strategy

Flag as unverified. Keep the prose only if it is supported by a real source supplied by the user.

## Before

> The claim is supported by doi:10.1109/PROC.1974.9547.

## After

> The supplied DOI does not support this claim; a valid source is needed.

## Audit question

Does the rewritten sentence say something specific that the original actually supports, or did it merely hide the tell?
