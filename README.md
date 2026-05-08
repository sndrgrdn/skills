# Agent Skills

A collection of agent skills that extend capabilities across planning, development, and review.

## Planning & Design

Think through problems before writing code.

- **grill-me** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.

  ```
  npx skills@latest add sndrgrdn/skills/grill-me
  ```

- **grill-with-docs** — Same grilling, but also challenges your plan against the existing domain model (CONTEXT.md, ADRs) and updates documentation inline as decisions crystallize.

  ```
  npx skills@latest add sndrgrdn/skills/grill-with-docs
  ```

- **to-prd** — Synthesize the current conversation and codebase understanding into a PRD. No interview — just writes it from what it already knows.

  ```
  npx skills@latest add sndrgrdn/skills/to-prd
  ```

- **to-todos** — Break a plan, spec, or PRD into independently-grabbable file-backed todos using tracer-bullet vertical slices.

  ```
  npx skills@latest add sndrgrdn/skills/to-todos
  ```

- **improve-codebase-architecture** — Surface architectural friction and propose deepening opportunities: refactors that turn shallow modules into deep ones. Informed by CONTEXT.md and ADRs.

  ```
  npx skills@latest add sndrgrdn/skills/improve-codebase-architecture
  ```

## Development

Write, refactor, and fix code.

- **hotwire** — Build Hotwire applications with Turbo Drive, Turbo Frames, Turbo Streams, and Stimulus. Covers forms, inline editing, typeahead, modals, and real-time streams.

  ```
  npx skills@latest add sndrgrdn/skills/hotwire
  ```

- **rails-hotwire** — Rails-specific Hotwire best practices: broadcasts, morphing, Stimulus boundaries, progressive enhancement, and testing.

  ```
  npx skills@latest add sndrgrdn/skills/rails-hotwire
  ```

## Review & Shipping

Sharpen work before it leaves your machine.

- **deslop** — Review recently written code for over-engineering, paranoia, and LLM slop. Checks each candidate against local codebase idiom before trimming.

  ```
  npx skills@latest add sndrgrdn/skills/deslop
  ```

- **pr-writer** — Create or update pull requests with a consistent structure. Always use before running `gh pr create`.

  ```
  npx skills@latest add sndrgrdn/skills/pr-writer
  ```

- **iterate-pr** — Keep pushing on a PR until CI passes and review feedback is addressed. Fetches check status, extracts failure snippets, fixes, and re-pushes.

  ```
  npx skills@latest add sndrgrdn/skills/iterate-pr
  ```

- **commit** — Commit staged or related changes with a clear message. Optionally push.

  ```
  npx skills@latest add sndrgrdn/skills/commit
  ```

## Writing & Editing

- **humanizer** — Remove signs of AI-generated writing from text. Detects and rewrites 31 AI writing patterns to make prose sound natural and human.

  ```
  npx skills@latest add sndrgrdn/skills/humanizer
  ```

- **skill-writer** — Create, synthesize, and iteratively improve agent skills following the Agent Skills specification. Handles source capture, depth gates, authoring, registration, and validation.

  ```
  npx skills@latest add sndrgrdn/skills/skill-writer
  ```

- **prompt-optimizer** — Create, optimize, and refine agent prompts and system prompts. Supports model-family porting (OpenAI, Claude, Gemini) and eval-driven iteration.

  ```
  npx skills@latest add sndrgrdn/skills/prompt-optimizer
  ```
