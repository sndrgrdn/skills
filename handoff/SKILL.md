---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Put temporary work files in `./tmp` if it exists, otherwise use the system temporary directory.

Include a "suggested skills" section in the document, listing Skill tool calls the next agent should make (e.g. Call the Skill tool with "coding-standards").

Do not duplicate content already captured in other artifacts (specs, plans, RFCs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
