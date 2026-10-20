---
name: deep-research
description: Investigate broad questions requiring multiple research threads, conflicting evidence, and a synthesized, cited report. Use research for bounded technical questions and documentation lookups.
---

# Deep research

The lead scopes the investigation, delegates source gathering, checks evidence, and reviews the report. Use a fresh agent for final synthesis so gathering and writing have separate contexts. The lead may inspect original sources to verify findings; delegate new research threads to researchers.

## 1. Define the investigation

Identify the audience, question or decision, boundaries, relevant dates or versions, source constraints, and success criteria from the request and available context. Ask focused questions only when an unknown would change the goal or materially alter scope. State other assumptions and obtain missing research inputs during the investigation.

Propose the question, outline, evidence standard, effort bound, and output location. Obtain approval for a changed goal or material scope expansion; otherwise proceed within the requested scope. Honor explicit requests to approve a plan first.

Match the repo's existing notes convention. Keep intermediate notes in an investigation-specific directory and record all paths in its coverage map. Read [references/research-frameworks.md](references/research-frameworks.md) to select methods appropriate to the question.

Completion criterion: the investigation has a defined scope, output path, and a checkable standard for answering the question, including how to report an inconclusive result.

## 2. Assign research threads

For unfamiliar domains, delegate a bounded reconnaissance pass to identify terminology, source availability, subquestions, and blind spots. Otherwise divide the question directly into bounded threads. Parallelize independent threads and sequence dependent work.

Read [references/agent-briefs.md](references/agent-briefs.md) before dispatch. Give each researcher a question, boundaries, evidence requirements, effort bound, and unique note path. Maintain a coverage map linking each report section or decision criterion to an assignment, note path, and status. Include a search for evidence that could overturn the expected conclusion.

Completion criterion: every required section has an owner and evidence requirements, with dependencies and verification work assigned.

## 3. Inspect evidence and close gaps

Read every note. Check claim support, source independence, applicability to the relevant dates or versions, contradictions, and coverage. Open the underlying sources for consequential claims and a sample of supporting claims; verify that the cited passages support the wording. Expand verification when a check reveals defects. Track unresolved items in the coverage map.

Delegate targeted follow-ups for gaps or disputed claims. For a conclusion that controls the recommendation, seek a fresh source or reproducible check not used to develop it. Preserve credible counterevidence and explain whether disagreements reflect scope, methods, timing, or unresolved uncertainty.

Stop when the evidence standard is met or the effort bound is reached. At that bound, document what remains unresolved; ask before materially expanding the investigation. A claim without retrievable support remains unverified, not established.

Completion criterion: each required section is supported or explicitly limited, consequential claims have been checked against original evidence, and credible conflicts remain visible.

## 4. Synthesize and validate

Give a fresh writer the question, outline, coverage map, all note paths, and final output path. Apply the writer contract in [references/agent-briefs.md](references/agent-briefs.md).

Review the report against the question and coverage map. Check that conclusions follow from evidence, citations support their adjacent claims, inference is labeled, and limitations affect the strength of recommendations. Check local references and cited URLs where accessible; a reachable URL alone does not establish support.

Send specific defects back to the writer or researcher within the effort bound. Remove unsupported assertions or label them as hypotheses. Deliver an explicitly partial or inconclusive report when the evidence cannot support a complete answer.

Completion criterion: every required section is present, conclusions are traceable to checked evidence, and remaining limitations are explicit.

## 5. Deliver

Return the report path, concise conclusions, important uncertainties, and unresolved checks. Retain research notes unless the user asks to remove them. Distinguish completed research from a partial result and explain which missing evidence could change the answer.
