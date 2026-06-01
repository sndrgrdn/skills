# Agent Skills

A collection of agent skills that extend capabilities across development, review, and writing.

## Development

- **hotwire** — Build and debug Hotwire features with Turbo Drive, Turbo Frames, Turbo Streams, and Stimulus. Covers forms, navigation, real-time streaming, Rails broadcasting, morphing, progressive enhancement, and testing.

  ```
  npx skills@latest add sndrgrdn/skills/hotwire
  ```

## Review & Shipping

- **deslop** — Review recently written code for over-engineering, paranoia, defensive chaff, and LLM-generated slop. Proposes numbered cuts and applies only explicitly approved changes.

  ```
  npx skills@latest add sndrgrdn/skills/deslop
  ```

- **create-pr** — Create or update GitHub pull requests with intent-focused, professional descriptions.

  ```
  npx skills@latest add sndrgrdn/skills/create-pr
  ```

- **babysit-pr** — Fix actionable CI failures and address review feedback until tests pass and the PR is merge-ready.

  ```
  npx skills@latest add sndrgrdn/skills/babysit-pr
  ```

## Writing & Editing

- **humanizer** — Remove signs of AI-generated writing from text. Detects and rewrites 31 AI writing patterns to make prose sound natural and human.

  ```
  npx skills@latest add sndrgrdn/skills/humanizer
  ```

- **skill-writer** — Create, synthesize, and iteratively improve agent skills following the Agent Skills specification. Handles source capture, precision passes, authoring, registration, and validation.

  ```
  npx skills@latest add sndrgrdn/skills/skill-writer
  ```

- **prompt-optimizer** — Create, optimize, and refine agent prompts and system prompts. Supports model-family porting (OpenAI, Claude, Gemini) and eval-driven iteration.

  ```
  npx skills@latest add sndrgrdn/skills/prompt-optimizer
  ```
