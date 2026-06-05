# Humanizer Specification

## Intent

Remove AI-writing tells from user-provided text and replace them with natural, venue-appropriate human prose. The skill covers prose patterns, structural artifacts, chatbot residue, citation/markup leakage, and broad AI-writing signs while preserving meaning and avoiding unsupported claims.

## Scope

In scope:
- Rewriting AI-sounding prose into natural human writing
- Auditing text for pattern clusters without claiming certainty from style alone
- Voice matching when the user provides a writing sample
- Handling general writing, professional writing, comments, edit summaries, and documentation
- Loading one focused reference per suspected AI-writing pattern
- Removing or flagging citation, URL, Markdown, markup, and chatbot-interface artifacts
- Running a draft rewrite → anti-AI audit → final rewrite loop

Out of scope:
- Proving whether a human or AI wrote the original text
- Relying on AI detectors as proof
- Fact-checking claims unless explicitly requested
- Inventing citations, examples, dates, studies, quotes, or lived experience
- SEO optimization, translation, or content generation from only a brief
- Platform-specific moderation, policy enforcement, or style-guide compliance beyond rewrite/audit guidance

## Users And Trigger Context

- Primary users: writers, editors, developers, and reviewers with text that sounds AI-generated or overly polished/generic.
- Common user requests: "humanize this", "make it sound human", "remove ChatGPT tells", "de-slop", "de-AI this", "make this less robotic", "audit for AI writing", "rewrite to sound natural".
- Should not trigger for: ordinary proofreading with no AI-pattern concern, pure translation, summarization, or requests to write new content from scratch.

## Runtime Contract

- Required first actions:
  - Identify venue and whether a writing sample exists.
  - Scan `SKILL.md` pattern index and load each applicable `references/pattern-XX-*.md`.
- Required outputs:
  - Draft rewrite
  - Anti-AI audit
  - Final rewrite
  - Changes made
- Non-negotiable constraints:
  - Preserve meaning and intended tone.
  - Do not assert AI authorship unless provenance or explicit artifacts justify it.
  - Do not launder unverifiable claims by making them sound human.
  - Do not fabricate specificity.
  - Run the audit pass before final output.
- Expected bundled files loaded at runtime:
  - applicable per-pattern files under `references/pattern-XX-*.md`
  - `references/detection-caveats.md` when auditing or explaining confidence
  - `references/rewrite-playbook.md` for complex rewrites
  - `references/audit-output-contract.md` for final validation/format
  - `references/transformed-examples.md` for example-driven calibration

## Source And Evidence Model

Authoritative sources:
- `SOURCES.md` records provenance, adaptation notes, coverage, and gaps.
- The upstream Signs of AI writing article is the primary pattern source, treated as descriptive advice rather than proof.
- Local prior Humanizer files are the source for the existing trigger/output contract and voice-calibration behavior.

Useful improvement sources:
- positive examples: rewrites that remove tells while preserving voice and meaning
- negative examples: rewrites that over-humanize, invent specificity, or merely hide tells
- commit logs/changelogs: upstream source revisions and local skill changes
- issue or PR feedback: missed-pattern reports, false positives, output-contract complaints
- validation results: structural validator output and manual reference-routing checks

Data that must not be stored:
- secrets
- customer data
- private URLs or identifiers not needed for reproduction
- sensitive original text examples unless anonymized and explicitly useful

## Reference Architecture

- `SKILL.md` contains: trigger description, runtime workflow, full per-pattern router, high-signal cluster table, voice calibration, constraints, output format.
- `references/pattern-XX-*.md` contains: one AI-writing pattern per file, including signals, false positives, rewrite strategy, before/after, and audit question.
- `references/detection-caveats.md` contains: uncertainty handling and false-positive guidance.
- `references/rewrite-playbook.md` contains: cross-pattern rewrite strategy.
- `references/audit-output-contract.md` contains: final audit checklist and response formats.
- `references/transformed-examples.md` contains: happy-path, robust/secure, and anti-pattern examples.
- `SOURCES.md` contains: source inventory, adaptation decisions, coverage matrix, gaps, and stopping rationale.
- `scripts/` and `assets/`: none.

## Validation

- Lightweight validation:
  - structural skill validation passes
  - every reference in `SKILL.md` exists
  - every runtime reference is directly discoverable from `SKILL.md`
  - no grouped pattern reference remains
- Deeper validation:
  - route representative inputs to the correct per-pattern refs: prose article, email/comment, documentation, citation-artifact text, quick final-only request
  - run transformed examples and ensure the final rewrite does not invent facts
- Holdout examples:
  - none stored yet
- Acceptance gates:
  - one reference per pattern
  - source-backed caveats included
  - expanded source-backed pattern classes represented
  - rewrite playbook includes safe handling for unsupported claims
  - output contract preserves draft/audit/final loop

## Known Limitations

- The upstream source is broader than most day-to-day writing needs; some signs are venue-specific and weak outside their original context.
- AI-writing style changes quickly; model-era vocabulary can drift.
- Surface cleanup can hide deeper problems. The skill flags suspicious facts/citations but does not verify them unless asked.
- Very short text may not provide enough signal for voice matching or confidence.
- Human writers increasingly adopt LLM-like phrasing, which raises false-positive risk.

## Maintenance Notes

- When to update `SKILL.md`: trigger wording changes, workflow changes, pattern router changes, output contract changes.
- When to update `SPEC.md`: scope, source model, reference architecture, validation gates, or data policy changes.
- When to update `SOURCES.md`: upstream sync, new source decisions, coverage/gap changes.
- When to update pattern references: new high-signal patterns, corrected examples, safer rewrite rules, or changed artifact behavior.
- When to update `references/evidence/`: persistent anonymized positive/negative/holdout examples become available.
