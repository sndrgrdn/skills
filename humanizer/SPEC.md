# Humanizer Specification

## Intent

Remove AI writing patterns from text and replace them with natural human voice. The skill detects 31 cataloged patterns that betray AI-generated writing — from vocabulary tells and structural formulas to formatting artifacts — and rewrites them while preserving meaning and adding personality.

## Scope

In scope:
- Detecting and rewriting all 31 cataloged AI writing patterns
- Voice matching when the user provides a writing sample
- Two-pass anti-AI audit (draft → audit → final)
- Adding personality and human feel to sterile-but-clean rewrites

Out of scope:
- Fact-checking or verifying claims in the input text
- Translation or language conversion
- SEO optimization or keyword insertion
- Wikipedia-specific markup patterns (broken wikitext, turn0search, oaicite, heading-level skipping)
- Content generation from scratch (skill requires input text to rewrite)

## Users And Trigger Context

- Primary users: anyone with AI-generated text that needs to sound human
- Common user requests: "humanize this", "make it sound human", "remove AI patterns", "de-slop", "rewrite to sound natural", "sounds like ChatGPT", "reads like AI"
- Should not trigger for: general editing/proofreading without AI-pattern focus, translation requests, summarization, content creation from a brief

## Runtime Contract

- Required first actions: load `references/patterns.md` to get full 31-pattern catalog
- Required outputs: draft rewrite, anti-AI audit bullets, final rewrite
- Non-negotiable constraints:
  - Preserve core meaning and intended tone
  - Scan against all 31 patterns, not a subset
  - Run the two-pass audit — do not skip the self-check
  - When a writing sample is provided, match its voice before applying defaults
- Expected bundled files loaded at runtime: `references/patterns.md`

## Source And Evidence Model

Authoritative sources:
- [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — maintained by WikiProject AI Cleanup. Primary source for the pattern catalog. Last synced: 2026-05-07.

Useful improvement sources:
- positive examples: successful humanizations where all tells were removed
- negative examples: rewrites that introduced new AI patterns or lost meaning
- commit logs/changelogs: Wikipedia article revision history for new patterns
- issue or PR feedback: user reports of missed patterns or false rewrites

Data that must not be stored:
- secrets
- customer data
- private URLs or identifiers not needed for reproduction

## Reference Architecture

- `SKILL.md` contains: trigger description, task steps, 31-pattern quick reference table, voice calibration rules, personality guidance, process steps, output format
- `references/patterns.md` contains: full pattern catalog with signal words, problem descriptions, before/after examples, era-specific AI vocabulary breakdown, worked example

## Validation

- Lightweight validation: count patterns in quick reference table matches patterns.md heading count (both should be 31)
- Deeper validation: run the worked example through the skill and check that the listed patterns are caught
- Holdout examples: none stored yet
- Acceptance gates: all 31 patterns have signal words and before/after examples in `references/patterns.md`

## Known Limitations

- Pattern catalog is Wikipedia-centric in origin; some patterns (curly quotes, notability inflation) are more relevant in certain contexts than others
- False ranges (12) and passive voice (13) were removed or merged in the Wikipedia source but kept here as valid general-writing tells — may diverge from upstream
- Era-specific vocabulary breakdown may lag behind new model releases
- The skill cannot detect AI writing that has already been manually edited to remove surface tells
- Voice matching depends on the quality and length of the provided writing sample

## Maintenance Notes

- When to update `SKILL.md`: new patterns added, pattern count changes, trigger language changes, process steps change
- When to update `SPEC.md`: scope changes, source model changes, validation gates change, new reference files added
- When to update `references/patterns.md`: Wikipedia source article is revised with new patterns, pattern definitions change, new era-specific vocabulary data available. Record sync date in the file header.
