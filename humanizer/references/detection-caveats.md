# Detection Caveats

Use this before accusing text of being AI-written or when the user asks for an audit.

## Core stance

- Say "AI-sounding", "contains common LLM tells", or "reads machine-assisted" unless provenance is known.
- Do not claim authorship origin from style alone.
- Do not rely on AI detectors as proof. They have meaningful false-positive and false-negative rates.
- A single tell is weak. Clusters across wording, structure, markup, and citation behavior are stronger.
- Treat the signs as rewrite leads, not as the whole problem.

## Why false positives happen

| Apparent tell | Human explanation |
|---|---|
| perfect grammar | professional writer, editor, non-native speaker using grammar tools |
| formal or academic prose | genre convention |
| bland/robotic tone | cautious institutional writing |
| curly quotes | Word, macOS/iOS smart quotes, typesetting, citation tools |
| Markdown | developers, Obsidian, GitHub, Reddit, Slack, notes apps |
| unsourced content | old notes and normal sloppy writing predate LLMs |
| em dashes | personal style, professional editing |
| transition words | essay convention; only clusters matter |
| mixed casual/formal register | technical workers, neurodivergence, code-switching, multi-author text |

## High-confidence clusters

Escalate confidence when several appear together:

1. generic significance claims + promotional phrasing + vague sources
2. Markdown/list artifacts in a venue that does not use Markdown
3. chatbot interface phrases plus knowledge-cutoff disclaimers
4. citation artifacts such as `turn0search`, `oaicite`, `utm_source=chatgpt.com`, or impossible refs
5. sudden polished style shift compared with an author's older writing
6. exhaustive formal edit summaries for small changes
7. placeholders left unfilled (`[Your Name]`, `INSERT_SOURCE_URL`, `2025-XX-XX`)

## Rewrite implications

- If confidence is low: make the text clearer and less generic; do not mention AI unless asked.
- If confidence is medium: report pattern clusters, not certainty.
- If confidence is high due to artifacts: remove artifacts and flag any fact/citation that cannot be safely rewritten.
- For sourced or professional writing, do not merely hide tells. Fix deeper risks: unsupported synthesis, source misrepresentation, hallucinated citations, and broken markup.

## Useful phrasing

- "This has several AI-writing tells: generic significance claims, vague attribution, and Markdown residue."
- "I can't prove origin from style, but these are the parts that read machine-assisted."
- "The citation artifacts are stronger evidence than the prose style. I removed the artifacts and marked claims that need verification."
