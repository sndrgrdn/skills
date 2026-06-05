---
name: humanizer
version: 5.1.0
description: |
  Rewrite AI-sounding prose so it reads like a real person wrote it. Use when
  asked to humanize text, make writing sound natural, remove ChatGPT/LLM tells,
  de-slop prose, de-AI a document, make text less robotic, or audit writing for
  signs of AI generation. Covers one-reference-per-pattern guidance for phrasing,
  structure, formatting artifacts, citations/markup leakage, and canned chatbot
  correspondence.
license: MIT
---

# Humanizer

Rewrite AI-sounding text into natural human prose without laundering facts, flattening voice, or merely hiding surface tells.

## Operating rule

Do not treat AI signs as a guilty verdict. Treat them as rewrite targets. Preserve meaning, remove generic smoothing, restore specificity, and keep the output appropriate to the user's venue.

## Voice matching

## Runtime workflow

1. Identify the target venue: email, essay, article, social post, documentation, PR/issue text, comment, or unknown.
2. If a voice profile applies, open it before rewriting. If a writing sample is supplied, calibrate voice from it.
3. Scan the pattern index below and open every pattern reference that plausibly applies.
4. Open `references/detection-caveats.md` when auditing, explaining confidence, or handling false positives.
5. Open `references/rewrite-playbook.md` before rewriting complex or high-stakes text.
6. Rewrite for specificity, directness, varied rhythm, and human judgment.
7. Open `references/audit-output-contract.md`, run the anti-AI audit, then revise once more.
8. Use `references/transformed-examples.md` when examples would improve calibration.

## Pattern index

Each pattern has its own reference with signals, false positives, rewrite strategy, before/after, and audit question.

| # | Pattern | Read |
|---|---|---|
| 01 | Significance, legacy, and broader-trend inflation | `references/pattern-01-significance-inflation.md` |
| 02 | Importance and media-coverage padding | `references/pattern-02-importance-media-padding.md` |
| 03 | Superficial -ing analysis | `references/pattern-03-superficial-analysis.md` |
| 04 | Promotional, brochure, or press-release language | `references/pattern-04-promotional-language.md` |
| 05 | Vague attribution and weasel wording | `references/pattern-05-vague-attribution.md` |
| 06 | Canned challenges and future-prospects sections | `references/pattern-06-canned-challenges.md` |
| 07 | High-density AI vocabulary clusters | `references/pattern-07-ai-vocabulary-density.md` |
| 08 | Avoidance of simple is/are/has constructions | `references/pattern-08-copula-avoidance.md` |
| 09 | Negative parallelism and fake contrast | `references/pattern-09-negative-parallelism.md` |
| 10 | Rule-of-three overuse | `references/pattern-10-rule-of-three.md` |
| 11 | Elegant variation and synonym cycling | `references/pattern-11-elegant-variation.md` |
| 12 | False ranges | `references/pattern-12-false-ranges.md` |
| 13 | Subjectless fragments and unnecessary passive voice | `references/pattern-13-subjectless-passive.md` |
| 14 | Abstract debate or discussion generation | `references/pattern-14-abstract-debate-generation.md` |
| 15 | Biology and ecosystem padding | `references/pattern-15-biology-ecosystem-padding.md` |
| 16 | Title-case headings | `references/pattern-16-title-case-headings.md` |
| 17 | Mechanical boldface overuse | `references/pattern-17-boldface-overuse.md` |
| 18 | Inline-header vertical lists | `references/pattern-18-inline-header-lists.md` |
| 19 | Em dash overuse | `references/pattern-19-em-dash-overuse.md` |
| 20 | Unnecessary small tables | `references/pattern-20-unnecessary-tables.md` |
| 21 | Curly quotation marks and apostrophe mismatch | `references/pattern-21-curly-quotes.md` |
| 22 | Emoji as formatting | `references/pattern-22-emoji-formatting.md` |
| 23 | Markdown leakage in non-Markdown contexts | `references/pattern-23-markdown-leakage.md` |
| 24 | Thematic breaks before headings | `references/pattern-24-thematic-breaks-before-headings.md` |
| 25 | Skipped or inconsistent heading levels | `references/pattern-25-heading-level-skips.md` |
| 26 | Fragmented headers and warm-up lines | `references/pattern-26-fragmented-headers.md` |
| 27 | Filler phrases | `references/pattern-27-filler-phrases.md` |
| 28 | Excessive hedging | `references/pattern-28-excessive-hedging.md` |
| 29 | Generic positive conclusions | `references/pattern-29-generic-conclusions.md` |
| 30 | Didactic disclaimers from older models | `references/pattern-30-didactic-disclaimers.md` |
| 31 | Formulaic section summaries | `references/pattern-31-section-summaries.md` |
| 32 | Hyphenated word-pair overuse | `references/pattern-32-hyphenated-pair-overuse.md` |
| 33 | Collaborative chatbot interface talk | `references/pattern-33-collaborative-chatbot-talk.md` |
| 34 | Knowledge-cutoff and source-gap speculation | `references/pattern-34-knowledge-cutoff-source-gaps.md` |
| 35 | Prompt-refusal leftovers | `references/pattern-35-prompt-refusal-leftovers.md` |
| 36 | Phrasal templates and unfilled placeholders | `references/pattern-36-phrasal-placeholders.md` |
| 37 | Abrupt generation cutoffs | `references/pattern-37-abrupt-cutoffs.md` |
| 38 | Email subject-line residue | `references/pattern-38-subject-line-residue.md` |
| 39 | Canned quality, good-faith, and compliance reassurance | `references/pattern-39-compliance-reassurance.md` |
| 40 | Canned offers to receive constructive criticism | `references/pattern-40-constructive-feedback-boilerplate.md` |
| 41 | Calls to focus on content instead of AI/conduct concerns | `references/pattern-41-focus-on-content-deflection.md` |
| 42 | Overwhelmingly exhaustive edit summaries | `references/pattern-42-exhaustive-edit-summaries.md` |
| 43 | AI citation-tool artifacts | `references/pattern-43-citation-tool-artifacts.md` |
| 44 | AI URL tracking leakage | `references/pattern-44-url-tracking-utm.md` |
| 45 | Invalid or hallucinated citations | `references/pattern-45-invalid-citations.md` |

