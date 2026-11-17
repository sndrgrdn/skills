# Edit log

Use actual edits to infer voice patterns. Explicit user instructions override inferred patterns; handle them through [`profile-management.md`](profile-management.md).

## Hypothesis policy

- Record an inferred voice pattern, structure habit, or banned phrase under Open hypotheses with its scope (`core` or one venue) and supporting pair paths.
- While drafting, use hypotheses within their scope as optional considerations, not required corrections or quotas.
- A pattern supported by one or two pieces remains a hypothesis. Propose promotion only after the same correction holds across three or more pieces. Count pieces, not repeated edits within one piece.
- For promotion, quote the exact guide line and request approval. After approval, follow [`profile-management.md`](profile-management.md) to update the venue guide, or `core.md` when the pattern holds across venues. Remove the promoted hypothesis; retain its log history.
- Retire a hypothesis when a later piece reverses it, recording the counterevidence in the log.

## Open hypotheses

None yet.

## Log a shared final

Complete this procedure when the user shares an edited final of a draft. Use the matching draft from the conversation or supplied files. If it is missing, ask for it before proceeding.

1. Save the matched pair under `references/edits/<YYYY-MM-DD>-<venue>-<slug>/` as `draft.md` and `final.md`. Resolve paths relative to `SKILL.md`; choose a subject-based slug that preserves existing pairs.
2. Run `scripts/edit-rate.sh` on the saved pair. Record its counts and rate. If it fails, report the failure and record the rate as unavailable. The rate measures textual change, not voice quality: filling a placeholder raises it even when the voice was fine.
3. Account for every edit, grouping repeated moves under these classes:
   - **voice rule**: cadence, diction, or a recurring move
   - **structure/format**: order, length, punctuation, or layout
   - **fidelity**: correction of a fact, opinion, feeling, or verdict unsupported by the source
   - **banned phrase**: a phrase removed or replaced on sight
   Record placeholder replacements separately as filled source gaps, not banned phrases or voice rules. Where the source or reason for an edit is unavailable, record the uncertainty rather than guessing a class.
4. Update Open hypotheses under the policy above. Recording, adding evidence, and retiring hypotheses are part of logging; changes to voice guides require approval. Fidelity corrections and filled source gaps do not become voice rules. If the same kind of invention recurs across three pieces, propose a sharper source-fidelity check in `SKILL.md` for approval.
5. Append an entry under Log containing:
   - Date, venue, slug, and pair path.
   - Edit rate, inserted, deleted, draft tokens, and final tokens, or the computation failure.
   - Edits by class, filled source gaps, and any unresolved classifications. Omit empty groups.
   - Hypotheses added, supported, or retired, and any proposed guide or source-fidelity changes.
6. Report the saved pair and log entry. Present proposed guide changes with their exact wording and await approval before applying them.

## Log

No entries yet.
