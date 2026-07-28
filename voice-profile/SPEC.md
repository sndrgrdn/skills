# Voice Profile Specification

## Intent

This skill gives an agent Sander's complete voice profile so it can write *as* him — matching character, tone, and venue-appropriate formatting. The goal is output that sounds like Sander wrote it, not output that has been "personalized" toward a generic friendly register.

## Scope

In scope:
- Writing as Sander across all venues (Slack, PR descriptions, emails, cover letters, blog posts, outreach)
- Venue-appropriate formatting adjustments (case, punctuation, length, emoji)
- Anti-pattern detection and removal in drafted content
- Rewrite heuristic for self-review

Out of scope:
- Humanizing generic AI prose (use the humanizer skill)
- Fact-checking or content research
- Generating content that invents facts, quotes, or lived experience

## Users And Trigger Context

- Primary users: agents writing first-person content on Sander's behalf
- Common user requests: "write in my voice", "match my style", "sound like Sander", "write as me", "write this as I would", "make this sound like me"
- Should not trigger for: generic AI-prose cleanup without a personal voice requirement (use humanizer)

## Runtime Contract

- Required first actions: open `references/voice-profile.md` before drafting
- Required outputs: content that passes the 7-point rewrite heuristic
- Non-negotiable constraints: no manufactured enthusiasm, no self-nomination phrasing, no anti-pattern vocabulary
- For written/professional register: also read `~/Developer/career-ops/config/voice-samples.md`
- Expected bundled files loaded at runtime: `references/voice-profile.md`

## Source And Evidence Model

Authoritative sources:
- `~/Developer/career-ops/config/voice-samples.md` — canonical samples for professional register (established 2026-05-18)
- `references/voice-profile.md` — distilled from the above and from sander.garden prose

Useful improvement sources:
- positive examples: cover letters and outreach that Sander approved as on-brand
- negative examples: drafts that were rejected as "too polished", "overachieving", or "corporate"
- session messages: live calibration signal from how Sander actually writes to the agent

Data that must not be stored:
- secrets
- customer data
- private URLs or identifiers not needed for reproduction

## Reference Architecture

- `SKILL.md` contains: activation instructions, routing table, non-negotiables
- `references/voice-profile.md` contains: core character traits, venue format adjustments, signature phrases, anti-patterns, rewrite heuristic, canonical sources
- `references/evidence/` contains: (empty — add approved examples here when available)

## Validation

- Lightweight validation: `uv run /Users/sander/.agents/skills/skill-writer/scripts/quick_validate.py /Users/sander/.agents/skills/voice-profile`
- Deeper validation: draft a cover letter paragraph → check against 7-point heuristic → flag any anti-pattern hits
- Acceptance gates: output passes heuristic; no anti-pattern vocabulary present; venue formatting matches table

## Known Limitations

- The profile is a distillation; edge cases may require reading canonical samples directly
- Casual/spoken register (lowercase, typos, fragments) differs significantly from written register — always check venue table
- The profile cannot substitute for the user's live session messages as calibration signal

## Maintenance Notes

- When to update `SKILL.md`: trigger language changes, new venue types added
- When to update `references/voice-profile.md`: new anti-patterns identified, character traits refined, venue rules change
- When to update `SOURCES.md`: provenance changes, new canonical source added
- Sync with `~/Developer/career-ops/config/voice-samples.md` when that file is updated significantly