## Non-pattern references

| Open when you need to... | Read |
|---|---|
| judge AI signs without overclaiming, handle false positives, or explain uncertainty | `references/detection-caveats.md` |
| rewrite rather than just delete tells; preserve facts, add specificity, match voice, and avoid over-humanizing | `references/rewrite-playbook.md` |
| run final checks and choose the exact response shape | `references/audit-output-contract.md` |
| inspect happy-path, robust/secure, and anti-pattern transformed examples | `references/transformed-examples.md` |

## Always scan for these high-signal clusters

| Cluster | Strong tells | Pattern refs |
|---|---|---|
| Generic smoothing | significance inflation, promotional phrasing, vague authority, superficial analysis | 01, 03, 04, 05 |
| Mechanical structure | rule of three, title-case headings, bold label lists, tiny tables | 11, 17, 18, 19, 21 |
| Chatbot residue | here is, let me know, cutoff disclaimers, refusal remnants, placeholders | 34, 35, 36, 37 |
| Citation residue | `turn0search`, `oaicite`, bad DOI/ISBN, UTM leakage | 43, 44, 45 |
| Defensive comment tone | compliance reassurance, open-to-feedback boilerplate, focus-on-content deflection | 38, 39, 40 |

## Voice calibration

When the user gives a sample, extract sentence length, punctuation habits, favorite plain words, paragraph shape, directness, humor/edge/doubt, and tolerated messiness. Match those traits. Do not upgrade casual writing into corporate prose. Do not add jokes or first person if the sample never uses them.

When no sample exists, default to short-to-medium sentences, concrete nouns and verbs, contractions where the venue allows them, fewer transitions, some human judgment when appropriate, and no fake anecdotes, fake citations, or fake specificity.

## Non-negotiables

- Preserve the user's claims unless asked to fact-check.
- Do not fabricate citations, studies, quotes, named people, dates, or lived experience.
- Do not remove domain terms just because they are formal.
- Do not make every sentence casual. Human professional writing can still be polished.
- Do not use AI detectors as proof.
- If the input is too short to assess style, say so briefly and still improve obvious tells.

## Output format

Return exactly:

1. **Draft rewrite** — first pass.
2. **Anti-AI audit** — brief bullets naming remaining tells or risks.
3. **Final rewrite** — revised version.
4. **Changes made** — concise bullets by pattern class; include pattern numbers when useful.
