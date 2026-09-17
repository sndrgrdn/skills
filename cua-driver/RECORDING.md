# Recording & replaying trajectories

> **Cross-platform.** Recording is available on macOS (native ScreenCaptureKit), Windows (ffmpeg + `gdigrab`), and Linux (ffmpeg + `x11grab`). Replay is cross-platform as long as the recorded artifacts are present.

Session-scoped capture of action sequences + pre/post state, suitable for demos, regression diffs, and training data. Invoke it only when the user explicitly asks to record. The skill does not auto-enable this.

## Recording and replay completion criteria

Before acting, determine whether the user wants trajectory artifacts, display video, or both, and obtain an output directory. Start is complete only when recording state confirms that recording is enabled for the expected directory. When video was requested, the start result must also confirm that video capture started. Stop recording during cleanup even when the GUI workflow fails. Recording is complete only when state reports disabled and every requested output is finalized.

Replay dispatches real actions. Before replay, inspect the recorded actions, confirm current authorization for destructive or externally visible effects, and verify that the current application, window, account, and content match the intended target. A replay result is not task proof; verify the application postcondition from fresh state afterward.

`start_recording` turns on a session-scoped trajectory recorder. While enabled, every action-tool call (`click`, `right_click`, `scroll`, `type_text`, `press_key`, `hotkey`, `set_value`) writes a numbered turn folder under a caller-chosen output directory. Read-only tools (`get_window_state`, `list_windows`, `screenshot`, `list_apps`, permission probes, agent-cursor getters / setters, and the recording controls themselves) are not recorded.

**Video is off by default.** `start_recording` captures trajectory artifacts without recording the full display. Pass `record_video: true` only when the user requested or approved display video. The resulting mp4 is finalized on `stop_recording`.

**macOS: native ScreenCaptureKit, zero-config.** On macOS the daemon's recorder uses `SCStream` + `SCRecordingOutput`, so it inherits the daemon's Screen Recording grant, with no separate subprocess prompt, no fast-fail, no second TCC dance. Requires macOS 15.0+ (SCRecordingOutput introduced in macOS 15). No ffmpeg needed.

**Windows / Linux: ffmpeg subprocess.** Outside macOS the recorder shells to ffmpeg with `gdigrab` (Windows) or `x11grab` (Linux). The binary needs to be on PATH (`winget install Gyan.FFmpeg` / `apt install ffmpeg`); when missing, the per-turn capture continues without video and `last_error` carries the install hint. ffmpeg startup failures fast-fail with a stderr tail in the error.

## Start / stop

When `LOCAL.md` exists, keep start, recorded actions, state checks, and stop on its selected transport. The CLI examples below are upstream operator reference when a local policy selects another transport.

Two upstream surfaces are available: the `start_recording` / `stop_recording` MCP tools, or the friendlier `cua-driver recording` subcommand group (wraps both with human-readable output).

```
cua-driver recording start ~/cua-trajectories/run-1
# … run the workflow …
cua-driver recording status    # -> enabled / disabled, next_turn, output_dir
cua-driver recording stop      # -> "Recording stopped. (video → recording.mp4)"
```

Raw-tool equivalent:

```
cua-driver start_recording '{"output_dir":"~/cua-trajectories/run-1"}'
cua-driver get_recording_state
cua-driver stop_recording '{}'
```

The `recording` subcommands require a running daemon (`cua-driver serve &`) because recording state is per-process. `output_dir` expands `~` and is created (with intermediates) if missing. Turn numbering starts at `1` every time recording is (re-)enabled, regardless of any existing contents in the directory. State lives in memory only, so a daemon restart resets to disabled.

## What each turn folder contains

Each action writes to `turn-NNNNN/` (five-digit zero-padded counter):

