# Local Cua Driver policy

These rules override upstream transport and host defaults. The action and verification rules in [SKILL.md](SKILL.md) still apply.

## GUI transport

Use the persistent `computer` MCP server for every GUI workflow. Use the CLI only for installation, diagnostics, updates, and isolated read-only inspection. Keep each multi-call action sequence on one MCP connection. Discover tools through the `mcp` gateway with `server: "computer"`, and treat installed tool schemas as authoritative.

After a connection error, reconnect once, discard connection-bound targets, and take fresh state before deciding what to do next. Retry an action only when fresh state proves that it did not occur and repetition is safe. Stop and ask the user after a permission error.

## macOS and Helium profile

Read [MACOS.md](MACOS.md) before the first GUI action. Use the existing Helium profile. Before authenticated or destructive work, verify that the visible account name or address matches an identifier supplied by the user or established by the task. Ask the user when no expected identifier exists or the visible account cannot be verified.

Use native window tools when exact browser binding is unavailable. Treat a refusal as a hard boundary. Keep the current profile, remote-debugging configuration, and existing-profile authorization unchanged.

## Foreground control and data privacy

Prefer background delivery and keep the agent cursor visible. Ask before foreground delivery or desktop takeover unless the user authorized it for the current workflow. After a Cua Driver refusal, stop rather than switching to AppleScript or a global-pointer tool.

Enable recording, history, or broader runtime permissions only after an explicit user request. Keep Cua Driver telemetry disabled.

## Skill pack updates

This directory is a physical copy of the release-matched pack from `cua-driver skills path`, not an installer-managed symlink. After `cua-driver skills update`, compare the canonical pack with this directory, update the upstream files, and preserve `LOCAL.md` plus the local entry pointer in `SKILL.md`. The update is complete only when upstream-owned files match the selected release, local overrides remain present, and no unrelated local file was removed.
