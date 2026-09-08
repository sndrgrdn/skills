---
name: write-discoverable-code
description: Make code resolve through plain-text search when naming symbols, defining signatures, writing comments or diagnostics, and organizing files, modules, imports, or tests.
---

One search should resolve the question. A hit should identify the exact concept, lead to one definition, and provide enough local context to use it without following unrelated code.

## Names are search queries

- Give exported symbols and methods the shortest name that greps uniquely, usually two to four words with a domain term. Give generic verbs their object. Receivers and directory paths do not disambiguate a symbol because they are absent from its search hit; count context only when a rigid convention makes it visible at the use site.
- Use one canonical project spelling for each concept. Rename a symbol in the same change when its behavior, audience, or visibility changes, and keep one definition site.
- Give files domain names rather than bare roles such as `config`, `types`, `utils`, or `handlers`. Keep `index` files as thin re-export entry points.

## Signatures answer the first question

Use explicit input and output types whose names make the signature read as a sentence. A search hit or compiler error should identify what enters, what returns, and which domain concepts are involved without requiring an implementation read.

## Put information where search lands

- Give every export a one-line doc comment with the sharpest constraint its signature cannot show and the natural-language phrase a reader would search for. A comment that restates the name or signature adds no value.
- Keep event names, flags, error codes, and diagnostic prefixes as complete literals. Start each error message at its throw site with a distinctive literal phrase.
- State deliberate non-implementations where a search for the absent behavior would land. Mark obsolete paths with `@deprecated` and point to the replacement.
- Imported names and their doc lines should make sense without opening their source modules.

## Organize around searchable concepts

- Give each question-sized concept one named file. Keep orchestrators as short sequences of calls into those files. Split files that answer unrelated questions; keep helpers used only by one concept with that concept.
- Prefer direct imports. Keep necessary barrels short and explicit; avoid `export *` chains that hide the name-to-file mapping.
- Colocate a test with the behavior it specifies so one search finds both.
- Record non-obvious naming and concept-location conventions in `AGENTS.md`, where future sessions will load them.
