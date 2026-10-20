---
name: research
description: Investigate a bounded question against primary sources and save a cited Markdown note in the repo. Use for focused technical questions, docs or API lookups, and background reading. Use deep-research for broad investigations requiring multiple research threads and synthesis.
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source. Distinguish findings from inference, report conflicting evidence, and state uncertainties and unanswered questions.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.

Before delivery, read the returned note and check that it answers the question, its claims have supporting citations, and conflicts and gaps are explicit. Send defects back to the researcher until each is resolved or documented as a limitation. Return the note path and any material limitations.
