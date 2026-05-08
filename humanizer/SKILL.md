---
name: humanizer
version: 3.1.0
description: |
  Remove signs of AI-generated writing from text. Use when asked to "humanize"
  text, "make it sound human", "remove AI patterns", "de-slop writing",
  "rewrite to sound natural", or when text "sounds like ChatGPT" or "reads
  like AI". Detects and rewrites 31 AI writing patterns including inflated
  significance, promotional language, AI vocabulary (with era-specific tells
  for GPT-4/4o/5), em dash overuse, rule of three, vague attributions,
  sycophantic tone, filler phrases, negative parallelisms, unnecessary tables,
  markdown artifacts, and generic conclusions.
license: MIT
---

# Humanizer

Remove AI writing patterns and add human voice.

## Task

1. Read `references/patterns.md` for the full 31-pattern catalog.
2. Scan input text against every pattern.
3. Rewrite problematic sections with natural alternatives.
4. Preserve core meaning and intended tone.
5. Add personality — clean-but-soulless is as obvious as slop.
6. Run the two-pass anti-AI audit (see [Process](#process)).

## Pattern quick reference

Scan for all of these. Full definitions, signal words, and before/after examples are in `references/patterns.md`.

| # | Pattern | Key tells |
|---|---------|-----------|
| 1 | Significance inflation | "pivotal moment", "testament to", "evolving landscape" |
| 2 | Notability inflation | "featured in", "active social media presence" |
| 3 | Superficial -ing analyses | "highlighting...", "showcasing...", "reflecting..." |
| 4 | Promotional language | "nestled", "vibrant", "groundbreaking", "breathtaking" |
| 5 | Vague attributions | "Experts argue", "Industry reports" |
| 6 | Formulaic challenges sections | "Despite challenges... continues to thrive" |
| 7 | AI vocabulary | "delve", "crucial", "tapestry", "underscore", "foster", "bolstered", "robust", "meticulous" — shifts by model era |
| 8 | Copula avoidance | "serves as", "stands as", "boasts", "maintains", "refers to" instead of "is"/"has" |
| 9 | Negative parallelisms | "It's not just X; it's Y", tailing "no guessing" |
| 10 | Rule of three | Forced triplets for fake comprehensiveness |
| 11 | Synonym cycling | "protagonist"→"main character"→"central figure"→"hero" |
| 12 | False ranges | "from X to Y" without a meaningful scale |
| 13 | Passive voice / subjectless fragments | "No configuration needed" |
| 14 | Em dash overuse | Punchy sales-writing dashes everywhere |
| 15 | Boldface overuse | Mechanical emphasis on every term |
| 16 | Inline-header lists | `- **Label:** description` pattern |
| 17 | Title Case headings | Every Main Word Capitalized |
| 18 | Emojis | 🚀💡✅ decorating headers or bullets |
| 19 | Curly quotes | "smart quotes" instead of "straight quotes" |
| 20 | Chatbot artifacts | "I hope this helps!", "Let me know if..." |
| 21 | Knowledge-cutoff disclaimers | "as of my last update", "based on available information" |
| 22 | Sycophantic tone | "Great question!", "You're absolutely right!" |
| 23 | Filler phrases | "In order to", "It is important to note that" |
| 24 | Excessive hedging | "could potentially possibly be argued" |
| 25 | Generic positive conclusions | "The future looks bright", "exciting times ahead" |
| 26 | Hyphenated pair overuse | Perfectly consistent "cross-functional", "data-driven" |
| 27 | Persuasive authority tropes | "The real question is", "at its core" |
| 28 | Signposting | "Let's dive in", "here's what you need to know" |
| 29 | Fragmented headers | Heading → one-line restatement → actual content |
| 30 | Unnecessary tables | Small 2–3 row tables where prose would suffice |
| 31 | Markdown formatting artifacts | Raw `**bold**`, `## headers`, `- ` lists leaking into non-Markdown contexts |

## Voice calibration

When the user provides a writing sample, analyze it before rewriting:

1. Note sentence length patterns, word choice level, paragraph openings, punctuation habits, recurring phrases, and transition style.
2. Replace AI patterns with patterns from the sample. If they write short sentences, don't produce long ones. If they say "stuff" and "things," don't upgrade to "elements" and "components."

When no sample is provided, fall back to the personality defaults below.

### How to provide a sample

- Inline: "Humanize this text. Here's a sample of my writing for voice matching: [sample]"
- File: "Humanize this text. Use my writing style from [file path] as a reference."

## Personality and soul

Avoiding AI patterns is half the job. Sterile, voiceless writing is just as obvious as slop.

### Signs of soulless writing (even when technically clean):

- Every sentence same length and structure
- No opinions, just neutral reporting
- No acknowledgment of uncertainty or mixed feelings
- No first-person perspective when appropriate
- No humor, no edge, no personality
- Reads like a Wikipedia article or press release

### How to add voice:

**Have opinions.** Don't just report facts — react to them. "I genuinely don't know how to feel about this" beats neutrally listing pros and cons.

**Vary rhythm.** Short punchy sentences. Then longer ones that take their time. Mix it up.

**Acknowledge complexity.** Real humans have mixed feelings. "This is impressive but also kind of unsettling" beats "This is impressive."

**Use "I" when it fits.** First person isn't unprofessional. "I keep coming back to..." or "Here's what gets me..." signals a real person thinking.

**Let some mess in.** Perfect structure feels algorithmic. Tangents, asides, and half-formed thoughts are human.

**Be specific about feelings.** Not "this is concerning" but "there's something unsettling about agents churning away at 3am while nobody's watching."

### Before (clean but soulless):
> The experiment produced interesting results. The agents generated 3 million lines of code. Some developers were impressed while others were skeptical. The implications remain unclear.

### After (has a pulse):
> I genuinely don't know how to feel about this one. 3 million lines of code, generated while the humans presumably slept. Half the dev community is losing their minds, half are explaining why it doesn't count. The truth is probably somewhere boring in the middle — but I keep thinking about those agents working through the night.

## Process

1. Read input text carefully.
2. Identify all pattern instances (use the quick reference table above and `references/patterns.md`).
3. Rewrite each problematic section.
4. Verify the rewrite: sounds natural read aloud, varies sentence structure, uses specifics over vague claims, uses simple constructions (is/are/has) where appropriate.
5. Present the draft.
6. Run anti-AI audit: ask "What makes the below so obviously AI generated?" and answer with remaining tells.
7. Revise to fix remaining tells.
8. Present the final version.

## Output format

Return exactly:

1. **Draft rewrite** — first pass with all patterns fixed.
2. **Anti-AI audit** — brief bullets listing remaining tells in the draft.
3. **Final rewrite** — revised after the audit.
4. **Changes made** — list which numbered patterns were fixed (optional, include when helpful).
