# Agent Skills

A collection of agent skills that extend capabilities across planning, development, and review.

## Planning & Design

These skills help you think through problems before writing code.

- **write-a-prd** — Create a PRD through user interview, codebase exploration, and module design.

  ```
  npx skills@latest add sndrgrdn/skills/write-a-prd
  ```

- **create-plan** — Research (via subagent), draft, and iteratively review a plan before implementation. For cross-cutting changes that need alignment before code.

  ```
  npx skills@latest add sndrgrdn/skills/create-plan
  ```

- **prd-to-todos** — Break a PRD into independently-grabbable file-backed todos using tracer-bullet vertical slices.

  ```
  npx skills@latest add sndrgrdn/skills/prd-to-todos
  ```

- **grill-me** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.

  ```
  npx skills@latest add sndrgrdn/skills/grill-me
  ```

## Development

These skills help you write, refactor, and fix code.

- **tdd** — Test-driven development with a red-green-refactor loop. Integration-first, one vertical slice at a time.

  ```
  npx skills@latest add sndrgrdn/skills/tdd
  ```

- **hotwire** — Build Hotwire applications with Turbo Drive, Turbo Frames, Turbo Streams, and Stimulus. Covers forms, inline editing, typeahead, modals, and real-time streams.

  ```
  npx skills@latest add sndrgrdn/skills/hotwire
  ```

- **rails-hotwire** — Rails-specific Hotwire best practices: broadcasts, morphing, Stimulus boundaries, progressive enhancement, and testing.

  ```
  npx skills@latest add sndrgrdn/skills/rails-hotwire
  ```

## Review & Shipping

These skills help you sharpen work before it leaves your machine.

- **deslop** — Review recently written code for over-engineering, paranoia, and LLM slop. Checks each candidate against local codebase idiom before trimming.

  ```
  npx skills@latest add sndrgrdn/skills/deslop
  ```

- **for-real** — Force a skeptical second pass on your own work. Because "it should work" has never once been true.

  ```
  npx skills@latest add sndrgrdn/skills/for-real
  ```

- **pr-writer** — Create or update pull requests with a consistent structure. Always use before running `gh pr create`.

  ```
  npx skills@latest add sndrgrdn/skills/pr-writer
  ```

## Writing Skills

- **skill-writer** — Create, synthesize, and iteratively improve agent skills following the Agent Skills specification. Handles source capture, depth gates, authoring, registration, and validation.

  ```
  npx skills@latest add sndrgrdn/skills/skill-writer
  ```
