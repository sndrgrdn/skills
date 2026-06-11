# Tjalling-Review Sources

## Source Inventory

| Source | Trust | Confidence | Contribution |
|--------|-------|------------|--------------|
| Sander review comments (1114 JSONL) | high | high | Blindspot analysis: workers, backfills, AI slop detection, blocking structure |
| Raw review comments (4586 JSONL) | high | high | Primary source for tone, patterns, and examples |
| Synthesized skill draft (`tjalling-review-skill.md`) | medium | high | Structured analysis of review patterns |
| Agent config draft (`tjalling-code-reviewer.md`) | medium | medium | Initial frontmatter and communication style |
| Existing skill conventions (`deslop`) | high | high | Structural reference for skill layout |

## Key Decisions

| Decision | Status | Rationale |
|----------|--------|-----------|
| Shape: `reference-backed-expert` | adopted | Core process fits SKILL.md router; examples justify separate reference |
| `inline-guidance` rejected | rejected | 615 questions + 429 suggestions + domain patterns would bloat router |
| Single reference file | adopted | One `review-examples.md` grouped by category; split not needed |
| Booqable patterns inline | adopted | Every review needs these; reference would force unnecessary file load |
| Project-scoped location | adopted | Skill is Booqable-specific; belongs in repo `.agents/skills/` |

## Data Analysis

Comment distribution:
- review_comment: 2894, issue_comment: 1170, review: 522
- APPROVED: 235, COMMENTED: 192, CHANGES_REQUESTED: 88, DISMISSED: 7

Pattern frequency (substantive comments >80 chars):
- Questions: 615, Testing: 579, Suggestions: 429, Consistency: 250, Simplification: 168, Performance: 134

## Gaps

| Gap | Impact | Next Action |
|-----|--------|-------------|
| No holdout examples | low | Add when iterating from review outcomes |
| Frontend patterns thin | low | Enrich when more React/JSX data analyzed |

## Changelog

| Date | Change |
|------|--------|
| 2026-06-04 | Initial creation from 4586 raw comments + 2 draft files. Replaced broken frontmatter agent config. |
| 2026-06-04 | Added workers, backfills, AI-generated code detection, impact statistics, blocking/non-blocking structure from Sander's 1114 review comments. |
