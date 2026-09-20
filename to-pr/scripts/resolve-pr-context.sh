#!/usr/bin/env bash
# Returns the repository context required for pull request publication.
# Usage: bash "<skill-directory>/scripts/resolve-pr-context.sh"
# Output: {"repository":"...","visibility":"PUBLIC|PRIVATE|INTERNAL|UNKNOWN","current_branch":"...","remote_branch_exists":bool,"default_branch":"..."}

# `git config --get remote.origin.url` is read-only: it reads the remote without
# any chance of mutating it (unlike `git remote ...`, which can rewrite remotes).
REPOSITORY=$(git config --get remote.origin.url 2>/dev/null | sed -E 's|^.*github\.com[:/]||; s|\.git$||') || REPOSITORY=""

GH_REPOSITORY_ARGUMENTS=()
if [[ "$REPOSITORY" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]]; then
  GH_REPOSITORY_ARGUMENTS=("$REPOSITORY")
fi

VISIBILITY=$(gh repo view "${GH_REPOSITORY_ARGUMENTS[@]}" --json visibility -q '.visibility' 2>/dev/null || echo "UNKNOWN")

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

REMOTE_BRANCH_EXISTS="false"
if [ -n "$CURRENT_BRANCH" ] && git ls-remote --heads origin "$CURRENT_BRANCH" 2>/dev/null | grep -q .; then
  REMOTE_BRANCH_EXISTS="true"
fi

DEFAULT_BRANCH=$(gh repo view "${GH_REPOSITORY_ARGUMENTS[@]}" --json defaultBranchRef -q '.defaultBranchRef.name' 2>/dev/null)
if [ -z "$DEFAULT_BRANCH" ] || [ "$DEFAULT_BRANCH" = "null" ]; then
  DEFAULT_BRANCH=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
fi
: "${DEFAULT_BRANCH:=main}"

jq -nc \
  --arg repository "$REPOSITORY" \
  --arg visibility "$VISIBILITY" \
  --arg current_branch "$CURRENT_BRANCH" \
  --argjson remote_branch_exists "$REMOTE_BRANCH_EXISTS" \
  --arg default_branch "$DEFAULT_BRANCH" \
  '{repository:$repository,visibility:$visibility,current_branch:$current_branch,remote_branch_exists:$remote_branch_exists,default_branch:$default_branch}'
