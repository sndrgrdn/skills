# Agent Skills

A collection of agent skills that extend capabilities across planning, development, and review.

Upstream sources are noted where a skill was adapted from external work.

## Planning & Design

Think through problems before writing code.

- **grill-me** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.

  Source: [mattpocock/skills/grill-me](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me)

  ```
  npx skills@latest add sndrgrdn/skills/grill-me
  ```

- **grill-with-docs** — Same grilling, but also challenges your plan against the existing domain model (CONTEXT.md, ADRs) and updates documentation inline as decisions crystallize.

  Source: [mattpocock/skills/grill-with-docs](https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs)

  ```
  npx skills@latest add sndrgrdn/skills/grill-with-docs
  ```

- **to-prd** — Turn the current conversation context into a PRD and save it as a markdown file.

  ```
  npx skills@latest add sndrgrdn/skills/to-prd
  ```

- **to-todos** — Break a plan, spec, or PRD into independently-grabbable file-backed todos using tracer-bullet vertical slices.

  ```
  npx skills@latest add sndrgrdn/skills/to-todos
  ```

- **improve-codebase-architecture** — Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and the decisions in docs/adr/.

  Source: [mattpocock/skills/improve-codebase-architecture](https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture)

  ```
  npx skills@latest add sndrgrdn/skills/improve-codebase-architecture
  ```

## Development

Write, refactor, and fix code.

- **hotwire** — Build and debug Hotwire features with Turbo Drive, Turbo Frames, Turbo Streams, and Stimulus. Covers forms, navigation, real-time streaming, Rails broadcasting, morphing, progressive enhancement, and testing.

  Source: [TheHotwireClub/hotwire_club-skills](https://github.com/TheHotwireClub/hotwire_club-skills), [hotwired.dev](https://hotwired.dev)

  ```
  npx skills@latest add sndrgrdn/skills/hotwire
  ```

- **tdd** — Test-driven development with a red-green-refactor loop. Integration-style tests through public interfaces.

  Source: [mattpocock/skills/tdd](https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd)

  ```
  npx skills@latest add sndrgrdn/skills/tdd
  ```

- **diagnose** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce, minimise, hypothesise, instrument, fix, regression-test.

  Source: [mattpocock/skills/diagnose](https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnose)

  ```
  npx skills@latest add sndrgrdn/skills/diagnose
  ```

- **cucumber-capybara** — Write and improve Cucumber scenarios with Capybara for browser-based system tests. Covers Gherkin quality, Capybara waiting, step reuse, and common anti-patterns.

  ```
  npx skills@latest add sndrgrdn/skills/cucumber-capybara
  ```

## Review & Shipping

Sharpen work before it leaves your machine.

- **deslop** — Review recently written code for over-engineering, paranoia, and LLM slop. Proposes numbered cuts and applies only explicitly approved changes.

  ```
  npx skills@latest add sndrgrdn/skills/deslop
  ```

- **thermo-nuclear-code-quality-review** — Extremely strict maintainability review focused on abstraction quality, giant files, and spaghetti-condition growth.

  Source: [cursor/plugins/thermo-nuclear-code-quality-review](https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review)

  ```
  npx skills@latest add sndrgrdn/skills/thermo-nuclear-code-quality-review
  ```

- **create-pr** — Create or update GitHub pull requests with intent-focused, professional descriptions.

  Source: [Intercom create-pr gist](https://gist.github.com/gregolsen/2aefc99aab6a44f5bc4e06638ad4f163), [Sentry pr-writer](https://github.com/getsentry/skills/tree/main/skills/pr-writer)

  ```
  npx skills@latest add sndrgrdn/skills/create-pr
  ```

- **babysit-pr** — Keep a PR merge-ready: triage CI failures, address review feedback, and iterate until checks pass.

  Source: [Sentry iterate-pr](https://github.com/getsentry/skills/tree/main/skills/iterate-pr)

  ```
  npx skills@latest add sndrgrdn/skills/babysit-pr
  ```

## Writing & Editing

- **humanizer** — Remove signs of AI-generated writing from text. Detects and rewrites 31 AI writing patterns to make prose sound natural and human.

  Source: [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)

  ```
  npx skills@latest add sndrgrdn/skills/humanizer
  ```

- **skill-writer** — Create, synthesize, and iteratively improve agent skills following the Agent Skills specification. Handles source capture, precision passes, authoring, registration, and validation.

  Source: [getsentry/skills/skill-writer](https://github.com/getsentry/skills/tree/main/skills/skill-writer)

  ```
  npx skills@latest add sndrgrdn/skills/skill-writer
  ```

- **prompt-optimizer** — Create, optimize, and refine agent prompts and system prompts. Supports model-family porting (OpenAI, Claude, Gemini) and eval-driven iteration.

  Source: [getsentry/skills/prompt-optimizer](https://github.com/getsentry/skills/tree/main/skills/prompt-optimizer)

  ```
  npx skills@latest add sndrgrdn/skills/prompt-optimizer
  ```
