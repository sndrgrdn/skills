---
name: humanizer
description: Rewrite AI-sounding text into natural human prose. Use when asked to humanize, de-AI, remove tells, make text sound human, or clean up LLM output for publication.
disable-model-invocation: true
---

# Humanizer

Find **tells** — AI-generated patterns that signal machine authorship — and rewrite them into natural prose. Preserve meaning, restore specificity, match venue.

## Workflow

1. Identify target venue (email, essay, article, PR, documentation, comment, social post).
2. Scan the cluster table and pattern index. Open every pattern reference that plausibly matches the input. Completion: every cluster checked, references opened for each match.
3. Open `references/rewrite-playbook.md`. Rewrite for specificity, directness, and varied rhythm.
4. Open `references/audit-output-contract.md`. Run the anti-AI audit, then revise. Completion: no unaddressed tells in the audit.
5. If input is too short to assess style, say so and still fix obvious tells.

Default voice: short-to-medium sentences, concrete nouns and verbs, contractions where venue allows, fewer transitions. Do not fabricate citations, quotes, named people, or lived experience.

## High-signal clusters

| Cluster | Tells | Pattern refs |
|---|---|---|
| Generic smoothing | significance inflation, promotional phrasing, vague authority, superficial analysis | 01, 03, 04, 05 |
| Mechanical structure | rule of three, title-case headings, bold label lists, tiny tables | 10, 16, 17, 18, 20 |
| Chatbot residue | "here is", "let me know", cutoff disclaimers, refusal remnants, placeholders | 33, 34, 35, 36, 37 |
| Citation residue | `turn0search`, `oaicite`, bad DOI/ISBN, UTM leakage | 43, 44, 45 |
| Defensive tone | compliance reassurance, open-to-feedback boilerplate, focus-on-content deflection | 39, 40, 41 |

## Pattern index

Each pattern has its own reference with signals, false positives, rewrite strategy, and before/after.

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

| Open when... | Read |
|---|---|
| Judging confidence, handling false positives, or explaining uncertainty | `references/detection-caveats.md` |
| Rewriting complex or high-stakes text | `references/rewrite-playbook.md` |
| Running final checks and choosing response shape | `references/audit-output-contract.md` |
| Inspecting before/after examples for calibration | `references/transformed-examples.md` |

## Output

1. **Draft rewrite**
2. **Anti-AI audit** — remaining tells or risks
3. **Final rewrite**
4. **Changes made** — by pattern class, with pattern numbers
