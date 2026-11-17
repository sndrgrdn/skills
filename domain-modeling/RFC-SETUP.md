# Set up RFCs in a project

Run these steps once per project, from the repository root. Each step ends on the check named in it.

1. **Copy the check.** Copy [scripts/rfcs](./scripts/rfcs) to `bin/rfcs` and make it executable. It needs Ruby and git, and nothing else. Done when `bin/rfcs` runs and reports that `docs/rfcs/domains.yml` is missing.
2. **Name the domains.** Write `docs/rfcs/domains.yml`, one entry per area of the codebase that has its own rules:

   ```yaml
   - block: "00"
     domain: process
     covers: How a change is made, reviewed, and merged
   - block: "01"
     domain: accounts
     covers: Tenancy, URLs, and public ids
   ```

   Use the words in `GLOSSARY.md` for the domains. Block `00` is always `process`, because RFC-0001 lives there. Done when every area the user names has a block.
3. **Write RFC-0001.** Write `docs/rfcs/0001-rfcs.md` from [RFC-FORMAT.md](./RFC-FORMAT.md): the project's own rules for when an RFC is warranted, the statuses, and what checks them. Keep its statements to what this project decides differently or must never lose. RFC-FORMAT.md carries the rest.
4. **Move existing rules in.** For each ADR, conventions file, or rule doc, write one RFC per decision or topic. Turn each rule into a statement, and keep the reasons and rejected options under their headings. Give the RFC `formerly:` with the old name, and set `status: enforced` for rules the project follows today. Skip any rule a linter or check already enforces, and name that check under `## What checks this`. Done when a script that compares every sentence of the old files against the new RFCs reports only sentences you split or reworded on purpose.
5. **Rewrite the citations.** Replace every `ADR-NNNN` and every old doc path in the repository with the new `RFC-NNNN`, using a script with an explicit old-to-new map. Then delete the old files. Done when `bin/rfcs` reports no ADR citations.
6. **Generate the index.** Run `bin/rfcs --write`. Done when `bin/rfcs` exits 0.
7. **Wire it in.** Add `bin/rfcs` to the project's CI. In `AGENTS.md`, add one pointer: "Before changing code, read the statements of its domain in `docs/rfcs/INDEX.md`. Open an RFC only for its reasoning." Done when CI runs the check, and a planted `ADR-0001` citation makes it fail.
