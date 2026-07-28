#!/usr/bin/env python3
"""Post one exact comment on a right-side GitHub pull-request diff line."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys


HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def run(command: list[str], *, payload: dict | None = None):
    result = subprocess.run(
        command,
        input=json.dumps(payload) if payload is not None else None,
        text=True,
        capture_output=True,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"command failed: {' '.join(command)}")
    return json.loads(result.stdout)


def gh_api(endpoint: str, *, method: str = "GET", payload: dict | None = None):
    command = ["gh", "api"]
    if method != "GET":
        command.extend(["--method", method])
    command.append(f"repos/{{owner}}/{{repo}}/{endpoint}")
    if payload is not None:
        command.extend(["--input", "-"])
    return run(command, payload=payload)


def find_file(pr: int, path: str) -> dict:
    page = 1
    while True:
        files = gh_api(f"pulls/{pr}/files?per_page=100&page={page}")
        for file in files:
            if file["filename"] == path:
                return file
        if len(files) < 100:
            raise ValueError(f"{path!r} is not in PR #{pr}")
        page += 1


def right_side_lines(patch: str) -> set[int]:
    commentable: set[int] = set()
    new_line: int | None = None
    for line in patch.splitlines():
        hunk = HUNK_RE.match(line)
        if hunk:
            new_line = int(hunk.group(1))
            continue
        if new_line is None or line.startswith("\\"):
            continue
        if line.startswith("-"):
            continue
        if line.startswith(("+", " ")):
            commentable.add(new_line)
            new_line += 1
    return commentable


def validate_anchor(file: dict, path: str, line: int) -> None:
    patch = file.get("patch")
    if patch is None:
        raise ValueError(f"GitHub did not provide a patch for {path!r}; anchor cannot be validated")
    commentable = right_side_lines(patch)
    if line not in commentable:
        raise ValueError(f"right-side line {line} is not commentable in {path!r}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pr", type=int, required=True)
    parser.add_argument("--file", required=True)
    parser.add_argument("--line", type=int, required=True)
    parser.add_argument("--comment", required=True)
    args = parser.parse_args()

    if args.line < 1:
        raise ValueError("--line must be positive")
    if not args.comment.strip():
        raise ValueError("--comment must not be empty")

    pull = gh_api(f"pulls/{args.pr}")
    file = find_file(args.pr, args.file)
    validate_anchor(file, args.file, args.line)

    payload = {
        "body": args.comment,
        "commit_id": pull["head"]["sha"],
        "path": args.file,
        "line": args.line,
        "side": "RIGHT",
    }

    comment = gh_api(f"pulls/{args.pr}/comments", method="POST", payload=payload)
    print(comment["html_url"])
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(1)