- `before_state.json` and `after_state.json`: application accessibility state immediately before and after the action. They carry the same `tree_markdown` and `element_count` shape as `get_window_state`.
- `before.png` and `after.png`: target-window images immediately before and after the action. Window capture remains scoped to the target when another window covers it.
- `evidence.json`: capture status for each phase. Missing expected capture has an explicit classification instead of disappearing from the turn.
- `app_state.json` and `screenshot.png`: compatibility aliases for `after_state.json` and `after.png`.
- `action.json`: the tool name, full input arguments, result summary, result-error flag, pid, click point (when applicable), ISO-8601 timestamp.
- `click.png`: for click-family actions (`click`, `double_click`, `right_click`): a copy of the pre-input image with a red marker drawn at the click point. Usually that source is `before.png`. When Windows scrolls an element into view during an action, it retains an additional `click_source.png` immediately before coordinate input. In that case, `action.json` names `click_point_image: "click_source.png"`, and `evidence.json` records `click.source_image` and the `click_source` capture status. The original before/after images and state remain intact. **Both addressing modes are covered:** explicit `x, y` clicks use the platform's recording-coordinate mapping, and `element_index`-addressed clicks resolve to the element's center via the live AX/UIA cache, then convert to the retained image's coordinate space. Native Hyprland recording retains the output image, so both kinds of marker use output coordinates. Pixel markers also account for the target window's origin and any snapshot resize or zoom. Absent for non-click tools. It is also absent, and explicitly classified as not applicable, when the driver refuses a click before target resolution; no input was aimed in that case. A successful plain macOS AX, Linux AT-SPI, or Windows UIA element click (Invoke, Toggle, SelectionItem, or ExpandCollapse) can activate a control without a visible point, such as an offscreen button. In that case, `semantic_action_without_point` records why there is no marker. The action must carry explicit accessibility transport and known delivery metadata; its before/after state, images, and requested video remain required. This exception does not apply to pixel clicks, Windows SendInput clicks, uncertain delivery, or failed marker rendering. Out-of-image points are rejected, never moved to an image edge. Other dispatched clicks whose markers cannot be resolved or rendered remain evidence failures.

## When to use it

- Demos and screen recordings: play the turn folder back to show exactly what the agent saw and what it did.
- Replay for regression: re-run the same sequence against a future build and diff the new trajectory against the saved one.
- Training data collection: each turn is a `(state, action, next_state)` triple ready for offline learning.

## When to invoke it

This skill does **not** auto-enable recording. The client invokes `start_recording` explicitly when the user asks to capture a session. If the user says "record this session" or similar, clarify whether display video is required, call `start_recording({output_dir:…})` before the first action, and call `stop_recording({})` during cleanup. Pass `record_video:true` only for approved display capture.

## Replaying a recorded trajectory

Treat recorded process IDs, window IDs, snapshot capabilities, coordinates, and focus assumptions as stale until current state proves that they still apply. Stop rather than replaying blindly when a recorded target cannot be bound safely to current state.

`replay_trajectory({dir})` walks `<dir>/turn-NNNNN/` folders in lexical order, reads each `action.json`, and re-invokes the recorded tool with its recorded `arguments`. Optional knobs: `delay_ms` (pacing between turns, default 500) and `stop_on_error` (halt on first failure, default true).

```
cua-driver recording start ~/cua-trajectories/demo1
# … run the workflow …
cua-driver recording stop
# Later: replay against a new build.
cua-driver replay_trajectory '{"dir":"~/cua-trajectories/demo1","delay_ms":500}'
```

Important caveat: **element_index doesn't survive across sessions**. Indices are assigned fresh on every `get_window_state` snapshot, keyed on `(pid, window_id)`, so a recorded `click({pid, window_id, element_index: 14})` from yesterday won't resolve today because the pid is usually different, the window_id always is. The call returns `Invalid element_index` or `No cached AX state`. Pixel clicks (`click({pid, x, y})`) and keyboard tools (`press_key`, `hotkey`, `type_text` without element_index) replay cleanly; element-indexed actions require a live snapshot that replay doesn't currently re-emit (read-only tools like `get_window_state` aren't recorded). For a reliable replay, either compose the trajectory from pixel + keyboard primitives, or capture it as a regression artifact (compare the failure/success pattern across builds) rather than a re-driving script.

If recording is still enabled while replay runs, the replay is itself recorded into the current output directory. That is the intended regression-diff workflow.
