# Humanizer Sources

## Source inventory

| Source | Trust | Confidence | Contribution | Usage constraints |
|---|---:|---:|---|---|
| `SKILL.md` prior Humanizer versions | local | high | existing trigger/output contract, voice calibration, two-pass audit | preserve useful behavior; replace grouped catalog shape |
| `SPEC.md` prior version | local | high | scope, validation, maintenance contract | update because reference architecture changed to one ref per pattern |
| Wikipedia:Signs of AI writing, fetched 2026-06-05 | upstream advice page | high | expanded signs: caveats, content, language, style, comments, markup, citations, historical indicators, ineffective indicators, model differences | CC BY-SA/GFDL page; summarize/adapt, do not copy long examples wholesale; page is descriptive advice, not policy |
| Repo skill layout in workspace skill root | local convention | high | skill root, README catalog style, SPEC convention | keep skill-root-relative refs |

## Adaptation notes

| Decision | Record |
|---|---|
| source intent | Upstream page helps identify common signs of undisclosed LLM-generated content and related quality risks. |
| local target | Humanizer rewrites AI-sounding prose for everyday writing, comments, docs, and professional communication. |
| fidelity boundary | Preserve high-signal AI signs, caveats about uncertainty, and artifact handling. |
| local replacements | Convert upstream narrative/examples into one-reference-per-pattern runtime guidance and omit platform-only material. |
| omitted material | Long page-specific examples, deletion-process details, and search links that do not affect general rewriting. |
| rights/attribution | Source is attributed here; content is summarized and transformed into local pattern references. |

## Synthesis decisions

| Decision | Status | Rationale |
|---|---|---|
| skill class: generic writing/editing | adopted | Not integration/API or operational workflow; domain dimensions are patterns, caveats, rewrite methods, output contract. |
| execution shape: reference-backed expert | adopted | SKILL.md routes to detailed per-pattern leaves. |
| grouped pattern references | rejected | User requested one reference per pattern for maximum disclosure and detail. |
| compatibility-only 31-pattern index | removed | User requested only the improved per-pattern reference model. |
| script-backed workflow | rejected | No deterministic parsing/validation needed; judgment and rewriting dominate. |
| provider-specific mechanics | rejected | Skill should remain portable. |

## Coverage matrix

| Coverage pass | Status | Files |
|---|---|---|
| core behavior | complete | `SKILL.md`, `references/rewrite-playbook.md` |
| content/language signs | complete | `references/pattern-01-*.md` through `references/pattern-15-*.md` |
| style/formatting signs | complete | `references/pattern-16-*.md` through `references/pattern-32-*.md` |
| comments/chatbot residue | complete | `references/pattern-33-*.md` through `references/pattern-42-*.md` |
| citation artifacts | complete | `references/pattern-43-*.md` through `references/pattern-45-*.md` |
| negative behavior / false positives | complete | all pattern refs plus `references/detection-caveats.md` |
| repair patterns | complete | all pattern refs plus `references/rewrite-playbook.md`, `references/transformed-examples.md` |
| output validation | complete | `references/audit-output-contract.md` |
| version/model variance | partial | era vocabulary included in pattern 08; future model drift remains maintenance item |

## Stopping rationale

The requested upstream page was fetched current to 2026-06-05 and covers the target domain deeply. The per-pattern split now exposes each actionable sign as a direct runtime leaf with signals, false positives, rewrite strategy, example, and audit question. Additional retrieval would mostly refine model-specific vocabulary, which is lower-yield than preserving the requested detailed disclosure.

## Gaps

- No persistent user-specific holdout examples yet.
- No automated semantic validator for pattern quality; validation remains structural/manual.
- Model-era vocabulary will drift and should be resynced periodically.
