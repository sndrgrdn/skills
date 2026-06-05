# Pattern 43: AI citation-tool artifacts

Open this when the text may contain **ai citation-tool artifacts**.

## Signals

turn0search; turn0image; contentReference; oaicite; oai_citation; attached_file; grok_card; 

## Why it reads AI-generated

These are strong artifacts from AI browsing/citation interfaces, not style guesses.

## False positives

- Human writers may use this pattern deliberately for genre, emphasis, or local style.
- Treat one instance as weak evidence. Treat repeated use with other tells as stronger.
- Preserve the pattern if it is required by a style guide, quote, code, citation, or the user's sample voice.

## Rewrite strategy

Remove artifacts. Verify the source before keeping the claim. Do not invent replacement citations.

## Before

> The school is recognized internationally. citeturn0search1

## After

> The school says it is an international exam centre. [source needed]

## Audit question

Does the rewritten sentence say something specific that the original actually supports, or did it merely hide the tell?
