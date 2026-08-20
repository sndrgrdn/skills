---
name: pi-subagent
description: Dispatch a Pi subagent for one self-contained task. Use when work should run in the background, or another skill tells you to dispatch a subagent.
disable-model-invocation: true
---

# Subagent

## Dispatch

1. Write the brief to a uniquely named temp file, `/tmp/brief-<task>.md`, where `<task>` is a short label for the work. The brief must be self-contained: the task, every file path and datum the subagent needs, the exact commands to run, the expected output shape, and the completion criterion. Step 2 must use the same path.
2. Run with `background: true` so it starts detached, a fast subagent would otherwise return inline with no pid:
   ```bash
   pi -p --mode json --no-session --provider "$PI_PROVIDER" --model "$PI_MODEL" --thinking <level> @<brief-file>
   ```
   `<brief-file>` is the path from step 1; `<level>` is off, minimal, low, medium, high, xhigh, or max, use `high` for reasoning-heavy work (design analysis, review judging), `low` or `minimal` for mechanical tasks (file search, formatting). Record the pid and a total time budget, generous for the task. The bash tool exports `$PI_PROVIDER` and `$PI_MODEL` into every command; a bare `pi -p` ignores them and resolves from the settings.json defaults or the first configured model.

**The caller owns monitoring.** A background subagent never pings back, no callback, no notification; it runs until checked. Watch it: check within the first minute for startup failures, then periodically (`bash_status <pid> wait_seconds=0` streams live progress), and block as the budget approaches (Collect step 1). The pid and budget from step 2 are the caller's handles for that watch.

## Collect

The caller's job, not the subagent's. `<pid>` is the id from Dispatch step 2; `<output-file>` is the path reported by `bash_status`. Check up any time with `bash_status <pid> wait_seconds=0`, JSON mode streams events live, so the file shows progress mid-run.

1. Block with `bash_status <pid> wait_seconds=60`, re-waiting until the process exits 0 and the file contains an `agent_end` event, or until the budget from Dispatch passes, then `bash_cancel <pid>`.
2. Read the output file (the status tail is capped; the file has everything) and extract the result:
   ```bash
   jq -r 'select(.type == "message_end" and .message.role == "assistant") | .message.content[]? | select(.type == "text") | .text' <output-file>  # all assistant text; last line is the final reply
   jq -c 'select(.type == "agent_end") | .messages' <output-file>  # full final message list
   ```
   `message_update` carries live text/thinking/tool-call deltas. Done when the result meets every completion criterion in the brief; otherwise redispatch with the gap named in a fresh brief.

## Failure modes

- **Exit 1 before any event**: a startup error, bad flag, missing model, or missing brief file (pi prints `Error: File not found`). Read the output file; non-JSON lines are stderr noise.
- **Silent empty run** (exit 0, only a `session` line, no `agent_start`): the brief file exists but is empty, so the prompt had no content. Fill the file and redispatch.
- **"Cannot continue from message role"** (exit 1): a retryable error occurred and pi's auto-retry failed, the last message role blocks the retry, not the brief's formatting. Check the output file for the underlying error and rerun.
- **Stall**: there is no auto-timeout, so the budget from Dispatch is the only bound. A subagent's own tool calls can also background, so a healthy run can stay silent for a minute. Only an `agent_end` event confirms completion; all earlier events are indeterminate, and a hung in-flight tool looks identical to a slow one. `bash_cancel <pid>` when the budget passes without an `agent_end`.
- **No `agent_end`**: the subagent produced no final event. If jq reports a parse error, non-JSON lines are in the file, strip them first: `grep -E '^\{' <output-file> | jq ...`. If the file is clean, redispatch with a fresh brief.
