---
name: to-todos
description: Break a plan, spec, or PRD into independently-grabbable file-backed todos using tracer-bullet vertical slices. Use when user wants to convert a plan into todos, create implementation tickets, or break down work into todos.
allowed-tools: read bash webfetch websearch todo
---

# To Todos

Break a plan into independently-grabbable implementation todos using vertical slices (tracer bullets).

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (file path, URL, or todo id) as an argument, fetch and read its full content.

If the plan is incomplete — missing problem statement, user stories, or constraints — ask clarifying questions before breaking it down.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Before exploring, follow [../grill-with-docs/DOMAIN-AWARENESS.md](../grill-with-docs/DOMAIN-AWARENESS.md). Todo titles and descriptions should use the project's `CONTEXT.md` vocabulary, and respect any ADRs in the area you're touching.

### 3. Draft vertical slices

Break the plan into **tracer bullet** todos. Each todo is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be `HITL` or `AFK`. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and completed without human interaction. Prefer AFK over HITL where possible. Do not mark a slice HITL just because it is hard; hard-but-clear work is AFK.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- Separate discovery/decision work from build work only when truly necessary
- Make dependencies explicit and minimize them aggressively
- Only mark a slice blocked if it is impossible to start without the blocker
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Before asking for approval, include a coverage check that maps each source user story to one or more proposed todos, and call out any uncovered stories.

Ask the user:

- Does the granularity feel right? Too coarse or too fine?
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user explicitly approves the breakdown.

Do **not** create todos before approval.

### 5. Create the todos

For each approved slice, create a todo using the `todo` tool. Do **not** create todo files by editing the filesystem directly unless the `todo` tool is unavailable.

Create todos in dependency order so later todos can reference the real todo ids of blockers.

Before creating the first todo, derive a single normalized plan slug from the plan title and reuse it across every todo created from that plan.

Use that slug in a shared tag of the form:

- `plan:<slug>`

Example:

- Plan title: `Improved tmux session restore`
- shared tag: `plan:improved-tmux-session-restore`

#### Title conventions

Use a concise title that a teammate could immediately grab.

Good examples:

- `Add minimal PRD list view with end-to-end data flow`
- `Support first-run auth handshake for sync setup`
- `Refine empty-state copy and error recovery flow`

#### Tag conventions

Always include:

- `plan`
- `vertical-slice`
- the shared plan tag: `plan:<slug>`
- `hitl` or `afk`

Optionally include:

- an area tag like `api`, `ui`, `infra`, or `migration` if it helps discoverability

Do not invent a different feature tag per slice if it would fragment search. All todos for the same plan should share the exact same `plan:<slug>` tag so they can be listed and grouped easily.

<todo-template>
## Parent

<path, URL, or short identifier>

## Type

HITL or AFK

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Reference specific sections of the parent plan rather than duplicating it in full.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- TODO-<id> if blocked

Or:

None - can start immediately

## User stories addressed

Reference by number from the parent plan:

- User story 3
- User story 7

## Notes

Any implementation notes, risks, or clarifications needed to make the task independently grabbable.
</todo-template>

Do NOT modify the parent plan.

### 6. Summarize what you created

After creating the todos:

- list each created todo id and title
- show the shared `plan:<slug>` tag used for all created todos
- show dependency relationships using the real todo ids
- mention any user stories that were intentionally deferred or left out

Do **not** claim the todos unless the user asks you to.

## Quality bar

A good output from this skill has these properties:

- every todo is independently understandable
- every todo is small enough to grab and finish
- every todo produces end-to-end value
- acceptance criteria are concrete and testable
- dependencies are real, not speculative
- the todo list is a better execution plan than the original plan alone
